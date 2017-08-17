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
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.MenuEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.ui.menu.renderers.MenuItemRenderer;
	import actionScripts.ui.menu.renderers.MenuRenderer;


	public class MenuModel extends EventDispatcher
	{
		private var freeMenuItemRenderers:Vector.<MenuItemRenderer> = new Vector.<MenuItemRenderer>();

		private var freeMenuOrSubMenus:Vector.<MenuRenderer> = new Vector.<MenuRenderer>();

		private var hysteresisTimer:Timer;

		// Bi-Directional Hash Of open menus
		private var activeMenuRepo:MenuRepo = new MenuRepo();

		private var _menuBar:MenuBar;

		private var stage:DisplayObject;

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

		// Current MenuItemRenderer in scope, this will be used after the the renderer has been
		// in over state for 300ms
		internal var activeMenuItemRenderer:MenuItemRenderer

		internal var previousMenuItemRenderer:MenuItemRenderer

		internal var topLevelMenu:MenuRenderer

		private const AUTO_CLICK_DELAY:int = 200;

		// helper flag used to suppress the stage MouseEvent.CLICK listener
		// when MenuItemRenderer is clicked
		private var supressMouseClick:Boolean = false;



		private var keyboardManager:MenuKeyboardManager;


		private function setTopLevelMenu(value:MenuRenderer):void
		{
			if (topLevelMenu == value)
				return;
			topLevelMenu = value;
			dispatchEvent(new MenuModelEvent(MenuModelEvent.TOP_LEVEL_MENU_CHANGED,
				false, false, value));

		}


		public function get bar():MenuBar
		{
			return _menuBar;
		}


		public function MenuModel(menuBar:MenuBar)
		{

			_menuBar = menuBar;

			var hook:Function = function(e:Event):void
				{
					_menuBar.removeEventListener(Event.ADDED_TO_STAGE, hook);
					stage = _menuBar.stage;
					init();

				}
			_menuBar.addEventListener(Event.ADDED_TO_STAGE, hook);


			hysteresisTimer = new Timer(AUTO_CLICK_DELAY, 0);
			hysteresisTimer.addEventListener(TimerEvent.TIMER, timerHysteresisHandler);
		}

		private function init():void
		{
			stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
			keyboardManager = new MenuKeyboardManager(this);
			keyboardManager.manage(stage);

		}

		private function deactivateHandler(e:Event):void
		{
			destroy();
		}




		public function isOpen():Boolean
		{
			return topLevelMenu != null;
		}

		public function get menuItems():Vector.<ICustomMenuItem>
		{
			return topLevelMenu ? topLevelMenu.items : null;
		}



		/**
		 * Release unused menuItemRenders
		 * @param	container
		 * @param	startIndex
		 */
		public function freeMenuItemRenderer(container:DisplayObjectContainer, startIndex:int):void
		{
			var toRemove:Vector.<MenuItemRenderer> = new Vector.<MenuItemRenderer>();
			var renderer:MenuItemRenderer
			while (container.numChildren > startIndex)
			{
				renderer = container.getChildAt(startIndex) as MenuItemRenderer

				if (!renderer)
					continue;
				toRemove.push(renderer);
			}

			freeMenuItemRenderers = freeMenuItemRenderers.concat(toRemove);
		}

		/**
		 * Get new MenuItemRenderers
		 * @param	howMany
		 * @return
		 */
		public function getMenuItemRenderers(howMany:int):Vector.<MenuItemRenderer>
		{
			var rtn:Vector.<MenuItemRenderer> = new Vector.<MenuItemRenderer>();

			var rdr:MenuItemRenderer
			for (var i:int = 0; i < howMany; i++)
			{
				if (freeMenuItemRenderers.length > 0)
				{
					rdr = freeMenuItemRenderers.pop();
				}
				else
				{
					rdr = new MenuItemRenderer();
					rdr.model = this;
					rdr.addEventListener(MouseEvent.ROLL_OVER, menuItemRenderRollOverHandler);
					rdr.addEventListener(MouseEvent.ROLL_OUT, menuItemRenderRollOutHandler);
					rdr.addEventListener(MouseEvent.MOUSE_DOWN, menuItemRenderClickHandler);
				}
				rtn.push(rdr);
			}
			return rtn;
		}

		public function displayMenu(base:DisplayObjectContainer, menuItems:Vector.<ICustomMenuItem>):MenuRenderer
		{

			if (topLevelMenu)
			{
				// menuItems will never be null so we can do a direct lookup to see if request is from same topmenu
				var isSameTopLevelMenu:Boolean = (topLevelMenu.items == menuItems);

				// If its the same menu we will notify the close so we can deactive the "highlight" in MenuBarView
				destroy(isSameTopLevelMenu);

				// if open request is from same menu which is already open we will skip opening a new request , thus toggling window to close
				if (isSameTopLevelMenu)
					return null;

			}
			var menu:MenuRenderer = positionMenu(menuItems, base, new Point(base.x, base.y + base.height));
			setTopLevelMenu(menu);
			return menu;
		}

		public function displaySubmenu(menu:MenuRenderer, base:DisplayObjectContainer, menuItems:Vector.<ICustomMenuItem>):MenuRenderer
		{

			hysteresisTimer.reset();
			var submenu:MenuRenderer
			if (activeMenuRepo.hasObjectAsBase(menu))
			{
				submenu = activeMenuRepo.getMenu(menu);;

			}
			else
			{

				submenu = positionMenu(menuItems, menu, new Point(base.width - 5, base.y));
				menu.addChild(submenu);
			}
			// Since we are using the Flex framework we need to delay this event on frame till all models are added,
			// Maybe we should move this to the MenuRenderer ??
			submenu.callLater(delayMenuOpenEvent, [submenu])
			return submenu;

		}

		private function delayMenuOpenEvent(menu:MenuRenderer):void
		{
			dispatchEvent(new MenuModelEvent(MenuModelEvent.MENU_OPENED,
				false, false, menu));
		}

		private function dispatchMenuEvent(menuItem:ICustomMenuItem):void
		{

			if (menuItem.data && menuItem.data.event)
			{
				var data:Object = menuItem.data;

				dispatcher.dispatchEvent(new MenuEvent(data.event, false, false, data.eventData));

			}
			else if (menuItem.shortcut && menuItem.shortcut.event)
			{
				dispatcher.dispatchEvent(new Event(menuItem.shortcut.event));
			}


		}


		private function positionMenu(menuItems:Vector.<ICustomMenuItem>, base:DisplayObjectContainer, position:Point):MenuRenderer
		{
			var menu:MenuRenderer = getMenuOrSubMenu()
			menu.items = menuItems;
			menu.x = position.x
			menu.y = position.y


			if (topLevelMenu == null)
			{ // request is to open up top menu
				PopUpManager.addPopUp(menu, IDEModel.getInstance().mainView);
				registerForMouseClicks(true);
			}

			activeMenuRepo.add(base, menu);
			return menu;
		}


		// Will allow use to listen to outside menu clicks to close the active menu
		private function registerForMouseClicks(setup:Boolean):void
		{

			// Mimic callLater, 
			//if someone can figure out the right combo of useCapture for stage/MenuBarView events you win a prize
			// TODO : Fix case were onEnterFrame is called twice when closing the currently active topLevelMenu
			var onEnterFrame:Function = function(e:Event):void
				{

					stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					if (setup)
					{
						// CLICK instead of MOUSE_DOWN to allow setting of suppressMouseClick flag when item is clicked otherwise
						// stageMouseClickHandler will ALWAYS destory topLevelMenu
						stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseClickHandler);
					}
					else
					{

						stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseClickHandler);
					}

				}

			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		}

		private function stageMouseClickHandler(e:MouseEvent):void
		{

			if (!topLevelMenu)
				return;
			e.stopImmediatePropagation();
			e.preventDefault();


			if (!supressMouseClick)
			{
				var notifyEvent:Boolean = !topLevelMenu.hitTestPoint(e.localX, e.localX);
				destroy(notifyEvent);
			}
			supressMouseClick = false;
		}

		private function destroy(notify:Boolean=true):void
		{
			registerForMouseClicks(false);
			cleanUpAfterMenu(topLevelMenu);
			setTopLevelMenu(null)
			cancelHysteresisTimer();
			previousMenuItemRenderer = null;
			supressMouseClick = false;
			if (notify)
				dispatchEvent(new Event("topMenuClosed"));
		}


		internal function cleanUpAfterMenu(menu:MenuRenderer):void
		{

			if (!menu || !activeMenuRepo.hasObjectAsMenu(menu))
				return;

			// TODO : use a MenuChain to speed up checking for open windows
			if (activeMenuRepo.hasObjectAsBase(menu)) // clean up open windows
			{
				cleanUpAfterMenu(activeMenuRepo.getMenu(menu));

			}
			if (menu == topLevelMenu)
				PopUpManager.removePopUp(menu);

			if (menu.parent) // completely remove it from its parnet, fixes dropshadow bug o_0
				menu.parent.removeChild(menu);
			freeMenuOrSubMenu(menu);
			activeMenuRepo.clear(menu) // clear instance in repo
			dispatchEvent(new MenuModelEvent(MenuModelEvent.MENU_CLOSED,
				false, false, menu));
			menu = null;

		}


		private function getMenuOrSubMenu():MenuRenderer
		{
			var menu:MenuRenderer
			if (freeMenuItemRenderers.length > 0)
			{
				menu = freeMenuOrSubMenus.pop();
			}
			else
			{
				menu = new MenuRenderer();
				menu.model = this;

			}
			return menu;
		}


		private function rescursiveFindMenu(base:Object):MenuRenderer
		{

			while (!(base is MenuRenderer) && base && base.parent)
			{
				base = base.parent;
			}
			return base as MenuRenderer;

		}

		private function freeMenuOrSubMenu(menu:MenuRenderer):void
		{
			menu.x = -2000;
			menu.y = -2000;
			menu.items = null;
			freeMenuOrSubMenus.push(menu);
		}


		private var lastActiveRendererForSubMenu:MenuItemRenderer

		private function displaySubMenuForRenderer(rdr:MenuItemRenderer):void
		{
			var rendererMenu:MenuRenderer = rescursiveFindMenu(rdr);
			if (!rendererMenu)
				return;
			if (lastActiveRendererForSubMenu)
				lastActiveRendererForSubMenu.explictActive = false;

			lastActiveRendererForSubMenu = rdr;
			lastActiveRendererForSubMenu.explictActive = true;
			displaySubmenu(rendererMenu, rdr, rdr.data.submenu.items);

		}

		private function menuItemRenderRollOverHandler(e:MouseEvent):void
		{
			var rdr:MenuItemRenderer = e.target as MenuItemRenderer;
			// Keyboard navigation will have localX and localY set to NaN

			registerActiveMenuItemRenderer(rdr, !isNaN(e.localX));

		}

		private function menuItemRenderClickHandler(e:MouseEvent):void
		{
			var rdr:MenuItemRenderer = e.target as MenuItemRenderer;

			if (!rdr)
				return;
			cancelHysteresisTimer(); // go ahead and stop the autotimer passing null to clean up previous 

			var currMenuItem:ICustomMenuItem = rdr.data as ICustomMenuItem;
			if (!currMenuItem)
				return;


			var canDispatch:Boolean = currMenuItem.hasShortcut() || currMenuItem.hasSubmenu() || (currMenuItem.data && currMenuItem.data);


			if (canDispatch)
			{
				// set suppress flag to stop stage listenering from destorying topLevelMenu
				supressMouseClick = true;
			}
			if (currMenuItem.hasSubmenu())
			{
				displaySubMenuForRenderer(rdr);

			}
			else if (canDispatch && currMenuItem.enabled)
			{
				destroy();
				dispatchMenuEvent(currMenuItem);

			}


		}

		private function menuItemRenderRollOutHandler(e:MouseEvent):void
		{
			var rdr:MenuItemRenderer = e.target as MenuItemRenderer;

			/*if (!rdr || !rdr.data || !rdr.data.hasSubmenu()) // if not a submenu then dont worry about it
			 return;*/



			var relatedObject:DisplayObject = e.relatedObject as DisplayObject

			trace(relatedObject);
			if (!relatedObject)
				return;
			// if we are moving down/up to a new menuItemRenderer in the same menu,
			// If we are moving to the newly created submenu then this object will be of another type
			if (!(relatedObject is MenuItemRenderer))
			{

				if (!previousMenuItemRenderer &&
					(relatedObject is MenuRenderer || relatedObject.parent is MenuRenderer))
					setPreviousRenderer(rdr);

				return;
			}
			else if (hasSubMenu(rdr))
			{
				cleanUpAfterMenuItemRenderer(rdr)
			}
			else
			{
				setPreviousRenderer(rdr);
			}



		}

		private function hasSubMenu(rdr:MenuItemRenderer):Boolean
		{
			return rdr && rdr.data && rdr.data.hasSubmenu();
		}

		private function registerActiveMenuItemRenderer(rdr:MenuItemRenderer, timer:Boolean=true):void
		{


			cancelHysteresisTimer();
			/*if (hasSubMenu(activeMenuItemRenderer))
			 activeMenuItemRenderer.explictActive = false;*/

			activeMenuItemRenderer = rdr;
			if (activeMenuItemRenderer == previousMenuItemRenderer)
				previousMenuItemRenderer = null

			dispatchEvent(new MenuModelEvent(MenuModelEvent.ACTIVE_MENU_ITEM_RENDERER_CHANGED,
				false, false, rescursiveFindMenu(rdr), rdr));


			if (hasSubMenu(rdr) && timer) // only need to auto open on submenu
				hysteresisTimer.start();

		}

		private function cancelHysteresisTimer():void
		{
			activeMenuItemRenderer = null;
			hysteresisTimer.reset();

		}

		private function setPreviousRenderer(rdr:MenuItemRenderer):void
		{
			trace("setPreviousRenderer", rdr == previousMenuItemRenderer, rdr == activeMenuItemRenderer);
			if (rdr == previousMenuItemRenderer || rdr == activeMenuItemRenderer)
				return;
			//if (hasSubMenu(rdr))
			//	cleanUpAfterMenuItemRenderer(rdr);
			if (previousMenuItemRenderer)
				cleanUpAfterMenuItemRenderer(previousMenuItemRenderer);
			previousMenuItemRenderer = rdr;

		}

		internal function cleanUpAfterMenuItemRenderer(rdr:MenuItemRenderer):void
		{

			var rendererMenu:MenuRenderer = rescursiveFindMenu(rdr);

			// TODO : Enhance this to use a MenuChain
			// check to see if submenu is open ,checking against the base
			if (rendererMenu)
			{
				if (previousMenuItemRenderer == rdr)
				{

					previousMenuItemRenderer = null;
				}
				if (lastActiveRendererForSubMenu == rdr)
				{
					lastActiveRendererForSubMenu = null;
				}
				rdr.explictActive = false;
				var openSubMenu:MenuRenderer = activeMenuRepo.getMenu(rendererMenu);
				if (openSubMenu)
					cleanUpAfterMenu(openSubMenu);

			}

		}



		private function timerHysteresisHandler(e:TimerEvent):void
		{

			//	trace("timerHysteresisHandler:check")

			if (!activeMenuItemRenderer ||
				!activeMenuItemRenderer.hitTestPoint(stage.mouseX, stage.mouseY)
				|| // if not over current activeMenuItemRendere exit
				previousMenuItemRenderer && activeMenuItemRenderer == previousMenuItemRenderer) // to not allow same renders
			{


				trace("timerHysteresisHandler", activeMenuItemRenderer == previousMenuItemRenderer);

				//trace(activeMenuItemRenderer, previousMenuItemRenderer, activeMenuItemRenderer == previousMenuItemRenderer);
				//trace("No ActiveMenuItemRenderer or fails HitTest");
				return;
			}



			// We need to check to see if we have a previous renderer and if so if it one of a submenu
			// If all checks are TRUE we then check to see if activeMenuItemRender 
			// is part of the previousMenuItemRender, if so we will return out of check and let the timer
			// run again . This is to prevent flickering of the submenu, this may need to be refactor
			// after next release
			if (previousMenuItemRenderer &&
				previousMenuItemRenderer.data &&
				previousMenuItemRenderer.data.hasSubmenu())
			{
				var activeMenuName:String = activeMenuItemRenderer.label;
				var subMenuItems:Vector.<ICustomMenuItem> = previousMenuItemRenderer.data.submenu.items;
				var subMenuItem:ICustomMenuItem;
				for each (subMenuItem in subMenuItems)
				{
					if (subMenuItem.label == activeMenuName)
					{
						//trace("IS Child OF ActiveMenu!!!")
						return;
					}

				}
			}




			var rdr:MenuItemRenderer = activeMenuItemRenderer;

			cancelHysteresisTimer();

			displaySubMenuForRenderer(rdr);
		}

	}
}

