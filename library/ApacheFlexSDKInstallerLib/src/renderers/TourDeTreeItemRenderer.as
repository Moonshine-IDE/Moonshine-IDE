////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package renderers
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	
	import spark.components.Label;
	import spark.components.TextInput;
	
	use namespace mx_internal;
	
	public class TourDeTreeItemRenderer extends TreeItemRenderer
	{
		private var label2:Label;
		private var editText:TextInput;
		
		private var isOpenIcon:Sprite;
		private var hitareaSprite:Sprite;
		private var sourceControlBackground:UIComponent;
		private var sourceControlText:Label;
		private var sourceControlSystem:Label;
		
		public function TourDeTreeItemRenderer()
		{
			super();
		}
		
		private function onActiveEditorChange(event:Event):void
		{
			invalidateDisplayList();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			isOpenIcon.visible = false;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			isOpenIcon = new Sprite();
			isOpenIcon.mouseEnabled = false;
			isOpenIcon.mouseChildren = false;
			isOpenIcon.graphics.clear();
			isOpenIcon.graphics.beginFill(0xe15fd5);
			isOpenIcon.graphics.drawCircle(1, 7, 2);
			isOpenIcon.graphics.endFill();
			isOpenIcon.visible = false;
			var glow:GlowFilter = new GlowFilter(0xff00e4, .4, 6, 6, 2);
			isOpenIcon.filters = [glow];
			addChild(isOpenIcon);
			
			hitareaSprite = new Sprite();
			hitArea = hitareaSprite;
			addChild(hitareaSprite);
		}
		
		override mx_internal function createLabel(childIndex:int):void
	    {
	        super.createLabel(childIndex);
	        label.visible = false;
	        
	        if (!label2)
			{	
				label2 = new Label();
				label2.mouseEnabled = false;
				label2.mouseChildren = false;
				label2.styleName = 'uiText';
				label2.setStyle('fontSize', 12);
				label2.setStyle('color', 0xe0e0e0);
				label2.maxDisplayedLines = 1;
				
				if (childIndex == -1) 
					addChild(label2);
				else 
					addChildAt(label2, childIndex);
			}
	    }
		
	    override mx_internal function removeLabel():void
	    {
	    	super.removeLabel();
	    	
	        if (label2 != null)
	        {
	            removeChild(label2);
	            label2 = null;
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
        	
        	// Draw our own FTE label
        	label2.width = label.width;
        	label2.height = label.height;
			label2.x = label.x;
        	label2.y = label.y+5;
        	
        	label2.text = label.text;
        	if (label) label.visible = false;
		}
		
	}
}