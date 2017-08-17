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
package actionScripts.ui.menu.renderers
{
	import actionScripts.ui.menu.MenuModel;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.utils.moonshine_internal;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;

	public class MenuRenderer extends Canvas
	{
		private var needsRedrawing:Boolean = false;
		private var background:Shape
		private var itemContainer:VBox
		private var needsShadow:Boolean
		private var needsRendererLayout:Boolean = false;
		private var startTime:Number;

		public function MenuRenderer()
		{
			super();
		}

		override protected function createChildren():void
		{
			super.createChildren();

			itemContainer = new VBox();
			itemContainer.setStyle("paddingTop", 3);
			itemContainer.setStyle("paddingBottom", 3);
			itemContainer.setStyle("verticalGap", 0);
			itemContainer.setStyle("backgroundColor", 0xf0f0f0);

			// TODO : Add an extra comp to offset the dropshadow a bit
			itemContainer.filters = [new DropShadowFilter(5, 55, 0x979797, .22, 5, 5)];
			itemContainer.setStyle("borderStyle", "solid");
			itemContainer.setStyle("borderColor", 0x979797);
			itemContainer.setStyle("borderThickeness", 0);

			addChild(itemContainer);
		}

		private var _model:MenuModel;

		public function set model(v:MenuModel):void
		{
			_model = v;
		}

		private var _items:Vector.<ICustomMenuItem>

		public function set items(v:Vector.<ICustomMenuItem>):void
		{
			if (v == null)
				v = new Vector.<ICustomMenuItem>();
			_items = v;

			needsRedrawing = true;
			invalidateProperties();
		}

		public function get items():Vector.<ICustomMenuItem>
		{
			return _items;
		}

		public function clear():void
		{
			_model.freeMenuItemRenderer(itemContainer, 0);
		}

		public function get numOfRenderers():int
		{
			return _items.length;
		}

		public function getRendererAt(index:int):MenuItemRenderer
		{
			return itemContainer.getChildAt(index) as MenuItemRenderer;
		}

		public function getRendererIndex(rdr:MenuItemRenderer):int
		{
			return itemContainer.getChildIndex(rdr);
		}
		
		private function setTooTip(label:String):String
		{
			for each(var c:Object in ConstantsCoreVO.MENU_TOOLTIP)
			{
				if(label == c.label)
				{
					return c.tooltip;
				}
			}
			return null;
		}
		
		private function drawMenuState():void
		{
			var renderer:MenuItemRenderer;
			var numOfItems:int = _items.length;

			startTime = getTimer();
			var tmpRenderers:Vector.<MenuItemRenderer> = _model.getMenuItemRenderers(numOfItems);
			trace("Get Menu Item Renderers 1", getTimer() - startTime);
			var currMenuItem:ICustomMenuItem

			for (var i:int = 0; i < numOfItems; i++)
			{
				renderer = tmpRenderers[i];

				currMenuItem = _items[i];

				renderer.shortcut = (currMenuItem.shortcut) ? currMenuItem.shortcut.toString() : null;
				renderer.data = currMenuItem;
				renderer.separator = currMenuItem.isSeparator;
				renderer.submenu = currMenuItem.submenu ? true : false;
				renderer.label = currMenuItem.label;
				renderer.tooltip = setTooTip(currMenuItem.label);
				itemContainer.addChildAt(renderer, i);
			}

			

			if (itemContainer.numChildren > numOfItems)
			{
				_model.freeMenuItemRenderer(itemContainer, numOfItems);
			}


			
			needsRendererLayout = true;
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (needsRedrawing)
			{
				drawMenuState();
				needsRedrawing = false;

			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// add an hit area to add a hit buffer of 5px in any direction
			if (!hitArea)
			{
				hitArea = new Sprite();
				hitArea.mouseEnabled = false;
				rawChildren.addChild(hitArea)
			}
			hitArea.graphics.clear();
			hitArea.graphics.beginFill(0xFF0000, 0);
			hitArea.graphics.drawRect(-5, -5, unscaledWidth + 5, unscaledHeight + 5);
			hitArea.graphics.endFill();
			if (itemContainer && needsRendererLayout)
			{

				needsRendererLayout = false;
				var rdr:MenuItemRenderer
				var containerNumOfChildren:int = itemContainer.numChildren;

				var maxRendererLabelWidth:Number = 0;
				var maxRendererShortcutLabelWidth:Number = 0;
				var currentWidth:Number

				var hasShortcut:Boolean = false;
				const defaultShortcutWidth:Number = 50;



				use namespace moonshine_internal;
				var layoutTime:Number = getTimer();
				
				for (var i:int = 0; i < containerNumOfChildren; i++)
				{
					rdr = itemContainer.getChildAt(i) as MenuItemRenderer;

					if (rdr.shortcut)
						hasShortcut = true;

					currentWidth = rdr.getLabelWidth();
					if (currentWidth > maxRendererLabelWidth)
						maxRendererLabelWidth = currentWidth;

					currentWidth = rdr.getShortcutLabelWidth();

					if (currentWidth > maxRendererShortcutLabelWidth)
						maxRendererShortcutLabelWidth = currentWidth;


				}
				if (!hasShortcut)
				{
					maxRendererShortcutLabelWidth = 5;
				}
				else if (maxRendererShortcutLabelWidth < defaultShortcutWidth && hasShortcut)
				{
					maxRendererShortcutLabelWidth = defaultShortcutWidth;
				}




				for (i = 0; i < containerNumOfChildren; i++)
				{
					rdr = itemContainer.getChildAt(i) as MenuItemRenderer;
					rdr.resizeLabels(maxRendererLabelWidth, maxRendererShortcutLabelWidth);

				}
				

			}


		}


	}
}