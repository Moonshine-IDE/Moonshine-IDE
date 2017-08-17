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
package actionScripts.ui.menu
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	import mx.containers.Canvas;
	
	import spark.components.HGroup;
	
	import actionScripts.ui.menu.interfaces.ICustomMenu;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.ui.menu.renderers.MenuBarItemRenderer;
	
	public class MenuBar extends Canvas
	{

		private var _menu:ICustomMenu;
		private var needsRedrawing:Boolean = false;

		private var menuLookup:Dictionary = new Dictionary(true);

		private var bar:HGroup;
		private var lastActiveMenuBarItem:MenuBarItemRenderer;

		private var background:Sprite;
		private var model:MenuModel;

		public function MenuBar()
		{
			super();

			createMenuModelInContext()
		}

		private function createMenuModelInContext():void
		{
			model = new MenuModel(this);
			model.addEventListener("topMenuClosed", modelTopMenuClosedHandler);
			model.addEventListener(MenuModelEvent.ACTIVE_ALL_MENUS, activeAllMenusHandler);
		}


		private function activeAllMenusHandler(e:MenuModelEvent):void
		{

		}

		private function modelTopMenuClosedHandler(e:Event):void
		{

			if (!lastActiveMenuBarItem)
				return;
			lastActiveMenuBarItem.active = false;
			// Check to see if mouse is still over last bar item and if so reselect it
			if (lastActiveMenuBarItem.hitTestPoint(mouseX, mouseY))
				lastActiveMenuBarItem.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
			lastActiveMenuBarItem = null;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			percentWidth = 100;
			height = 21;

			bar = new HGroup();
			bar.setStyle("left", 0);

			bar.percentWidth = 100;
			bar.mouseChildren = true;

			bar.gap = 0;

			addChild(bar);
		}

		public function set menu(value:ICustomMenu):void
		{
			_menu = value;
			needsRedrawing = true;
			invalidateDisplayList();
		}
		
		public function get menu():ICustomMenu
		{
			return _menu;
		}

		private function drawMenuState():void
		{
			var barItem:MenuBarItemRenderer
			var items:Vector.<ICustomMenuItem> = _menu.items;
			for each (var item:ICustomMenuItem in items)
			{
				barItem = new MenuBarItemRenderer();
				menuLookup[item.label] = item;
				barItem.text = item.label;
				barItem.addEventListener(MouseEvent.MOUSE_DOWN, barItemOpenMenu, false, Number.MAX_VALUE, true);
				barItem.addEventListener(MouseEvent.ROLL_OVER, barItemOpenMenu, false, Number.MAX_VALUE, true);

				//barItem.menu = item;
				bar.addElement(barItem);
			}

			needsRedrawing = false;
		}

		public function get numOfRenderers():int
		{
			return _menu.items.length;
		}

		public function getRendererAt(index:int):MenuBarItemRenderer
		{
			return MenuBarItemRenderer(bar.getElementAt(index));
		}

		public function displayMenuAt(index:int):void
		{
			var barItem:MenuBarItemRenderer= getRendererAt(index);
			var item:ICustomMenuItem = menuLookup[barItem.text] as ICustomMenuItem;
			if (!item || !item.data)
				return;

			var menuItems:Vector.<ICustomMenuItem> =  (item.data as ICustomMenu)
				? (item.data as ICustomMenu).items : null;

			if (!menuItems || !menuItems.length)
				return;

			if (lastActiveMenuBarItem)
				lastActiveMenuBarItem.active = false;
			barItem.active = true;
			lastActiveMenuBarItem = barItem;
			model.displayMenu(barItem, (item.data as ICustomMenu).items);
		}

		private function barItemOpenMenu(e:Event):void
		{
			if (e.type == MouseEvent.ROLL_OVER && !model.isOpen())
				return;

			var barItem:MenuBarItemRenderer = e.target as MenuBarItemRenderer;
			// Menu is open but we must also check to see if the current menu items are the same,
			// if so we will skip opening the window otherwise we will close it due to the toggle statement
			// in _model.displayMenu

			if (e.type == MouseEvent.ROLL_OVER && lastActiveMenuBarItem == barItem)
				return;

			displayMenuAt(bar.getElementIndex(barItem));
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);

			graphics.clear()
			graphics.beginGradientFill("linear", [0xebeff7, 0xCACBCD], [1, 1], [64, 255], mtr)
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();

			graphics.lineStyle(1);
			graphics.moveTo(0, unscaledHeight - 1);
			graphics.lineTo(unscaledWidth, unscaledHeight - 1);

			if (needsRedrawing)
			{
				drawMenuState();
			}
		}
	}
}