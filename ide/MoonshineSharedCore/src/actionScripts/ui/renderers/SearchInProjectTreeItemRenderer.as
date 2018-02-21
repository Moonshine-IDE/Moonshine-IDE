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
package actionScripts.ui.renderers
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    import flash.text.engine.TextLine;
    
    import mx.binding.utils.ChangeWatcher;
    import mx.controls.treeClasses.TreeItemRenderer;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.ToolTipEvent;
    
    import spark.components.Label;
    
    import actionScripts.locator.IDEModel;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.Settings;
    
    import no.doomsday.utilities.math.MathUtils;

	use namespace mx_internal;
	
	public class SearchInProjectTreeItemRenderer extends TreeItemRenderer
	{
		private var model:IDEModel;
		private var hitareaSprite:Sprite;
		private var sourceControlBackground:UIComponent;
		private var sourceControlText:Label;
		private var sourceControlSystem:Label;
		private var isTooltipListenerAdded:Boolean;
		private var lineHighligter:Sprite;
		private var textLine:TextLine;
		private var textBlock:TextBlock;
		private var lineNumberTextBlock:TextBlock;
		private var lineNumberText:TextLine;
		private var lineNumberTextElement:TextElement;

		public function SearchInProjectTreeItemRenderer()
		{
			super();
			model = IDEModel.getInstance();
			ChangeWatcher.watch(model, 'activeEditor', onActiveEditorChange);
			
			textBlock = new TextBlock();
			lineNumberTextBlock = new TextBlock();
			lineNumberTextElement = new TextElement();
			lineNumberTextBlock.content = lineNumberTextElement;
		}
		
		private function onActiveEditorChange(event:Event):void
		{
			invalidateDisplayList();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			drawLineNumber();
			drawText();
			
			if (!isTooltipListenerAdded)
			{
				addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
				addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);
				isTooltipListenerAdded = true;
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			sourceControlBackground = new UIComponent();
			sourceControlBackground.mouseEnabled = false;
			sourceControlBackground.mouseChildren = false;
			sourceControlBackground.visible = false;
			sourceControlBackground.graphics.beginFill(0x484848, .9);
			sourceControlBackground.graphics.drawRect(0, -2, 30, 17);
			sourceControlBackground.graphics.endFill();
			sourceControlBackground.graphics.lineStyle(1, 0x0, .3);
			sourceControlBackground.graphics.moveTo(-1, -2);
			sourceControlBackground.graphics.lineTo(-1, 16);
			sourceControlBackground.graphics.lineStyle(1, 0xEEEEEE, .1);
			sourceControlBackground.graphics.moveTo(0, -2);
			sourceControlBackground.graphics.lineTo(0, 16);
			addChild(sourceControlBackground);
			
			// For drawing SVN/GIT/HG/CVS etc
			sourceControlSystem = new Label();
			sourceControlSystem.width = 30;
			sourceControlSystem.height = 16;
			sourceControlSystem.mouseEnabled = false;
			sourceControlSystem.mouseChildren = false;
			sourceControlSystem.styleName = 'uiText';
			sourceControlSystem.setStyle('fontSize', 10);
			sourceControlSystem.setStyle('color', 0xe0e0e0);
			sourceControlSystem.setStyle('textAlign', 'center');
			sourceControlSystem.setStyle('paddingTop', 3);
			sourceControlSystem.maxDisplayedLines = 1;
			sourceControlSystem.visible = false;
			addChild(sourceControlSystem);
			
			// For displaying source control status
			sourceControlText = new Label();
			sourceControlText.width = 20;
			sourceControlText.height = 16;
			sourceControlText.mouseEnabled = false;
			sourceControlText.mouseChildren = false;
			sourceControlText.styleName = 'uiText';
			sourceControlText.setStyle('fontSize', 9);
			sourceControlText.setStyle('color', 0xcdcdcd);
			sourceControlText.setStyle('textAlign', 'center');
			sourceControlText.setStyle('paddingTop', 3);
			sourceControlText.maxDisplayedLines = 1;
			sourceControlText.visible = false;
			addChild(sourceControlText);
			
			hitareaSprite = new Sprite();
			hitArea = hitareaSprite;
			addChild(hitareaSprite);
		}
		
		private function drawLineNumber():void
		{
			if (data.isShowAsLineNumber)
			{
				//var style:ElementFormat = (model.breakPoint) ? styles['breakPointLineNumber'] : styles['lineNumber'];
				//style = (model.traceLine) ? styles['tracingLineColor'] : styles['lineNumber'];
				lineNumberTextElement.elementFormat = new ElementFormat(Settings.font.uiFontDescription, 12, 0x999999);
				lineNumberTextElement.text = data.lineNumbersWithRange[0].startLineIndex + 1; // moonshine manage by 0th index, but in UI we need to show 1
				var newLineNumberText:TextLine = null;
				if(lineNumberText)
				{
					//try to reuse the existing TextLine, if it exists already
					newLineNumberText = lineNumberTextBlock.recreateTextLine(lineNumberText, null, 40);
				}
				else
				{
					newLineNumberText = lineNumberTextBlock.createTextLine(null, 40);
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
				}
			}
			else if (lineNumberText)
			{
				removeChild(lineNumberText);
				lineNumberText = null;
			}
		}
		
		private function getSearchLabel():String
		{
			if (data.isRoot)  return data.name +"     ("+data.file.nativePath+")";
			if (data.isShowAsLineNumber) return (data.lineText);
			else if (data.file && (data.searchCount != 0)) return data.name +" ("+data.searchCount +" matches)";
			return (data.name);
		}
		
		private function drawText():void
		{
			var groupElement:GroupElement = new GroupElement();
			var contentElements:Vector.<ContentElement> = new Vector.<ContentElement>();
			var newTextLine:TextLine = null;
			var newTextLineNumber:TextLine = null;
			
			contentElements.push(new TextElement(getSearchLabel(), new ElementFormat(Settings.font.uiFontDescription, 12, 0xe0e0e0)));
			groupElement.setElements(contentElements);
			textBlock.content = groupElement;
			
			if (textLine)
			{
				//try to reuse the existing TextLine, if it exists already
				newTextLine = textBlock.recreateTextLine(textLine);
				newTextLine.doubleClickEnabled = true;
			}
			else
			{
				newTextLine = textBlock.createTextLine();
				lineHighligter = new Sprite();
				if (newTextLine)
				{
					textLine = newTextLine;
					textLine.mouseEnabled = false;
					textLine.mouseChildren = false;
					textLine.cacheAsBitmap = true;
					
					if (labelIndex == -1)
					{
						addChild(lineHighligter);
						addChild(textLine);
					}
					else
					{
						addChildAt(lineHighligter, labelIndex);
						addChildAt(textLine, labelIndex+1);
					}
				}
				
			}
			if (textLine && !newTextLine)
			{
				removeChild(textLine);
				textLine = null;
			}
			if (textLine) 
			{
				textLine.x = label.x;
				textLine.y = 12;
			}
		}
		
		private var labelIndex:int;
		override mx_internal function createLabel(childIndex:int):void
	    {
	        super.createLabel(childIndex);
	        label.visible = false;
			labelIndex = childIndex;
	    }
		
	    override mx_internal function removeLabel():void
	    {
	    	super.removeLabel();
			
			if (textLine)
			{
				removeChild(textLine);
				textLine = null;
				textBlock = null;
			}
			if (lineNumberText)
			{
				removeChild(lineNumberText);
				lineNumberText = null;
				lineNumberTextBlock = null;
			}
	    }
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    	{
        	super.updateDisplayList(unscaledWidth, unscaledHeight);
        	
        	hitareaSprite.graphics.clear();
        	hitareaSprite.graphics.beginFill(0x0, 0);
        	hitareaSprite.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        	hitareaSprite.graphics.endFill();
        	hitArea = hitareaSprite;
			
			// to be used in 'search in projects' 
			if (data.isShowAsLineNumber && textLine)
			{
				if (lineNumberText)
				{
					lineNumberText.x = (label.x + 2);
					textLine.x = lineHighligter.x = (label.x + 44);
				}
				
				var g:Graphics = lineHighligter.graphics;
				g.clear();
				g.lineStyle(1, 0xcccccc);
				g.beginFill(0xff7cff, 0);
				
				for each(var i:Object in data.lineNumbersWithRange)
				{
					try	{ getSelectionRange(i.startCharIndex, i.endCharIndex); } catch (e:Error) {	break;	}
				}
				
				g.endFill();
				
				/*
				 * @local
				 */
				function getSelectionRange(start:int, end:int):void
				{
					if (start == end || start < 0) 
					{
						lineHighligter.graphics.clear();
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
					
					g.drawRect(selStart, 0, selWidth, height);
				}
			}
			else if (textLine)
			{
				textLine.x = lineHighligter.x = (label.x + 2);
				lineHighligter.graphics.clear();
			}
        	
        	if (label) label.visible = false;
        	if (data)
			{
	        	// Update source control status
	        	sourceControlSystem.visible = false;
	        	sourceControlText.visible = false;
	        	sourceControlBackground.visible = false;
	        	
	        	if (data.sourceController)
	        	{
	        		if (data.isRoot)
	        		{
		        		// Show source control system name (SVN/CVS/HG/GIT)
		        		sourceControlSystem.text = FileWrapper(data).sourceController.systemNameShort; 
		        		
		        		sourceControlBackground.visible = true;
		        		sourceControlSystem.visible = true;
		        		
		        		sourceControlBackground.x = unscaledWidth-30;
		        		sourceControlSystem.x = sourceControlBackground.x;
						sourceControlSystem.y = textLine.y;
	        		}
	        		else
	        		{
	        			/*var st:String = data.sourceController.getStatus(data.nativePath);
		        		if (st)
		        		{*/
		        			sourceControlText.text = data.name;
		        			sourceControlBackground.visible = true;
		        			sourceControlText.visible = true;
		        			
		        			sourceControlBackground.x = unscaledWidth-30;
		        			sourceControlText.x = sourceControlBackground.x;
							sourceControlText.y = textLine.y;
		        		//}	
	        		}
	        	}
			}
		}
	}
}