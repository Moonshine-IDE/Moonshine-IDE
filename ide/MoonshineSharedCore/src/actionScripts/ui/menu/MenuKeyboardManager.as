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
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import actionScripts.ui.menu.renderers.MenuItemRenderer;
	import actionScripts.ui.menu.renderers.MenuRenderer;

	public class MenuKeyboardManager
	{
		private var model:MenuModel

		private static const UP:uint = 1 << 0;
		private static const DOWN:uint = 1 << 1;
		private static const LEFT:uint = 1 << 2;
		private static const RIGHT:uint = 1 << 3;


		private var activeTopLevelMenu:MenuRenderer;

		private var activeMenuItemRenderer:MenuItemRenderer;

		private var activeMenu:MenuRenderer

		private var selectFirstSubMenuItem:Boolean;

		private var activeMenus:Vector.<MenuRenderer> = new Vector.<MenuRenderer>();

		public function MenuKeyboardManager(model:MenuModel)
		{
			this.model = model;
		}

		private function reset():void
		{
			activeMenus.length = 0;
			activeMenuItemRenderer = null;
			selectFirstSubMenuItem = false;
		}

		public function manage(stage:DisplayObject):void
		{
			stage.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			model.addEventListener(MenuModelEvent.TOP_LEVEL_MENU_CHANGED, topLevelMenuChangedHandler);
			model.addEventListener(MenuModelEvent.MENU_OPENED, menuOpenedHandler);
			model.addEventListener(MenuModelEvent.MENU_CLOSED, menuClosedHandler);
			model.addEventListener(MenuModelEvent.ACTIVE_MENU_ITEM_RENDERER_CHANGED, activeMenuItemChangedHandler);
		}

		private function menuClosedHandler(e:MenuModelEvent):void
		{
			var index:int = activeMenus.indexOf(e.menu);
			if (index > -1)
				activeMenus.splice(index, 1);
		}

		private function menuOpenedHandler(e:MenuModelEvent):void
		{

			activeMenu = e.menu;
			if (activeMenus.indexOf(activeMenu) == -1)
				activeMenus.push(activeMenu);
			if (selectFirstSubMenuItem) // if we previous requested to open a submenu via RIGHT
			{

				activeMenuItemRenderer = null;


				navigate(Keyboard.DOWN);
				selectFirstSubMenuItem = false;
			}
		}

		private function topLevelMenuChangedHandler(e:MenuModelEvent):void
		{
			activeMenu = activeTopLevelMenu = e.menu;
			reset();
			activeMenus.push(activeTopLevelMenu);

		}

		private function activeMenuItemChangedHandler(e:MenuModelEvent):void
		{
			/*deactiveRenderer(activeMenuItemRenderer)*/

			activeMenuItemRenderer = e.renderer

			activeMenu = e.menu; // current menu assoicated with renderer
			if (activeMenus.indexOf(activeMenu) == -1)
				activeMenus.push(activeMenu);



		}

		private function keyUpHandler(e:KeyboardEvent):void
		{
			if (!activeMenu)
				return;
			switch (e.keyCode)
			{
				case Keyboard.UP:
				case Keyboard.DOWN:
				case Keyboard.LEFT:
				case Keyboard.RIGHT:
					navigate(e.keyCode);
					break;

			}
		}


		private function getNextOrPreviousIndex(current:int, direction:int, max:int):int
		{

			current += direction;
			if (current >= max)
				current = 0;
			if (current < 0)
				current = max - 1;
			return current;
		}


		private function findRendererAtIndex(menu:MenuRenderer, direction:uint, currentIndex:int):MenuItemRenderer
		{
			var rdr:MenuItemRenderer
			var numOfRenderers:int = menu.numOfRenderers;
			trace("findRendererAtIndex", numOfRenderers, currentIndex);
			do
			{
				currentIndex = getNextOrPreviousIndex(currentIndex, direction == Keyboard.DOWN ? 1 : -1, numOfRenderers);
				trace("after findRendererAtIndex", currentIndex);
				try
				{
					rdr = menu.getRendererAt(currentIndex);
				}
				catch (e:Error)
				{
					return null;
				}
			} while (rdr.separator);
			return rdr;
		}

		private function navigate(direction:uint):void
		{
			var numOfRenderers:int = activeMenu.numOfRenderers;
			var currentIndex:int = -1;

			var relatedObject:InteractiveObject

			if (activeMenuItemRenderer)
			{
				try
				{
					currentIndex = activeMenu.getRendererIndex(activeMenuItemRenderer)
				}
				catch (e:Error)
				{
				}
			}

			var rdr:MenuItemRenderer
			if (direction == Keyboard.DOWN || direction == Keyboard.UP)
			{
				trace("Moving:", direction == Keyboard.DOWN ? "down" : "up")
				rdr = findRendererAtIndex(activeMenu, direction, currentIndex)
				//if (!rdr)
				//rdr = activeMenu.getRendererAt(0);
				// we need to mimc the relatedObject depending on the direction we are traveling			
				if (currentIndex != -1)
					relatedObject = findRendererAtIndex(activeMenu, direction == Keyboard.DOWN ?
						Keyboard.UP : Keyboard.DOWN, activeMenu.getRendererIndex(rdr));

				if (activeMenuItemRenderer)
					activeMenuItemRenderer.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT,
						true, false, NaN, NaN, relatedObject));

				if (rdr)
					rdr.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER));
				trace(rdr);

			}
			else if (direction == Keyboard.LEFT || direction == Keyboard.RIGHT)
			{
				if (direction == Keyboard.RIGHT)
				{
					if (activeMenuItemRenderer
						&& activeMenuItemRenderer.submenu)
					{

						// we dispatch the down even again, this will in most cases, already have the submenu open,
						// but we do this so we can get the instance of that menu
						// A flag is set which will denote that we need to move to the first entry in the submenu
						// upon MENU_CHANGED
						selectFirstSubMenuItem = true;
						activeMenuItemRenderer.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));

						return;
					}
				}
				else
				{
					var index:int = activeMenus.indexOf(activeMenu) - 1;
					if (index < 0)
						return;
					if (activeMenuItemRenderer)
					{
						model.cleanUpAfterMenuItemRenderer(activeMenuItemRenderer);
					}
					model.cleanUpAfterMenu(activeMenu);
					/*if (model.previousMenuItemRenderer)
					   {
					   model.previousMenuItemRenderer.dispatchEvent(new MouseEvent(
					   MouseEvent.ROLL_OUT,false,false,NaN,NaN,activeMenu));
					 }*/
					activeMenu = activeMenus[index];
					navigate(Keyboard.DOWN);

				}

			}








		}

		private function activateRenderer(rdr:MenuItemRenderer):void
		{
			if (rdr)
			{

				if (rdr.data && rdr.data.hasSubmenu())
					rdr.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}

		private function deactiveRenderer(rdr:MenuItemRenderer, relatedObject:InteractiveObject=null):void
		{
			if (rdr)
			{


			}
		}
	}


}