import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;

import actionScripts.ui.menu.renderers.MenuRenderer;


internal class MenuRepo
{

	private var menuToBaseRepo:Dictionary = new Dictionary(true);

	private var baseToMenuRepo:Dictionary = new Dictionary(true);


	public function add(base:DisplayObjectContainer, menu:MenuRenderer):void
	{
		menuToBaseRepo[menu] = base;
		baseToMenuRepo[base] = menu;
	}

	public function getOpenMenusForTopMenu(menu:MenuRenderer):Vector.<MenuRenderer>
	{
		var opened:Vector.<MenuRenderer> = new Vector.<MenuRenderer>([menu]);

		while (hasObjectAsMenu(menu))
		{
			menu = getMenu(menu);
			opened.push(menu);
		}
		return opened;
	}

	public function hasObjectAsBase(obj:Object):Boolean
	{
		return baseToMenuRepo[obj] ? true : false;
	}

	public function hasObjectAsMenu(obj:Object):Boolean
	{
		return menuToBaseRepo[obj] ? true : false;
	}

	public function has(baseOrMenu:Object):Boolean
	{
		if (baseOrMenu is MenuRenderer)
			return menuToBaseRepo[baseOrMenu] ? true : false;
		return baseToMenuRepo[baseOrMenu] ? true : false;
	}

	public function getMenu(base:DisplayObjectContainer):MenuRenderer
	{
		return baseToMenuRepo[base] as MenuRenderer;
	}

	public function getBase(menu:MenuRenderer):DisplayObjectContainer
	{
		return menuToBaseRepo[menu] as DisplayObjectContainer;
	}

	public function clear(menuOrBase:Object=null):void
	{
		var obj:Object
		if (menuOrBase)
		{

			if (menuOrBase is MenuRenderer)
			{
				obj = menuToBaseRepo[menuOrBase];
				menuToBaseRepo[menuOrBase] = null;
				baseToMenuRepo[obj] = null;
				obj = null;
			}
			else
			{
				obj = baseToMenuRepo[menuOrBase];
				baseToMenuRepo[menuOrBase] = null;
				menuToBaseRepo[obj] = null;
				obj = null;
			}
		}
		else
		{

			for each (obj in menuToBaseRepo)
				menuToBaseRepo[obj] = null;

			for each (obj in baseToMenuRepo)
				baseToMenuRepo[obj] = null;
		}

	}

}