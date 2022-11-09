////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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