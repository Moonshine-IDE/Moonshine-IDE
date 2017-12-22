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
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TabAlignment;
	import flash.text.engine.TabStop;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.Timer;

	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Settings;

    import no.doomsday.utilities.math.MathUtils;


    public class TextLineRenderer extends Sprite
	{	
		// TODO: These need to derive from the font metrics
		public static var lineHeight:int = 16;
		public static var charWidth:Number = 7.82666015625;
		
		private static var numTabstops:int = 100;
		private static var tabStops:Vector.<TabStop>;
		
		classInit(); // Do static init once & once only.
		static private function classInit():void {
			tabStops = new Vector.<TabStop>(numTabstops);
			var charWidthWithTabWidth:Number = charWidth * Settings.font.tabWidth;
			for (var i:int = 0; i < numTabstops; i++) {
				tabStops[i] = new TabStop(TabAlignment.START, Math.round((i+1) * charWidthWithTabWidth));
			}
		}
		
		public var styles:Object; 
		public var lineNumberWidth:int;
		
		private var textBlock:TextBlock;
		private var textLine:TextLine;
		
		private var lineNumberTextBlock:TextBlock;
		private var lineNumberTextElement:TextElement;
		private var lineNumberText:TextLine;
		private var lineNumberBackground:Sprite;
		
		private var marker:Sprite;
		private var markerBlinkTimer:Timer;
		private var lastMarkerPosition:Number;
		private var diagnosticsShape:Shape;
		
		private var selection:Sprite;
		private var traceSelection:Sprite;
		private var lineSelection:Sprite;
		
		private var _dataIndex:int;
		public function get dataIndex():int
		{
			return _dataIndex;
		}
		public function set dataIndex(v:int):void
		{
			_dataIndex = v;
			
			drawLineNumber();
		}
		
		private var _model:TextLineModel;
		public function get model():TextLineModel
		{
			return _model;
		}
		public function set model(value:TextLineModel):void
		{
			focus = false;
			
			_model = value;
			drawText();
			traceFocus = _model.debuggerLineSelection;
		}
		
		private var _horizontalOffset:int = 0;
		public function get horizontalOffset():int
		{
			return _horizontalOffset;
		}
		public function set horizontalOffset(value:int):void
		{
			_horizontalOffset = value;
			if (textLine) textLine.x = lineNumberWidth + _horizontalOffset;
			if (diagnosticsShape) diagnosticsShape.x = lineNumberWidth + _horizontalOffset;
			selection.x = lineNumberWidth + _horizontalOffset;
			drawMarkerAtPosition(lastMarkerPosition, 0);
		}

		private var _caretPosition:int;

		public function set caretPosition(value:int):void
		{
			_caretPosition = value;
			drawCaret(value);
		}
		
		private var _caretTracePosition:int;

		public function set caretTracePosition(value:int):void
		{
			_caretTracePosition = value;
			drawCaret(value);
		}
		
		private var _showTraceLines:Boolean;

		public function set showTraceLines(value:Boolean):void
		{
			_showTraceLines = value;
			_model.debuggerLineSelection = value;
		}

		private var _focus:Boolean;

		public function get focus():Boolean
		{
			return _focus;
		}

		public function set focus(value:Boolean):void
		{
			_focus = value;
			var g:Graphics = lineSelection.graphics;
			g.clear();
			if (value)
			{
				markerBlinkTimer.start();
				marker.visible = true;
				g.beginFill(styles['selectedLineColor'],styles['selectedLineColorAlpha']);
				g.drawRect(lineNumberWidth, 0, 2000, lineHeight); 
				g.endFill();
			}
			else
			{
				g.clear();	
				markerBlinkTimer.reset();
				marker.visible = false;
			}
		}

		private var _traceFocus:Boolean = false;

		public function set traceFocus(value:Boolean):void
		{
			_traceFocus = value;
			var g:Graphics = traceSelection.graphics;
			g.clear();
			if(value)
			{
				g.beginFill(styles['tracingLineColor'], styles['selectedLineColorAlpha']);
				g.drawRect(lineNumberWidth, 0, 2000, lineHeight); 
				g.endFill();
			}
		}

		public function TextLineRenderer()
		{
			super();
			init();
		}

		private function init():void 
		{
			textBlock = new TextBlock();
			textBlock.tabStops = tabStops;

			lineNumberTextBlock = new TextBlock();
			lineNumberTextElement = new TextElement();
			lineNumberTextBlock.content = lineNumberTextElement;
			
			lineSelection = new Sprite();
			addChild(lineSelection);
			
			selection = new Sprite();
			addChild(selection);

			traceSelection = new Sprite();
			addChild(traceSelection);

			marker = new Sprite();
			marker.graphics.beginFill(0x0, 0.5);
			marker.graphics.drawRect(0, 0, 3, lineHeight);
			marker.graphics.endFill();
			addChild(marker);
			
			markerBlinkTimer = new Timer(600);
			markerBlinkTimer.addEventListener(TimerEvent.TIMER, markerBlink);

			diagnosticsShape = new Shape();
			addChild(diagnosticsShape);
			
			lineNumberBackground = new Sprite();
			addChild(lineNumberBackground);
		}
		
		public function drawCaret(beforeCharAtIndex:int):void
		{
			var bounds:Rectangle;
			var markerPos:Number = 0;
			
			if (beforeCharAtIndex == 0)
			{
				// Draw on empty line
			}
			else if (beforeCharAtIndex >= model.text.length)
			{
				bounds = textLine.getAtomBounds(model.text.length-1);
				markerPos = bounds.x+bounds.width;
			}
			else
			{
				bounds = textLine.getAtomBounds(beforeCharAtIndex);
				markerPos = bounds.x;
			}
			
			lastMarkerPosition = markerPos;
			drawMarkerAtPosition(markerPos, 0);
		}
		
		public function drawSelection(start:int, end:int):void
		{
			if (start == end || start < 0) 
			{
				removeSelection();
				return;	
			}
			if (start > end)
			{
				var tmp:int = start;
				start = end;
				end = tmp;
			}
		
			var selStart:int = Math.floor(textLine.getAtomBounds(start).x);
			var endBounds:Rectangle = textLine.getAtomBounds(end-1);
			var selWidth:int = MathUtils.ceil(endBounds.x + endBounds.width) - selStart;
			
			drawSelectionRect(selStart, selWidth);
		}
		public function drawTraceSelection(start:int, end:int):void
		{
			/*if (start == end || start < 0) 
			{
			trace(start +"   "+end);
			removeTraceSelection();
			return;	
			}*/
			if (start > end)
			{
				var tmp:int = start;
				start = end;
				end = tmp;
				var selStart:int = Math.floor(textLine.getAtomBounds(start).x);
				var endBounds:Rectangle = textLine.getAtomBounds(end-1);
				var selWidth:int = MathUtils.ceil(endBounds.x + endBounds.width) - selStart;
				drawTraceSelectionRect(selStart, selWidth);
			}
			
		}
		public function drawFullLineSelection(lineWidth:int, startAtChar:int=0):void
		{
			var start_x:int = 0;
			if (startAtChar > 0)
			{
				start_x = textLine.getAtomBounds(Math.min(startAtChar, model.text.length) - 1).right;
			}
			
			drawSelectionRect(start_x, lineWidth-start_x);
		}
		
		public function removeSelection():void
		{
			selection.graphics.clear();
		}
		public function removeTraceSelection():void
		{
			traceSelection.graphics.clear();
		}
		
		public function getCharIndexFromPoint(globalX:int, returnNextAfterCenter:Boolean=true):int
		{
			var localPoint:Point = this.globalToLocal(new Point(globalX,0));
			var localPointX:Number = localPoint.x;
			var modelTextLength:int = model.text.length;
			
			if (modelTextLength == 0)
			{
				return localPointX >= lineNumberWidth ? 0 : -1;
			}
			else if (localPointX >= textLine.x + textLine.width) // After text
			{
				return modelTextLength;
			}
			else
			{
				// Get a line through the middle of the text field for y
				var mid:Point = this.localToGlobal(new Point(0, lineHeight/2));
				var atomIndexAtPoint:int = textLine.getAtomIndexAtPoint(globalX, mid.y);
				
				if (atomIndexAtPoint > -1 && returnNextAfterCenter)
				{
					var bounds:Rectangle = textLine.getAtomBounds(atomIndexAtPoint);
					var center:Number = lineNumberWidth + bounds.x + bounds.width/2;
					// If point falls after the center of the character, move to next one
					if (localPointX >= center) atomIndexAtPoint++;
				}
				
				return atomIndexAtPoint;
			}
		}
		
		// Will give you the char bounds, or if charIdx is out-of-bounds, the lines xy, or the last chars right-side xy
		// Uses the renderers height instead of the chars height
		public function getCharBounds(charIndex:int):Rectangle
		{
			var addCharWidth:Boolean;
            var modelTextLength:int = model.text.length;

			// Sanity checks
			if (charIndex >= modelTextLength)
			{
				charIndex = modelTextLength - 1;
				addCharWidth = true;
			}
			if (charIndex < 0)
			{
				return new Rectangle(lineNumberWidth, 0, 0, lineHeight);
			}
			
			if (charIndex == textLine.atomCount) charIndex--;
			var bounds:Rectangle = textLine.getAtomBounds(charIndex);
			bounds.x += lineNumberWidth;
			
			if (addCharWidth)
			{
				bounds.x += bounds.width;
				bounds.width = 0;
			}
			
			// The renders size is what we want to use
			bounds.y = 0;
			bounds.height = lineHeight;
			
			return bounds;	
		}
		
		public function drawText():void
		{
			var text:String = model.text;
			var meta:Vector.<int> = model.meta;
			var groupElement:GroupElement = new GroupElement();
			var contentElements:Vector.<ContentElement> = new Vector.<ContentElement>();
			
			if (meta)
			{
				var style:int, start:int, end:int;
				var metaCount:int = meta.length;
				var textLength:int = text.length;
				
				for (var i:int = 0; i < metaCount; i+=2)
				{
					start = meta[i];
					var plusTwoLine:int = i + 2;
					end = (plusTwoLine < metaCount) ? meta[plusTwoLine] : textLength;
					style = meta[i+1];
					var textElement:TextElement = new TextElement(text.substring(start, end), styles[style]);
					contentElements.push(textElement);
				}
			} 
			else
			{
				contentElements.push( new TextElement(text, styles[0]) );
			}
			
			groupElement.setElements(contentElements);

			var contentElementsCount:int = contentElements.length;
			if (contentElementsCount >= 2 && contentElements[contentElementsCount-2].elementFormat.color == 0xca2323)
			{
				var textToElement:String = contentElements[contentElementsCount-2].text;
				var textToElementLength:int = textToElement.length;
				var startChar:String = textToElement.charAt(0);
				model.isQuoteTextOpen = textToElementLength == 1 || textToElement.charAt(textToElementLength - 1) != startChar;
				model.lastQuoteText = startChar;
			}
			
			textBlock.content = groupElement;

			var newTextLine:TextLine = null;
			if(textLine)
			{
				//try to reuse the existing TextLine, if it exists already
				newTextLine = textBlock.recreateTextLine(textLine);
			}
			else
			{
				newTextLine = textBlock.createTextLine();
				if(newTextLine)
				{
					textLine = newTextLine;
					textLine.mouseEnabled = false;
					textLine.cacheAsBitmap = true;
					addChildAt(textLine, this.getChildIndex(selection) + 2);
				}
				
			}
			if(textLine && !newTextLine)
			{
				removeChild(textLine);
				textLine = null;
			}
			
			if (textLine) 
			{
				textLine.x = lineNumberWidth + horizontalOffset;
				textLine.y = 12;
			}
			drawDiagnostics();
		 }
		
		private function drawDiagnostics():void
		{
			diagnosticsShape.graphics.clear();
			if(!textLine)
			{
				return;
			}
			var stepLength:int = 2;
			diagnosticsShape.x = textLine.x;
			diagnosticsShape.y = textLine.y;
			var diagnostics:Vector.<Diagnostic> = model.diagnostics;
            var diagnosticsCount:int = diagnostics.length;
			if(diagnostics && diagnosticsCount > 0)
			{
				for(var i:int = 0; i < diagnosticsCount; i++)
				{
					var diagnostic:Diagnostic = diagnostics[i];
					if(diagnostic.severity == Diagnostic.SEVERITY_HINT)
					{
						//skip hints because they are not meant to be displayed
						//to the user like regular problems. they're used
						//internally by the language server or the editor for
						//other types of things, such as code actions.
						continue;
					}
					var startChar:int = diagnostic.range.start.character;
					var endChar:int = diagnostic.range.end.character;
					var maxChar:int = textLine.rawTextLength - 1;
					if(startChar > maxChar)
					{
						startChar = maxChar;
					}
					if(endChar > maxChar)
					{
						endChar = maxChar;
					}
					var startBounds:Rectangle = textLine.getAtomBounds(startChar);
					var endBounds:Rectangle = textLine.getAtomBounds(endChar);
					var lineColor:uint = 0xfa0707; //error
					switch(diagnostic.severity)
					{
						case Diagnostic.SEVERITY_WARNING:
						{
							lineColor = 0x078a07;
							break;
						}
						case Diagnostic.SEVERITY_HINT:
						case Diagnostic.SEVERITY_INFORMATION:
						{
							lineColor = 0x0707fa;
							break;
						}
					}
					diagnosticsShape.graphics.lineStyle(1, lineColor, .65);
					diagnosticsShape.graphics.moveTo(startBounds.x, 0);
					var upDirection:Boolean = false;
					var offset:int = 0;
					var startBoundsOffset:int = 0;
					var lineLength:Number = endBounds.x + endBounds.width - startBounds.x;
					while(offset <= lineLength)
					{
						offset = offset + stepLength;
                        startBoundsOffset = startBounds.x + offset;
						
						if (upDirection)
						{
							diagnosticsShape.graphics.lineTo(startBoundsOffset, 0);
						}
						else
						{
							diagnosticsShape.graphics.lineTo(startBoundsOffset, stepLength);
						}
						upDirection = !upDirection;
					}
				}
			}
		}
		
		private function drawLineNumber():void
		{
			if (lineNumberWidth > 0)
			{
				lineNumberBackground.graphics.clear();

				if (model.breakPoint)
				{
					trace("breakpoint ? "+dataIndex);
					lineNumberBackground.graphics.beginFill(styles['breakPointBackground']);
					lineNumberBackground.graphics.drawRect(0, 0, lineNumberWidth, lineHeight);
					lineNumberBackground.graphics.endFill();
				}
				else
				{
					lineNumberBackground.graphics.beginFill(0xf9f9f9);
					lineNumberBackground.graphics.drawRect(0, 0, lineNumberWidth, lineHeight);
					lineNumberBackground.graphics.endFill();
				}
				
				var style:ElementFormat = (model.breakPoint) ? styles['breakPointLineNumber'] : styles['lineNumber'];
				//style = (model.traceLine) ? styles['tracingLineColor'] : styles['lineNumber'];
				lineNumberTextElement.elementFormat = style;
				lineNumberTextElement.text = (_dataIndex+1).toString();
				var newLineNumberText:TextLine = null;
				if(lineNumberText)
				{
					//try to reuse the existing TextLine, if it exists already
					newLineNumberText = lineNumberTextBlock.recreateTextLine(lineNumberText, null, lineNumberWidth);
				}
				else
				{
					newLineNumberText = lineNumberTextBlock.createTextLine(null, lineNumberWidth);
					if(newLineNumberText)
					{
						lineNumberText = newLineNumberText;
						lineNumberText.mouseEnabled = false;
						lineNumberText.mouseChildren = false;
						addChild(lineNumberText);
					}
				}
				if (lineNumberText && !newLineNumberText)
				{
					removeChild(lineNumberText);
					lineNumberText = null;
				}
				
				if (lineNumberText) 
				{
					lineNumberText.y = 12;
					lineNumberText.x = lineNumberWidth-lineNumberText.width-3;
				}
			}
			else if (lineNumberText)
			{
				removeChild(lineNumberText);
				lineNumberText = null;
			}
		}
		
		private function drawSelectionRect(x:int, w:int):void
		{
			var g:Graphics = selection.graphics;
			g.clear();
			g.beginFill(styles['selectionColor'],styles['selectedLineColorAlpha']);
			g.drawRect(x, 0, w, lineHeight);
			g.endFill();
		}
		
		private function drawTraceSelectionRect(x:int, w:int):void
		{
			var g:Graphics = traceSelection.graphics;
			g.clear();
			g.beginFill(styles['tracingLineColor'], styles['selectedLineColorAlpha']);
			g.drawRect(x, 0, w, lineHeight);
			g.endFill();
			
		}
		private function drawMarkerAtPosition(x:int, y:int):void
		{
			x += lineNumberWidth + _horizontalOffset;
			marker.x = x;
			marker.y = y;
			
			if (focus)
			{
				markerBlinkTimer.reset();
				markerBlinkTimer.start();
				marker.visible = true;
			}
		}
		
		private function markerBlink(event:TimerEvent):void
		{
			marker.visible = !marker.visible;
		}
		
	}
}