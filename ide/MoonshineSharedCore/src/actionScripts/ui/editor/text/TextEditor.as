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
    import actionScripts.events.OpenFileEvent;

    import flash.display.Sprite;
	import flash.events.FocusEvent;
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
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.vo.SearchResult;
	import actionScripts.ui.parser.ILineParser;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Location;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.SignatureHelp;
	
	
	
	
	/*
	Line-based text editor. Text rendering with Flash Text Engine. 
	DataProvider (String) is split up newline & each TextLineRenderer gets one line to render.
	Only what can be seen on screen is rendered & item-renderers are reused.
	
	This class handles scrolling & rendering, MVC style. 
	Different types of rendering can be triggered with various invalidateSomething() calls,
	upon which a flag will be set & when the frame exists rendering will happen (the Flex way).
	
	Managers handle non-rendering actions and affect TextEditorModel, which is the base for rendering.
	See EditManager, UndoManager, SelectionManager & ColorManager.
	
	WORK IN PROGRESS
	
	*/
	[Style(name="backgroundColor",type="uint",format="Color",inherit="no")]
	[Style(name="backgroundAlpha",type="Number",format="Number",inherit="no")]
	[Style(name="selectionColor",type="uint",format="Color",inherit="yes")]
	[Style(name="selectedLineColor",type="uint",format="Color",inherit="no")]
	[Style(name="selectedLineColorAlpha",type="Number",format="Number",inherit="no")]
	public class TextEditor extends UIComponent implements IFocusManagerComponent
	{	
		// Amount to look ahead when horiz-scrolling caret into view (8 characters)
		private static const HORIZONTAL_LOOKAHEAD:int = TextLineRenderer.charWidth*8;
		
		// Holds the text lines
		internal var itemContainer:UIComponent = new UIComponent();
		
		private var verticalScrollBar:ScrollBar;
		// The square connecting dual scrollbars
		private var scrollbarConnector:UIComponent;
		
		protected var lineHeight:int = TextLineRenderer.lineHeight;
		
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
		protected var editorToolTipManager:EditorToolTipManager;
		
		public var model:TextEditorModel;
		
		private var widthUpdateTime:int;
		private var widthUpdateDelay:int = 100;
		private var widthUpdateDelayer:Timer;
		
		// Style defaults
		private var _backgroundColor:uint = 			0xfdfdfd;
		private var _backgroundAlpha:uint = 			1;
		private var lineNumberBackgroundColor:uint = 	0xf9f9f9;
		private var _selectionColor:uint =				0xd1e3f9;
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
		// Getters/Setters
		public function get dataProvider():String
		{
			return model.lines.join(lineDelim); 
		}
		public function set dataProvider(v:String):void 
		{
			// Detect line ending (for saves)
			// TODO: take first found line encoding
			if (v.indexOf("\r\n")>-1) _lineDelim = "\r\n";
			else if (v.indexOf("\r")>-1) _lineDelim = "\r";
			else _lineDelim = "\n";
			
			// Split lines regardless of line encoding
			var lines:Array = v.split(/\r?\n|\r/);
			var count:int = lines.length;
			
			// Populate lines into model
			model.lines = new Vector.<TextLineModel>(count);
			
			for (var i:int = 0; i < count; i++)
			{
				model.lines[i] = new TextLineModel(lines[i]);
			}
			
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
			invalidateFlag(INVALID_RESIZE);
			invalidateFlag(INVALID_FULL);
		}
		
		private var _lineDelim:String = "\n";
		public function set lineDelim(v:String):void
		{
			_lineDelim = v;
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
		public function set lineNumberWidth(v:int):void
		{
			if (v != _lineNumberWidth)
			{
				var t:TextLineRenderer;
				
				// Update all item renderers since this value can happen when editing (999->1000, etc)
				for each (t in model.itemRenderersFree)
				{
					t.lineNumberWidth = v;
				}
				for each (t in model.itemRenderersInUse)
				{
					t.lineNumberWidth = v;
				}
				
				_lineNumberWidth = v;
				invalidateLines();
			}
		}
		
		private var _showScrollBars:Boolean = true;
		public function get showScrollBars():Boolean
		{
			return _showScrollBars;
		}
		public function set showScrollBars(v:Boolean):void
		{
			_showScrollBars = v;
			if (verticalScrollBar)
			{
				if (v) verticalScrollBar.alpha = horizontalScrollBar.alpha = 0;
				else verticalScrollBar.alpha = horizontalScrollBar.alpha = 1;
			} 
		}
		
		private var _showLineNumbers:Boolean = true;
		public function get showLineNumbers():Boolean
		{
			return _showLineNumbers;
		}
		public function set showLineNumbers(v:Boolean):void
		{
			_showLineNumbers = v;
			{
				lineNumberWidth = 0;	
			}
		}
		
		private var _hasFocus:Boolean = false;
		protected function get hasFocus():Boolean
		{
			return _hasFocus;
		}
		protected function set hasFocus(v:Boolean):void
		{
			_hasFocus = v;
			if(model.hasTraceSelection)
				invalidateTraceSelection(true);
			else
				invalidateSelection(true);
		}
		
		public function get hasChanged():Boolean
		{
			return undoManager.hasChanged;
		}
		
		public function save():void
		{
			// Enables undoManager.hasChanged
			undoManager.save();
		}

		public function get signatureHelpActive():Boolean
		{
			return signatureHelpManager.isActive;
		}
		
		// Hook in syntax parser & it's styles
		public function setParserAndStyles(parser:ILineParser, styles:Object):void
		{
			colorManager.setParser(parser);
			if (styles) 
			{
				if (!styles['selectedLineColor']) 		styles['selectedLineColor'] = _selectedLineColor;
				if (!styles['selectionColor']) 			styles['selectionColor'] = _selectionColor;
				if (!styles['selectedLineColorAlpha'])	styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
				
				colorManager.styles = styles;
				
				var t:TextLineRenderer;
				for each (t in model.itemRenderersFree)
				{
					t.styles = styles;
				}
				for each (t in model.itemRenderersInUse)
				{
					t.styles = styles;
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
			for (var i:int = 0; i < model.lines.length; i++)
			{
				var line:TextLineModel = model.lines[i];
				if (line.breakPoint) bps.push(i);
			}
			return bps;
		}
		public function set breakpoints(v:Array):void
		{
			_breakpoints = v; // if it exists when set dataProvider is called we re-populate & remove it.
			for (var i:int = 0; i < v.length; i++)
			{
				var lineNumber:int = v[i];
				if (lineNumber >= model.lines.length) return;
				var line:TextLineModel = model.lines[lineNumber];
				line.breakPoint = true;
			}
		}
		public function setCompletionData(begin:int, end:int, s:String, change:TextChangeInsert = null):void
		{
			editManager.setCompletionData(begin, end, s, change);
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
			colorManager.styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
			
			editManager = new EditManager(this, model, readOnly);
			
			if (!readOnly)
			{
				undoManager = new UndoManager(this, model);
				searchManager = new SearchManager(this, model);
				completionManager = new CompletionManager(this, model);
				signatureHelpManager = new SignatureHelpManager(this, model);
			}
			hoverManager = new HoverManager(this, model);
			gotoDefinitionManager = new GotoDefinitionManager(this, model);
			diagnosticsManager = new DiagnosticsManager(this, model);
			editorToolTipManager = new EditorToolTipManager(this, model);
			
			addEventListener(ChangeEvent.TEXT_CHANGE, handleChange, false, 1);
			addEventListener(LineEvent.COLOR_CHANGE, handleColorChange);
			addEventListener(LineEvent.WIDTH_CHANGE, handleWidthChange);
			
			addEventListener(ResizeEvent.RESIZE, handleResize);
		}
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			if (getStyle('backgroundColor') != null)
			{ 
				_backgroundColor = getStyle('backgroundColor');
				invalidateFlag(INVALID_RESIZE);
			}
			if (getStyle('backgroundAlpha') != null)
			{
				_backgroundAlpha = getStyle('backgroundAlpha');
				invalidateFlag(INVALID_RESIZE);
			}
			if (getStyle('selectionColor') != null) 
			{
				_selectionColor = getStyle('selectionColor');
				colorManager.styles['selectionColor'] = _selectionColor;
				invalidateSelection(true);
			}
			if (getStyle('selectedLineColor') != null)
			{
				_selectedLineColor = getStyle('selectedLineColor');
				colorManager.styles['selectedLineColor'] = _selectedLineColor;
				invalidateSelection(true);
			}
			if (getStyle('selectedLineColorAlpha') != null)
			{
				_selectedLineColorAlpha = getStyle('selectedLineColorAlpha');
				colorManager.styles['selectedLineColorAlpha'] = _selectedLineColorAlpha;
				invalidateSelection(true);
			}
			if (getStyle('tracingLineColor') != null)
			{
				_tracingLineColor = getStyle('tracingLineColor');
				colorManager.styles['tracingLineColor'] = _tracingLineColor;
				invalidateTraceSelection(true);
			}
		}
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
			hasFocus = true;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			
			//hasFocus = false;
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
				
				if (model.selectedLineIndex < verticalScrollBar.scrollPosition || model.renderersNeeded <= 2 && model.selectedLineIndex > verticalScrollBar.scrollPosition)
				{
					verticalScrollBar.scrollPosition = model.selectedLineIndex;
					invalidateFlag(INVALID_SCROLL);
				}
				else if (model.renderersNeeded > 2 && model.selectedLineIndex + 2 > verticalScrollBar.scrollPosition + model.renderersNeeded)
				{
					verticalScrollBar.scrollPosition = Math.max(model.selectedLineIndex-model.renderersNeeded+2, 0);
					invalidateFlag(INVALID_SCROLL);
				}
				if (caretPos < model.horizontalScrollPosition)
				{
					model.horizontalScrollPosition = horizontalScrollBar.scrollPosition = Math.max(caretPos - HORIZONTAL_LOOKAHEAD, 0);
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
				var selText:String = "";
				
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
				
				
				selText = model.lines[startLine].text.substr(start);
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
		
		public function getCaretIndex():int
		{
			return TextUtil.lineCharIdx2charIdx(dataProvider, model.selectedLineIndex, model.caretIndex, lineDelim);
		}
		
		public function getLineCharIndex():Point
		{
			return new Point( model.caretIndex,model.selectedLineIndex);
		}
		
		public function getLines():Vector.<String>
		{
			var lines:Vector.<String> = new Vector.<String>();
			var len:int = model.lines.length;
			for (var i:int = 0; i < len; i++)
			{
				lines[i] = model.lines[i].text;	
			}
			return lines;
		}
		
		private function handleTraceChange(event:ChangeEvent):void
		{
			// Any text change requires line invalidation
			invalidateLines();
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
				if (timeDiff < widthUpdateDelay) 
				{
					if (!widthUpdateDelayer.running) 
					{
						widthUpdateDelayer.delay = widthUpdateDelay-timeDiff;
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
			var lines:Vector.<TextLineModel> = model.lines;
			var max:Number = 0;
			for (var i:int = 0; i < lines.length; i++) 
			{
				var line:TextLineModel = lines[i];
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
			var charPoint:Point = rdr.localToGlobal(new Point(charBounds.x, charBounds.y));
			return charPoint;
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

            var verticalOffsetLineIndex:int = lineIndex;
			if (eventType ==  OpenFileEvent.TRACE_LINE)
			{
				verticalOffsetLineIndex = lineIndex - verticalScrollBar.pageSize / 2;
			}

			verticalScrollBar.scrollPosition = Math.min(Math.max(verticalOffsetLineIndex, verticalScrollBar.minScrollPosition), verticalScrollBar.maxScrollPosition);
			if (horizontalScrollBar.visible)
			{
				horizontalScrollBar.scrollPosition = Math.min(Math.max(x, horizontalScrollBar.minScrollPosition), horizontalScrollBar.maxScrollPosition);
			}
			invalidateFlag(INVALID_SCROLL);
		}

		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean):SearchResult
		{
			return searchManager.search(search, null, false, backwards);
		}
		
		// Search may be RegExp or String
		public function searchReplace(search:*, replace:String=null, all:Boolean=false):SearchResult
		{
			return searchManager.search(search, replace, all);
		}
		
		public function showCompletionList(items:Array):void
		{
			completionManager.showCompletionList(items);
		}

		public function showSignatureHelp(data:SignatureHelp):void
		{
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

		public function setTooltip(id:String, text:String):void
		{
			editorToolTipManager.setTooltip(id, text);
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
					var masker:Sprite = new Sprite();
					masker.graphics.beginFill(0XFFFFFF);
					masker.graphics.drawRect(0 , 0 , this.parentApplication.width+1000 , this.parent.height+1000);
					masker.graphics.endFill();
					masker.cacheAsBitmap = true;
					rdr.mask = masker;
					itemContainer.addChild(masker);
					itemContainer.addChild(rdr);
				}
				
				rdr.model = model.lines[beginningAtLine+i];
				rdr.dataIndex = beginningAtLine+i;
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
			var needed:int = Math.min(model.renderersNeeded, model.lines.length - model.scrollPosition);
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
			model.renderersNeeded = Math.ceil(model.viewHeight/lineHeight);
			
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
			var maxScroll:int = Math.max(model.lines.length - model.renderersNeeded + 1, 0);
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
			var maxScroll:int = Math.max(model.textWidth - model.viewWidth + HORIZONTAL_LOOKAHEAD, 0);
			horizontalScrollBar.maxScrollPosition = maxScroll;
			horizontalScrollBar.pageSize = model.viewWidth;
			horizontalScrollBar.visible = maxScroll > 0;
			
			if (horizontalScrollBar.scrollPosition > maxScroll) {
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
				affectedLines = Math.min(scrollDelta, linesRemaining);
				
				freeRenderersAtTop(scrollDelta);
				newRenderers = getItemRenderers(affectedLines, bottomLine);
				model.itemRenderersInUse = model.itemRenderersInUse.concat(newRenderers);
			}
			else // Scroll up
			{
				linesRemaining = model.scrollPosition;
				affectedLines = Math.min(-scrollDelta, linesRemaining);
				
				freeRenderersAtBottom(affectedLines);
				newRenderers = getItemRenderers(affectedLines, model.scrollPosition - affectedLines);
				model.itemRenderersInUse = newRenderers.concat(model.itemRenderersInUse);
				
				// Restore any unused lines to the bottom
				bottomLine = model.scrollPosition - affectedLines + model.itemRenderersInUse.length;
				linesRemaining = model.lines.length - bottomLine;
				affectedLines = Math.min(model.renderersNeeded - model.itemRenderersInUse.length, linesRemaining);
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
			for (var i:int = 0; i < model.itemRenderersInUse.length; i++)
			{
				rdr = model.itemRenderersInUse[i];
				rdr.y = yStart;
				rdr.x = 0;
				rdr.horizontalOffset = -model.horizontalScrollPosition;
				yStart += lineHeight;
			}
			
			dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT));
		}
		
		public function updateSelection():void
		{
			var rdr:TextLineRenderer;
			
			for (var i:int = 0; i < model.itemRenderersInUse.length; i++)
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
		
		public function updateTraceSelection():void
		{
			var rdr:TextLineRenderer;
			
			for (var i:int = 0; i < model.itemRenderersInUse.length; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (i+model.scrollPosition == model.selectedTraceLineIndex)
				{
					if (DebugHighlightManager.LAST_DEBUG_LINE_OBJECT) DebugHighlightManager.LAST_DEBUG_LINE_OBJECT.debuggerLineSelection = false;
					DebugHighlightManager.LAST_DEBUG_LINE_OBJECT = rdr.model;
					DebugHighlightManager.LAST_DEBUG_LINE_RENDERER = rdr;
					
					//rdr.focus = hasFocus;
					rdr.caretTracePosition = model.caretTraceIndex;
					rdr.showTraceLines = true;
					rdr.traceFocus = true;
					//rdr.drawTraceSelection(model.selectionStartTraceCharIndex, model.caretTraceIndex);
				}
				else
				{
					//rdr.focus = false;
					rdr.showTraceLines = false;
					rdr.traceFocus = false;
					//rdr.removeTraceSelection();
				}
			}
		}
		
		public function removeTraceSelection():void
		{
			var rdr:TextLineRenderer;
			for (var i:int = 0; i < model.itemRenderersInUse.length; i++)
			{
				rdr = model.itemRenderersInUse[i];
				rdr.traceFocus = false;
				//rdr.focus = false;
				rdr.showTraceLines = false;
				rdr.removeTraceSelection();
			}
		}
		
		private function updateMultilineSelection():void
		{
			var rdr:TextLineRenderer;
			
			// If we are horiz-scrolling the selection might be wider than window width.
			// Makes sure selection is drawn all the way to the right edge when scrolling.
			var lineWidth:int = width + model.horizontalScrollPosition;
			
			for (var i:int = 0; i < model.itemRenderersInUse.length; i++)
			{
				rdr = model.itemRenderersInUse[i];
				if (i+model.scrollPosition == model.selectionStartLineIndex) 
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
				else if (i+model.scrollPosition == model.selectedLineIndex)
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
				else if (model.selectionStartLineIndex < i+model.scrollPosition 
					&& model.selectedLineIndex > i+model.scrollPosition)
				{ // Start of selection is above current line
					rdr.drawFullLineSelection(lineWidth);
					rdr.focus = false;				  
				}
				else if (model.selectionStartLineIndex > i+model.scrollPosition
					&& model.selectedLineIndex < i+model.scrollPosition)
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
				}
				if (checkFlag(INVALID_WIDTH, curInvalidFlags))
				{
					var old:Boolean = horizontalScrollBar.visible;
					updateHorizontalScrollbar();
					
					if (old != horizontalScrollBar.visible) invalidateFlag(INVALID_RESIZE);
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
		
		private function checkFlag(flag:uint, flags:uint):Boolean
		{
			return (flags & flag) > 0;
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
                        return item.dataIndex != lineIndex && !item.model.traceLine;
                    });
        }
    }
}