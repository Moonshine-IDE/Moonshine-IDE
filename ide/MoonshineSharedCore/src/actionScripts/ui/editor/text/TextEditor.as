////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.editor.text
{
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import mx.controls.HScrollBar;
    import mx.controls.scrollClasses.ScrollBar;
    import mx.core.UIComponent;
    import mx.events.ResizeEvent;
    import mx.events.ScrollEvent;
    import mx.managers.IFocusManagerComponent;
    
    import __AS3__.vec.Vector;
    
    import actionScripts.events.ChangeEvent;
    import actionScripts.events.LayoutEvent;
    import actionScripts.events.LineEvent;
    import actionScripts.events.OpenFileEvent;
    import actionScripts.ui.editor.text.vo.SearchResult;
    import actionScripts.ui.parser.ILineParser;
    import actionScripts.utils.TextUtil;
    import actionScripts.valueObjects.Diagnostic;
    import actionScripts.valueObjects.Location;
    import actionScripts.valueObjects.Position;
    import actionScripts.valueObjects.SignatureHelp;
    import actionScripts.valueObjects.Command;
    import actionScripts.valueObjects.CodeAction;
    import actionScripts.valueObjects.CompletionItem;

    /**
     *	Line-based text editor. Text rendering with Flash Text Engine.
     *	DataProvider (String) is split up newline & each TextLineRenderer gets one line to render.
     *	Only what can be seen on screen is rendered & item-renderers are reused.
     *
     *	This class handles scrolling & rendering, MVC style.
     *	Different types of rendering can be triggered with various invalidateSomething() calls,
     *	upon which a flag will be set & when the frame exists rendering will happen (the Flex way).
     *
     *	Managers handle non-rendering actions and affect TextEditorModel, which is the base for rendering.
     *	See EditManager, UndoManager, SelectionManager & ColorManager.
     *
     *	WORK IN PROGRESS
     */
	[Style(name="backgroundColor",type="uint",format="Color",inherit="no")]
	[Style(name="backgroundAlpha",type="Number",format="Number",inherit="no")]
	[Style(name="selectionColor",type="uint",format="Color",inherit="yes")]
	[Style(name="selectedLineColor",type="uint",format="Color",inherit="no")]
	[Style(name="selectedLineColorAlpha",type="Number",format="Number",inherit="no")]
	[Style(name="selectedAllInstancesOfASearchStringColorAlpha",type="uint",format="Color",inherit="no")]
	public class TextEditor extends UIComponent implements IFocusManagerComponent
	{	
		// Amount to look ahead when horiz-scrolling caret into view (8 characters)
		private static const HORIZONTAL_LOOKAHEAD:int = TextLineRenderer.charWidth*8;
        private static const WIDTH_UPDATE_DELAY:int = 100;
		
		// Holds the text lines
		internal var itemContainer:UIComponent = new UIComponent();
		
		private var verticalScrollBar:ScrollBar;
		// The square connecting dual scrollbars
		private var scrollbarConnector:UIComponent;

		protected var selectionManager:SelectionManager;
		protected var editManager:EditManager;
		protected var colorManager:ColorManager;
		protected var undoManager:UndoManager;
		protected var searchManager:SearchManager;
		protected var completionManager:CompletionManager;
		protected var signatureHelpManager:SignatureHelpManager;
		protected var hoverManager:HoverManager;
		protected var gotoDefinitionManager:GotoDefinitionManager;
		protected var diagnosticsManager:DiagnosticsManager;
		protected var codeActionsManager:CodeActionsManager;
		protected var editorToolTipManager:EditorToolTipManager;
		
		public var model:TextEditorModel;
		
		private var widthUpdateTime:int;
		private var widthUpdateDelayer:Timer;
		
		// Style defaults
		private var _backgroundColor:uint = 			0xfdfdfd;
		private var _backgroundAlpha:uint = 			1;
		private var lineNumberBackgroundColor:uint = 	0xf9f9f9;
		private var _selectionColor:uint =				0xd1e3f9;
		private var _selectedAllInstancesOfASearchStringColorAlpha:uint = 0xffb2ff;
		private var _selectedLineColor:uint =  			0xedfbfb;
		private var _selectedLineColorAlpha:Number =	1;
		private var _tracingLineColor:uint=				0xc6dbae;	
		// Invalidation flags
		private const INVALID_RESIZE:uint =		1 << 0;
		private const INVALID_SCROLL:uint =		1 << 1;
		private const INVALID_FULL:uint =		1 << 2;
		private const INVALID_SELECTION:uint =	1 << 3;
		private const INVALID_LAYOUT:uint =		1 << 4;
		private const INVALID_WIDTH:uint =		1 << 5;
		private const INVALID_TRACESELECTION:uint =	1 << 6;
		private var invalidFlags:uint = 0;
		public var horizontalScrollBar:HScrollBar;
		public  var startPos:Number=0;
		public var isNeedToBeTracedAfterOpening:Boolean;
		// Getters/Setters
		public function get dataProvider():String
		{
			return model.lines.join(lineDelim); 
		}
		public function set dataProvider(value:String):void
		{
			// Detect line ending (for saves)
			// TODO: take first found line encoding
			if (value.indexOf("\r\n")>-1)
			{
				_lineDelim = "\r\n";
            }
			else if (value.indexOf("\r")>-1)
			{
				_lineDelim = "\r";
            }
			else
			{
				_lineDelim = "\n";
            }
			
			// Split lines regardless of line encoding
			var lines:Array = value.split(/\r?\n|\r/);
			var count:int = lines.length;
			
			// Populate lines into model
			model.lines = new Vector.<TextLineModel>(count);
			
			var tagSelectionLineBeginIndex:int = -1;
			var tagSelectionLineEndIndex:int = -1;
			for (var i:int = 0; i < count; i++)
			{
				if (lines[i].indexOf("_moonshineSelected_") != -1)
				{
					if (tagSelectionLineBeginIndex == -1) tagSelectionLineBeginIndex = i;
					else tagSelectionLineEndIndex = i;
					lines[i] = lines[i].replace("_moonshineSelected_", "");
				}
				
				model.lines[i] = new TextLineModel(lines[i]);
			}
			
			if (tagSelectionLineBeginIndex != -1 && tagSelectionLineEndIndex == -1) tagSelectionLineEndIndex = tagSelectionLineBeginIndex;
			colorManager.reset();
			
			// Clear undo history (readOnly doesn't have it)
			if (undoManager) undoManager.clear();
			
			// Reset selection state
			model.setSelection(0, 0, 0, 0);
			// Reset scroll
			model.scrollPosition = 0;
			model.horizontalScrollPosition = 0;
			if (verticalScrollBar) verticalScrollBar.scrollPosition = 0;
			if (horizontalScrollBar) horizontalScrollBar.scrollPosition = 0;
			
			// If we got breakpoints set before we loaded text, re-set them.
			if (_breakpoints)
			{
				breakpoints = _breakpoints;
				_breakpoints = null;
			}
			
			// Set invalidation flags for render
			invalidateLines();
			
			if (isNeedToBeTracedAfterOpening) 
			{
				this.callLater(function():void
				{
					scrollTo(DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE, OpenFileEvent.TRACE_LINE);
					selectTraceLine(DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE);
				});
			}
			
			if (tagSelectionLineBeginIndex != -1)
			{
				searchManager.unHighlightTagSelection();
				callLater(function():void
				{
					searchManager.highlightTagSelection(tagSelectionLineBeginIndex, tagSelectionLineEndIndex);
				});
			}
			else if (!isNeedToBeTracedAfterOpening && model.allInstancesOfASearchStringDict)
			{
				searchManager.unHighlightTagSelection();
			}
		}
		
		private var _lineDelim:String = "\n";
		public function set lineDelim(value:String):void
		{
			_lineDelim = value;
		}
		public function get lineDelim():String
		{
			return _lineDelim;
		}
		
		private var _lineNumberWidth:int = 35;
		public function get lineNumberWidth():int
		{
			return _lineNumberWidth;
		}
		public function set lineNumberWidth(value:int):void
		{
			if (value != _lineNumberWidth)
			{
				var textLineRenderer:TextLineRenderer;

				// Update all item renderers since this value can happen when editing (999->1000, etc)
				for each (textLineRenderer in model.itemRenderersFree)
				{
					textLineRenderer.lineNumberWidth = value;
				}
				for each (textLineRenderer in model.itemRenderersInUse)
				{
					textLineRenderer.lineNumberWidth = value;
				}
				
				_lineNumberWidth = value;
				invalidateLines();
			}
		}
		
		private var _showScrollBars:Boolean = true;
		public function get showScrollBars():Boolean
		{
			return _showScrollBars;
		}
		public function set showScrollBars(value:Boolean):void
		{
			_showScrollBars = value;
			if (verticalScrollBar)
			{
				if (value)
				{
					verticalScrollBar.alpha = horizontalScrollBar.alpha = 0;
                }
				else
				{
					verticalScrollBar.alpha = horizontalScrollBar.alpha = 1;
                }
			} 
		}
		
		private var _showLineNumbers:Boolean = true;
		public function get showLineNumbers():Boolean
		{
			return _showLineNumbers;
		}
		public function set showLineNumbers(value:Boolean):void
		{
			_showLineNumbers = value;
			{
				lineNumberWidth = 0;	
			}
		}
		
		private var _hasFocus:Boolean;
		public function get hasFocus():Boolean
		{
			return _hasFocus;
		}
		public function set hasFocus(value:Boolean):void
		{
			_hasFocus = value;
			if(model.hasTraceSelection)
				invalidateTraceSelection(true);
			else
				invalidateSelection(true);
		}
		
		public function get hasChanged():Boolean
		{
			if (!undoManager) return false;
			
			return undoManager.hasChanged;
		}
		
		public function save():void
		{
			if (!undoManager) return;
			
			// Enables undoManager.hasChanged
			undoManager.save();
		}

		public function get signatureHelpActive():Boolean
		{
			return signatureHelpManager && signatureHelpManager.isActive;
		}
		
		// Hook in syntax parser & it's styles
		public function setParserAndStyles(parser:ILineParser, styles:Object):void
		{
			colorManager.setParser(parser);
			if (styles) 
			{
				if (!styles['selectedLineColor']) 		styles['selectedLineColor'] = _selectedLineColor;
				if (!styles['selectionColor']) 			styles['selectionColor'] = _selectionColor;
				if (!styles['selectedAllInstancesOfASearchStringColorAlpha']) styles['selectedAllInstancesOfASearchStringColorAlpha'] = _selectedAllInstancesOfASearchStringColorAlpha;
				if (!styles['selectedLineColorAlpha'])	styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
				
				colorManager.styles = styles;
				
				var textLineRenderer:TextLineRenderer;
				for each (textLineRenderer in model.itemRenderersFree)
				{
					textLineRenderer.styles = styles;
				}
				for each (textLineRenderer in model.itemRenderersInUse)
				{
					textLineRenderer.styles = styles;
				}
				
				invalidateLines();
			}
		}
		
		// Only used to set breakpoints later on.
		private var _breakpoints:Array;
		public function get breakpoints():Array
		{
			// Get breakpoints from line models
			var bps:Array = [];
			var linesCount:int = model.lines.length;
			
			for (var i:int = 0; i < linesCount; i++)
			{
				var line:TextLineModel = model.lines[i];
				if (line.breakPoint) bps.push(i);
			}
			return bps;
		}
		public function set breakpoints(value:Array):void
		{
			_breakpoints = value; // if it exists when set dataProvider is called we re-populate & remove it.
			var breakpointsCount:int = value.length;
			for (var i:int = 0; i < breakpointsCount; i++)
			{
				var lineNumber:int = value[i];
				if (lineNumber >= model.lines.length) return;
				var line:TextLineModel = model.lines[lineNumber];
				line.breakPoint = true;
			}
		}
		public function setCompletionData(begin:int, end:int, s:String):void
		{
			editManager.setCompletionData(begin, end, s);
		}
		public function TextEditor(readOnly:Boolean=false):void
		{
			model = new TextEditorModel();
			
			widthUpdateDelayer = new Timer(0, 0);
			widthUpdateDelayer.addEventListener(TimerEvent.TIMER_COMPLETE, calculateTextWidth);
			
			selectionManager = new SelectionManager(this, model);
			colorManager = new ColorManager(this, model);
			colorManager.styles['selectedLineColor'] = _selectedLineColor;
			colorManager.styles['selectionColor'] = _selectionColor;
			colorManager.styles['selectedAllInstancesOfASearchStringColorAlpha'] = _selectedAllInstancesOfASearchStringColorAlpha;
			colorManager.styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
			
			editManager = new EditManager(this, model, readOnly);
			
			if (!readOnly)
			{
				undoManager = new UndoManager(this, model);
				completionManager = new CompletionManager(this, model);
				signatureHelpManager = new SignatureHelpManager(this, model);
			}
			
			searchManager = new SearchManager(this, model);
			hoverManager = new HoverManager(this, model);
			gotoDefinitionManager = new GotoDefinitionManager(this, model);
			diagnosticsManager = new DiagnosticsManager(this, model);
			codeActionsManager = new CodeActionsManager(this, model);
			editorToolTipManager = new EditorToolTipManager(this, model);
			
			addEventListener(ChangeEvent.TEXT_CHANGE, handleChange, false, 1);
			addEventListener(LineEvent.COLOR_CHANGE, handleColorChange);
			addEventListener(LineEvent.WIDTH_CHANGE, handleWidthChange);
			
			addEventListener(ResizeEvent.RESIZE, handleResize);
		}
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);

			var backgroundColor:* = getStyle('backgroundColor');
			var backgroundAlpha:* = getStyle('backgroundAlpha');
			var selectionColor:* = getStyle('selectionColor');
			var selectedAllInstancesOfASearchStringColorAlpha:* = getStyle('selectedAllInstancesOfASearchStringColorAlpha');
            var selectedLineColor:* = getStyle('selectedLineColor');
			var selectedLineColorAlpha:* = getStyle('selectedLineColorAlpha');
			var tracingLineColor:* = getStyle('tracingLineColor');

			if (backgroundColor)
			{ 
				_backgroundColor = backgroundColor;
			}
			
			if (backgroundAlpha)
			{
				_backgroundAlpha = backgroundAlpha;
			}

			if (backgroundColor || backgroundAlpha)
			{
                invalidateFlag(INVALID_RESIZE);
			}

			if (selectionColor)
			{
				_selectionColor = selectionColor;
				colorManager.styles['selectionColor'] = _selectionColor;
			}
			if (selectedAllInstancesOfASearchStringColorAlpha)
			{
				_selectedAllInstancesOfASearchStringColorAlpha = selectedAllInstancesOfASearchStringColorAlpha;
				colorManager.styles['selectedAllInstancesOfASearchStringColorAlpha'] = _selectedAllInstancesOfASearchStringColorAlpha;
			}
			if (selectedLineColor)
			{
				_selectedLineColor = selectedLineColor;
				colorManager.styles['selectedLineColor'] = _selectedLineColor;
			}
			if (selectedLineColorAlpha)
			{
				_selectedLineColorAlpha = selectedLineColorAlpha;
				colorManager.styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
			}

			if (selectionColor || selectedLineColor || selectedLineColorAlpha || selectedAllInstancesOfASearchStringColorAlpha)
			{
                invalidateSelection(true);
			}

			if (tracingLineColor)
			{
				_tracingLineColor = tracingLineColor;
				colorManager.styles['tracingLineColor'] = _tracingLineColor;
				invalidateTraceSelection(true);
			}
		}
		
		public function invalidateLines():void
		{
			invalidateFlag(INVALID_FULL);
			invalidateFlag(INVALID_RESIZE);
		}
		
		public function invalidateSelection(noScroll:Boolean = false):void
		{
			invalidateFlag(INVALID_SELECTION);
			
			if (!noScroll) scrollViewIfNeeded();
		}
		public function invalidateTraceSelection(noScroll:Boolean = false):void
		{
			invalidateFlag(INVALID_TRACESELECTION);
			
			//if (!noScroll) scrollViewIfNeeded();
		}
		public function scrollViewIfNeeded():void
		{
			// Scroll view if needed
			if (model.renderersNeeded > 0)
			{
				var caretPos:int = colorManager.calculateWidth(model.selectedLine.text.slice(0,model.caretIndex));
				var scrollPos:Number;

				if (model.selectedLineIndex < verticalScrollBar.scrollPosition || model.renderersNeeded <= 2 && model.selectedLineIndex > verticalScrollBar.scrollPosition)
				{
					verticalScrollBar.scrollPosition = model.selectedLineIndex;
					invalidateFlag(INVALID_SCROLL);
				}
				else if (model.renderersNeeded > 2 && model.selectedLineIndex + 2 > verticalScrollBar.scrollPosition + model.renderersNeeded)
				{
                    scrollPos = model.selectedLineIndex - model.renderersNeeded + 2;
					if (scrollPos < 0)
					{
						scrollPos = 0;
					}

					verticalScrollBar.scrollPosition = scrollPos;
					invalidateFlag(INVALID_SCROLL);
				}
				if (caretPos < model.horizontalScrollPosition)
				{
                    scrollPos = caretPos - HORIZONTAL_LOOKAHEAD;
					if (scrollPos < 0)
					{
						scrollPos = 0;
					}

					model.horizontalScrollPosition = horizontalScrollBar.scrollPosition = scrollPos;
					invalidateFlag(INVALID_SCROLL);
				}
				else if (caretPos > model.horizontalScrollPosition + model.viewWidth)
				{
					model.horizontalScrollPosition = horizontalScrollBar.scrollPosition = caretPos - model.viewWidth + HORIZONTAL_LOOKAHEAD;
					invalidateFlag(INVALID_SCROLL);
				}
			}
		}
		
		public function getSelection():String
		{
			if (model.hasMultilineSelection)
			{
				var startLine:int = model.selectionStartLineIndex;
				var endLine:int = model.selectedLineIndex;
				
				var start:int = model.selectionStartCharIndex;
				var end:int = model.caretIndex;
				
				if (startLine > endLine)
				{
					startLine = endLine;
					endLine = model.selectionStartLineIndex;
					
					start = end;
					end = model.selectionStartCharIndex;
				}
				
				var selText:String = model.lines[startLine].text.substr(start);
				for (var i:int = startLine+1; i < endLine; i++)
				{
					selText += lineDelim + model.lines[i].text;
				}
				selText += lineDelim + model.lines[endLine].text.substr(0, end);
				
				return selText;
				
			}
			else if (model.hasSelection)
			{
				start = model.selectionStartCharIndex;
				end = model.caretIndex;
				if (model.selectionStartCharIndex > model.caretIndex) 
				{
					start = end;
					end = model.selectionStartCharIndex;
				}
				
				return model.selectedLine.text.substring(start, end);
			}
			
			return "";
		}

		private function handleChange(event:ChangeEvent):void
		{
			// Any text change requires line invalidation
			invalidateLines();
		}
		
		private function handleColorChange(event:LineEvent):void
		{
			// Line invalidation is required if the changed line is on-screen
			if (event.line >= model.scrollPosition && event.line <= model.scrollPosition + model.renderersNeeded + 1)
			{
				invalidateLines();
			}
		}
		
		private function handleWidthChange(event:LineEvent):void 
		{
			var line:TextLineModel = model.lines[event.line];
			if (line.width > model.textWidth) 
			{
				model.textWidth = line.width;
				invalidateFlag(INVALID_WIDTH);
			} 
			else 
			{
				var timeDiff:int = getTimer()-widthUpdateTime;
				if (timeDiff < WIDTH_UPDATE_DELAY)
				{
					if (!widthUpdateDelayer.running) 
					{
						widthUpdateDelayer.delay = WIDTH_UPDATE_DELAY-timeDiff;
						widthUpdateDelayer.reset();
						widthUpdateDelayer.start();
					}
				}
				else 
				{
					calculateTextWidth();
				}
			}
		}
		
		private function calculateTextWidth(event:TimerEvent = null):void 
		{
			var linesCount:int = model.lines.length;
			var max:Number = 0;
			for (var i:int = 0; i < linesCount; i++)
			{
				var line:TextLineModel = model.lines[i];
				if (line.width > max) 
				{
					max = line.width;
				}
			}
			
			if (model.textWidth != max)
			{
				invalidateFlag(INVALID_WIDTH);
			}
			
			model.textWidth = max;
			widthUpdateTime = getTimer();
		}
			
		public function selectLine(lineIndex:int):void
		{
			lineIndex = Math.max(0, Math.min(model.lines.length-1, lineIndex));
			model.removeSelection();
			model.selectedLineIndex = lineIndex;
			
			invalidateSelection();
		}
		
		public function selectRangeAtLine(search:*, range:Object=null):void
		{
			var rdr:TextLineRenderer;
			var itemRenderersInUseCount:int = model.itemRenderersInUse.length;
			
			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (i+model.scrollPosition == range.startLineIndex)
				{
					var results:Array = RegExp(search).exec(rdr.model.text);
					if (results != null)
					{
						var lc:Point = TextUtil.charIdx2LineCharIdx(rdr.model.text, results.index, lineDelim);
						
						model.selectedLineIndex = range.startLineIndex;
						rdr.focus = hasFocus;
						rdr.caretPosition = model.caretIndex = lc.y + results[0].length;
						model.selectionStartCharIndex = lc.y;
						rdr.drawSelection(model.selectionStartCharIndex, model.caretIndex);
					}
				}
				else
				{
					rdr.focus = false;
					rdr.removeSelection();
				}
			}
		}
		
		public function selectTraceLine(lineIndex:int):void
		{
			lineIndex = Math.max(0, Math.min(model.lines.length-1, lineIndex));
			model.removeTraceSelection();
			model.selectedTraceLineIndex = lineIndex;
			model.hasTraceSelection = true;
			DebugHighlightManager.verifyNewFileOpen(model);
			
			invalidateTraceSelection();
		}
		public function getPointForIndex(index:int):Point
		{
			return getXYForCharAndLine(index, model.selectedLineIndex);
		}
		public function getXYForCharAndLine(character:int, line:int):Point
		{
			var rdrIdx:int = line - model.scrollPosition;
			var rdr:TextLineRenderer = model.itemRenderersInUse[rdrIdx];

			var charBounds:Rectangle = rdr.getCharBounds(character);
			// .x is manually adjusted, so we can't use .topLeft:Point, instead we create a new Point.
			return rdr.localToGlobal(new Point(charBounds.x, charBounds.y));
		}
		public function getCharAndLineForXY(globalXY:Point, returnNextAfterCenter:Boolean = true):Point
		{
			var localXY:Point = this.globalToLocal(globalXY);
			var itemRenderer:TextLineRenderer = null;
			var itemRenderers:Vector.<TextLineRenderer> = model.itemRenderersInUse;
			var itemRendererCount:int = itemRenderers.length;
			for(var i:int = 0; i < itemRendererCount; i++)
			{
				var currentItemRenderer:TextLineRenderer = itemRenderers[i];
				if(localXY.y >= currentItemRenderer.y &&
					localXY.y < (currentItemRenderer.y + currentItemRenderer.height))
				{
					itemRenderer = currentItemRenderer;
					break;
				}
			}
			if(!itemRenderer)
			{
				return null;
			}
			var charIndex:int = itemRenderer.getCharIndexFromPoint(globalXY.x, returnNextAfterCenter);
			if(charIndex === -1)
			{
				return null;
			}
			var bounds:Rectangle = itemRenderer.getCharBounds(itemRenderer.model.text.length - 1);
			localXY = itemRenderer.globalToLocal(globalXY);
			if(localXY.x > (bounds.x + bounds.width))
			{
				//after the final character, so we don't care
				return null;
			}
			return new Point(charIndex, itemRenderer.dataIndex);
		}
		public function scrollTo(lineIndex:int, eventType:String = null):void
		{
			if (!canScroll(lineIndex, eventType))
			{
				return;
            }
			
			// in case (when editor first opens)
			// requisite values not initialized yet
			if (verticalScrollBar.minScrollPosition == 0 && verticalScrollBar.maxScrollPosition == 0)
			{
				verticalScrollBar.callLater(scrollTo, [lineIndex, eventType]);
				return;
			}

            var verticalOffsetLineIndex:int = lineIndex;
			if (eventType ==  OpenFileEvent.TRACE_LINE || eventType ==  OpenFileEvent.JUMP_TO_SEARCH_LINE)
			{
				verticalOffsetLineIndex = lineIndex - verticalScrollBar.pageSize / 2;
			}

			var scrollPos:Number = verticalOffsetLineIndex;
			if (scrollPos < verticalScrollBar.minScrollPosition)
			{
				scrollPos = verticalScrollBar.minScrollPosition;
			}

			if (verticalScrollBar.maxScrollPosition < scrollPos)
			{
				scrollPos = verticalScrollBar.maxScrollPosition;
			}

			verticalScrollBar.scrollPosition = scrollPos;
			if (horizontalScrollBar.visible)
			{
				scrollPos = x;
				if (x < horizontalScrollBar.minScrollPosition)
				{
					scrollPos = horizontalScrollBar.minScrollPosition;
				}

				if (horizontalScrollBar.maxScrollPosition < scrollPos)
				{
					scrollPos = horizontalScrollBar.maxScrollPosition;
				}

				horizontalScrollBar.scrollPosition = scrollPos;
			}
			invalidateFlag(INVALID_SCROLL);
		}

		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean):SearchResult
		{
			return searchManager.search(search, null, false, backwards);
		}
		
		// Search all instances and highlight
		// Preferably used in 'search in project' sequence
		public function searchAndShowAll(search:*):void
		{
			searchManager.searchAndShowAll(search);
		}
		
		// Search may be RegExp or String
		public function searchReplace(search:*, replace:String=null, all:Boolean=false):SearchResult
		{
			return searchManager.search(search, replace, all);
		}
		
		public function get completionActive():Boolean
		{
			return completionManager.isActive;
		}
		
		public function showCompletionList(items:Array):void
		{
			completionManager.showCompletionList(items);
		}
		
		public function resolveCompletionItem(item:CompletionItem):void
		{
			completionManager.resolveCompletionItem(item);
		}

		public function showSignatureHelp(data:SignatureHelp):void
		{
			if (!signatureHelpManager)
			{
				return;
			}

			signatureHelpManager.showSignatureHelp(data);
		}

		public function showHover(contents:Vector.<String>):void
		{
			hoverManager.showHover(contents);
		}

		public function showDefinitionLink(locations:Vector.<Location>, position:Position):void
		{
			gotoDefinitionManager.showDefinitionLink(locations, position);
		}

		public function showDiagnostics(diagnostics:Vector.<Diagnostic>):void
		{
			diagnosticsManager.showDiagnostics(diagnostics);
		}

		public function showCodeActions(codeActions:Vector.<CodeAction>):void
		{
			codeActionsManager.showCodeActions(codeActions);
		}

		public function setTooltip(id:String, text:String, html:Boolean = false):void
		{
			editorToolTipManager.setTooltip(id, text, html);
		}

		private function handleResize(event:ResizeEvent):void
		{
			invalidateFlag(INVALID_RESIZE);
			invalidateFlag(INVALID_FULL);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			addChild(itemContainer);
			updateScrollRect();
			
			verticalScrollBar = new ScrollBar();
			verticalScrollBar.minScrollPosition = 0;
			verticalScrollBar.lineScrollSize = 1;
			verticalScrollBar.addEventListener(ScrollEvent.SCROLL, handleScroll);
			addChild(verticalScrollBar);
			
			horizontalScrollBar = new HScrollBar();
			horizontalScrollBar.minScrollPosition = 0;
			horizontalScrollBar.lineScrollSize = 1;
			horizontalScrollBar.addEventListener(ScrollEvent.SCROLL, handleScroll);
			addChild(horizontalScrollBar);
			
			scrollbarConnector = new UIComponent();
			scrollbarConnector.graphics.beginFill(0x323232, 1);
			scrollbarConnector.graphics.drawRect(0, 0, 15, 15);
			scrollbarConnector.graphics.endFill();
			addChild(scrollbarConnector);
			
			if (!showScrollBars)
			{
				verticalScrollBar.alpha = 0;
				horizontalScrollBar.alpha = 0;
			} 
			
			addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
		}
		
		private function updateScrollRect():void
		{
			itemContainer.scrollRect = new Rectangle(0, 0, this.width, this.height);
		}
		
		private function handleMouseWheel(event:MouseEvent):void
		{
			if (!completionManager || completionManager.isMouseOverList() == false)
				scrollTo(verticalScrollBar.scrollPosition - event.delta);
		}
		
		private function handleScroll(event:ScrollEvent):void 
		{
			invalidateFlag(INVALID_SCROLL);
		}
		
		private function getItemRenderers(howMany:int, beginningAtLine:int):Vector.<TextLineRenderer>
		{
			var ret:Vector.<TextLineRenderer> = new Vector.<TextLineRenderer>();
			for (var i:int = 0; i < howMany; i++)
			{
				var rdr:TextLineRenderer;
				if (model.itemRenderersFree.length > 0)
				{
					rdr = model.itemRenderersFree.pop();
				}
				else
				{ 
					rdr = new TextLineRenderer();
					rdr.lineNumberWidth = _lineNumberWidth;
					rdr.styles = colorManager.styles;
					rdr.cacheAsBitmap = true;
					
					//For masking Right panel
					/*var masker:Sprite = new Sprite();
					masker.graphics.beginFill(0XFFFFFF);
					masker.graphics.drawRect(0 , 0 , this.parentApplication.width+1000 , this.parent.height+1000);
					masker.graphics.endFill();
					masker.cacheAsBitmap = true;
					rdr.mask = masker;
					itemContainer.addChild(masker);*/
					itemContainer.addChild(rdr);
				}

				var beginningAtLinePlusIndex:int = beginningAtLine + i;
				rdr.model = model.lines[beginningAtLinePlusIndex];
				rdr.dataIndex = beginningAtLinePlusIndex;
				ret.push(rdr);
			}
			
			return ret;
		}
		
		private function freeItemRenderers(startIndex:int, howMany:int):void 
		{
			var toRemove:Vector.<TextLineRenderer> = model.itemRenderersInUse.splice(startIndex, howMany);
			for each (var rdr:TextLineRenderer in toRemove) 
			{
				rdr.x = -2000;
				rdr.y = -2000;
			}
			
			model.itemRenderersFree = model.itemRenderersFree.concat(toRemove);
		}
		
		private function freeRenderersAtTop(howMany:int):void 
		{
			freeItemRenderers(0, howMany);
		}
		
		private function freeRenderersAtBottom(howMany:int):void
		{
			freeItemRenderers(model.itemRenderersInUse.length-howMany, howMany);
		}
		
		private function clearAllRenderers():void 
		{
			freeItemRenderers(0, model.itemRenderersInUse.length);
		}

		private function updateDataProvider():void
		{
			clearAllRenderers();
			var needed:int = model.lines.length - model.scrollPosition;
			if (model.renderersNeeded < needed)
			{
				needed = model.renderersNeeded;
			}

			model.itemRenderersInUse = getItemRenderers(needed, model.scrollPosition);
			
			invalidateFlag(INVALID_LAYOUT);
			invalidateSelection(true);
			if (model.hasTraceSelection) invalidateTraceSelection();
		}
		
		private function updateSize():void
		{
			// TODO: Fix this to better consider the dependency of scrollbars
			// as showing/hiding one scrollbar can change the need for the other
			model.viewWidth = width - lineNumberWidth;
			model.viewHeight = height - (horizontalScrollBar.visible ? 15 : 0);
			model.renderersNeeded = Math.ceil(model.viewHeight / TextLineRenderer.lineHeight);
			
			if (model.renderersNeeded < model.itemRenderersInUse.length)
			{
				// Remove no-longer needed renderers
				var removed:Vector.<TextLineRenderer> = model.itemRenderersInUse.splice(model.renderersNeeded, model.itemRenderersInUse.length - model.renderersNeeded);
				
				for each (var rdr:TextLineRenderer in removed)
				{
					rdr.focus = false;
					rdr.parent.removeChild(rdr);
				}
				
				removed.length = 0;
				removed = null;
			}
			
			updateVerticalScrollbar();
			
			if (verticalScrollBar.visible) model.viewWidth -= 15;
			updateHorizontalScrollbar();
			
			updateScrollbarVisibility();
			
			itemContainer.graphics.clear();
			itemContainer.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			itemContainer.graphics.drawRect(0, 0, width, height);
			itemContainer.graphics.endFill();
			
			if (showLineNumbers)
			{
				// Calculate line-number gutter width according to line count
				lineNumberWidth = TextLineRenderer.charWidth*TextUtil.digitCount(model.lines.length)+8+10;
				
				itemContainer.graphics.beginFill(lineNumberBackgroundColor);
				itemContainer.graphics.drawRect(0, 0, _lineNumberWidth, height);
				itemContainer.graphics.endFill();
			}
		}
		
		private function updateVerticalScrollbar():void
		{
			var maxScroll:int = model.lines.length - model.renderersNeeded + 1;
			if (maxScroll < 0)
			{
				maxScroll = 0;
			}

			verticalScrollBar.maxScrollPosition = maxScroll;
			verticalScrollBar.pageSize = model.renderersNeeded;
			verticalScrollBar.visible = maxScroll > 0;
			
			if (verticalScrollBar.scrollPosition > maxScroll) {
				verticalScrollBar.scrollPosition = maxScroll;
				invalidateFlag(INVALID_SCROLL);
			}
		}
		
		private function updateHorizontalScrollbar():void
		{
			var maxScroll:int = model.textWidth - model.viewWidth + HORIZONTAL_LOOKAHEAD;
			if (maxScroll < 0)
			{
				maxScroll = 0;
			}

			horizontalScrollBar.maxScrollPosition = maxScroll;
			horizontalScrollBar.pageSize = model.viewWidth;
			horizontalScrollBar.visible = maxScroll > 0;
			
			if (horizontalScrollBar.scrollPosition > maxScroll)
			{
				horizontalScrollBar.scrollPosition = maxScroll;
				invalidateFlag(INVALID_SCROLL);
			}
		}
		
		private function updateScrollbarVisibility():void
		{
			// Scrollbar is centered on it's x (& 15px wide)
			verticalScrollBar.x = width-7;
			verticalScrollBar.height = height;
			
			horizontalScrollBar.y = height-7;
			horizontalScrollBar.width = width;
			
			if (horizontalScrollBar.visible && verticalScrollBar.visible)
			{
				verticalScrollBar.height -= 15;
				horizontalScrollBar.width -= 15;
				scrollbarConnector.x = width-15;
				scrollbarConnector.y = height-15;
				scrollbarConnector.visible = true;
			}
			else
			{
				scrollbarConnector.visible = false;
			}
		}
		
		private function updateHorizontalScroll():void
		{
			if (model.horizontalScrollPosition != horizontalScrollBar.scrollPosition)
			{
				model.horizontalScrollPosition = horizontalScrollBar.scrollPosition;
				
				invalidateFlag(INVALID_LAYOUT);
				invalidateSelection(true);
			}
		}
		
		private function updateVerticalScroll():void
		{
			var scrollDelta:int = verticalScrollBar.scrollPosition - model.scrollPosition;
			
			if (scrollDelta == 0) return;
			
			if (Math.abs(scrollDelta) >= model.renderersNeeded) 
			{
				model.scrollPosition = verticalScrollBar.scrollPosition;
				
				invalidateFlag(INVALID_FULL);
				return;
			}
			
			var bottomLine:int;
			var linesRemaining:int;
			var affectedLines:int;
			var newRenderers:Vector.<TextLineRenderer>;
			
			if (scrollDelta > 0) // Scroll down
			{
				bottomLine = model.scrollPosition + model.renderersNeeded;
				linesRemaining = model.lines.length - bottomLine;
				affectedLines = scrollDelta;
				if (linesRemaining < scrollDelta)
				{
					affectedLines = linesRemaining;
				}

				freeRenderersAtTop(scrollDelta);
				newRenderers = getItemRenderers(affectedLines, bottomLine);
				model.itemRenderersInUse = model.itemRenderersInUse.concat(newRenderers);
			}
			else // Scroll up
			{
				linesRemaining = model.scrollPosition;
				affectedLines = -scrollDelta;
				if (linesRemaining < affectedLines)
				{
					affectedLines = linesRemaining;
				}
				
				freeRenderersAtBottom(affectedLines);
				newRenderers = getItemRenderers(affectedLines, model.scrollPosition - affectedLines);
				model.itemRenderersInUse = newRenderers.concat(model.itemRenderersInUse);
				
				// Restore any unused lines to the bottom
				bottomLine = model.scrollPosition - affectedLines + model.itemRenderersInUse.length;
				linesRemaining = model.lines.length - bottomLine;

				affectedLines = model.renderersNeeded - model.itemRenderersInUse.length;
				if (linesRemaining < affectedLines)
				{
					affectedLines = linesRemaining;
				}

				if (affectedLines > 0)
				{
					newRenderers = getItemRenderers(affectedLines, bottomLine);
					model.itemRenderersInUse = model.itemRenderersInUse.concat(newRenderers);
				}
			}
			
			model.scrollPosition = verticalScrollBar.scrollPosition;
			
			invalidateFlag(INVALID_LAYOUT);
			invalidateSelection(true);
		}
		
		private function updateLayout():void
		{
			var yStart:int = 0;
			var rdr:TextLineRenderer;
            var itemRenderersInUseCount:int = model.itemRenderersInUse.length;

			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				rdr.y = yStart;
				rdr.x = 0;
				rdr.horizontalOffset = -model.horizontalScrollPosition;
				yStart += TextLineRenderer.lineHeight;
			}
			
			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT));
		}
		
		public function updateSelection():void
		{
			var rdr:TextLineRenderer;
            var itemRenderersInUseCount:int = model.itemRenderersInUse.length;

			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (i+model.scrollPosition == model.selectedLineIndex)
				{
					rdr.focus = hasFocus;
					rdr.caretPosition = model.caretIndex;
					rdr.drawSelection(model.selectionStartCharIndex, model.caretIndex);
				}
				else
				{
					rdr.focus = false;
					rdr.removeSelection();
				}
			}
		}
		
		public function updateAllInstancesOfASearchStringSelection():void
		{
			if (!model.allInstancesOfASearchStringDict) return;
			
			var rdr:TextLineRenderer;
			var itemRenderersInUseCount:int = model.itemRenderersInUse.length;
			
			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (model.allInstancesOfASearchStringDict[i+model.scrollPosition] != undefined)
				{
					rdr.drawAllInstanceOfASearchStringSelection(model.allInstancesOfASearchStringDict[i+model.scrollPosition]);
				}
				else
				{
					rdr.removeAllInstancesSelection();
				}
			}
		}
		
		public function updateTraceSelection():void
		{
			var rdr:TextLineRenderer;
            var itemRenderersInUseCount:int = model.itemRenderersInUse.length;

			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (i+model.scrollPosition == model.selectedTraceLineIndex)
				{
					if (DebugHighlightManager.LAST_DEBUG_LINE_OBJECT) DebugHighlightManager.LAST_DEBUG_LINE_OBJECT.debuggerLineSelection = false;
					DebugHighlightManager.LAST_DEBUG_LINE_OBJECT = rdr.model;
					DebugHighlightManager.LAST_DEBUG_LINE_RENDERER = rdr;
					
					//rdr.focus = hasFocus;
					rdr.caretTracePosition = model.caretTraceIndex;
					rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = true;
					//rdr.drawTraceSelection(model.selectionStartTraceCharIndex, model.caretTraceIndex);
				}
				else
				{
					//rdr.focus = false;
					rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = false;
					//rdr.removeTraceSelection();
				}
			}
		}
		
		public function removeTraceSelection():void
		{
			var rdr:TextLineRenderer;
            var itemRenderersInUseCount:int = model.itemRenderersInUse.length;
			
			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
				rdr.model.debuggerLineSelection = rdr.showTraceLines = rdr.traceFocus = false;
				//rdr.focus = false;
				rdr.removeTraceSelection();
			}
		}
		
		private function updateMultilineSelection():void
		{
			var rdr:TextLineRenderer;
			
			// If we are horiz-scrolling the selection might be wider than window width.
			// Makes sure selection is drawn all the way to the right edge when scrolling.
			var lineWidth:int = width + model.horizontalScrollPosition;
			var itemRenderersInUseCount:int = model.itemRenderersInUse.length;
			var scrollPosition:int = 0;
			for (var i:int = 0; i < itemRenderersInUseCount; i++)
			{
				rdr = model.itemRenderersInUse[i];
                scrollPosition = i + model.scrollPosition;
				
				if (scrollPosition == model.selectionStartLineIndex)
				{ // Beginning of selection (may be below or above current point)
					if (model.selectionStartLineIndex > model.selectedLineIndex)
					{
						rdr.drawSelection(0, model.selectionStartCharIndex);
					}
					else
					{
						rdr.drawFullLineSelection(lineWidth, model.selectionStartCharIndex);
					}
					rdr.focus = false;
				} 
				else if (scrollPosition == model.selectedLineIndex)
				{ // Selected line
					if (model.selectedLineIndex > model.selectionStartLineIndex)
					{
						rdr.drawSelection(0, model.caretIndex);
					}
					else
					{
						rdr.drawFullLineSelection(lineWidth, model.caretIndex);
					}
					rdr.caretPosition = model.caretIndex;
					rdr.focus = hasFocus;
				}
				else if (model.selectionStartLineIndex < scrollPosition
					&& model.selectedLineIndex > scrollPosition)
				{ // Start of selection is above current line
					rdr.drawFullLineSelection(lineWidth);
					rdr.focus = false;				  
				}
				else if (model.selectionStartLineIndex > scrollPosition
					&& model.selectedLineIndex < scrollPosition)
				{ // Start of selection is below current line
					rdr.drawFullLineSelection(lineWidth);
					rdr.focus = false;
				}
				else
				{ // No selection
					rdr.focus = false;
					rdr.removeSelection();
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Keep processing until no flags are on
			while (invalidFlags != 0)
			{
				// Get current invalid flags
				var curInvalidFlags:uint = invalidFlags;
				// Reset all invalidation flags
				invalidFlags = 0;
				if (checkFlag(INVALID_RESIZE, curInvalidFlags))
				{
					updateSize();
					updateScrollRect();
				}
				if (checkFlag(INVALID_WIDTH, curInvalidFlags))
				{
					var old:Boolean = horizontalScrollBar.visible;
					updateHorizontalScrollbar();
					
					if (old != horizontalScrollBar.visible) invalidateFlag(INVALID_RESIZE);
					else updateScrollRect();
				}
				if (checkFlag(INVALID_SCROLL, curInvalidFlags))
				{
					updateVerticalScroll();
					updateHorizontalScroll();
				}
				if (checkFlag(INVALID_FULL, curInvalidFlags))
				{
					updateDataProvider();
				}
				if (checkFlag(INVALID_SELECTION, curInvalidFlags))
				{
					if (model.hasMultilineSelection)
					{
						updateMultilineSelection();
					}
					else
					{
						updateSelection();
						updateAllInstancesOfASearchStringSelection();
					}
				}
				if (checkFlag(INVALID_TRACESELECTION, curInvalidFlags))
				{
					
					/*if(model.hasTraceSelection)
					{*/
						updateTraceSelection();
					//}
				}
				if (checkFlag(INVALID_LAYOUT, curInvalidFlags))
				{
					updateLayout();
				}
			}
		}
		
		private function invalidateFlag(flag:uint):void
		{
			if (invalidFlags == 0)
			{
				// Invalidate display list on the first flag invalidated, to get updateDisplayList to execute
				invalidateDisplayList();
			}
			invalidFlags |= flag;
		}

        private function canScroll(lineIndex:int, eventType:String):Boolean
        {
            if (eventType == null) return true;

            var hasTracedItem:Boolean = true;
            if (eventType == OpenFileEvent.TRACE_LINE)
            {
                hasTracedItem = isDebuggerLineVisible(lineIndex);
            }

            return hasTracedItem;
        }

        private function isDebuggerLineVisible(lineIndex:int):Boolean
        {
            return model.itemRenderersInUse.every(
                    function(item:TextLineRenderer, index:int, vector:Vector.<TextLineRenderer>):Boolean
                    {
                        return item.dataIndex != lineIndex || !item.model.traceLine;
                    });
        }

        private static function checkFlag(flag:uint, flags:uint):Boolean
        {
            return (flags & flag) > 0;
        }
    }
}