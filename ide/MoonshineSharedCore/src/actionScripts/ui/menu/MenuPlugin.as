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
	import flash.display.NativeMenu;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.events.MenuEvent;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.ShortcutEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.factory.NativeMenuItemLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.ui.menu.vo.CustomMenu;
	import actionScripts.ui.menu.vo.CustomMenuItem;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.utils.KeyboardShortcutManager;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.KeyboardShortcut;
	import actionScripts.valueObjects.Settings;
	
	// This class is a singleton
	public class MenuPlugin extends PluginBase implements ISettingsProvider
	{
		
		// If you add menus, make sure to add a constant for the event + a binding for a command in IDEController
		public static const MENU_QUIT_EVENT:String = "menuQuitEvent";
		public static const MENU_OPEN_EVENT:String = "menuOpenEvent";
		public static const MENU_SAVE_EVENT:String = "menuSaveEvent";
		public static const MENU_SAVE_AS_EVENT:String = "menuSaveAsEvent";
		public static const EVENT_ABOUT:String = "EVENT_ABOUT";
		public static const CHANGE_MENU_MAC_DISABLE_STATE:String = "CHANGE_MENU_MAC_DISABLE_STATE"; // shows only Quit command with File menu
		public static const CHANGE_MENU_MAC_NO_MENU_STATE:String = "CHANGE_MENU_MAC_NO_MENU_STATE"; // shows absolutely no top menu
		public static const CHANGE_MENU_MAC_ENABLE_STATE:String = "CHANGE_MENU_MAC_ENABLE_STATE";
		public static const CHANGE_MENU_FILE_NEW_DISABLE_STATE:String = "CHANGE_MENU_FILE_NEW_DISABLE_STATE";
		public static const CHANGE_MENU_FILE_NEW_ENABLE_STATE:String = "CHANGE_MENU_FILE_NEW_ENABLE_STATE";
		public static const CHANGE_MENU_SDK_STATE:String = "CHANGE_MENU_SDK_STATE";
		
		private const BUILD_NATIVE_MENU:uint = 1;
		private const BUILD_CUSTOM_MENU:uint = 2;
		private const BUILD_NATIVE_CUSTOM_MENU:uint = 3;
		
		// Menu Event to data mapping, used for passing extra information to 
		// listeners
		private var eventToMenuMapping:Dictionary = new Dictionary();
		private var noSDKOptionsToMenuMapping:Dictionary = new Dictionary();
		private var noCodeCompletionOptionsToMenuMapping:Dictionary = new Dictionary();
		
		override public function get name():String { return "Application Menu Plugin"; }
		override public function get author():String { return "Keyston Clay & Moonshine Project Team"; }
		override public function get description():String { return "Adds Menu"; }		
		
		public function getSettingsList():Vector.<ISetting>
		{
			if (!ConstantsCoreVO.IS_AIR) return Vector.<ISetting>([]);
			
			var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
				new NameValuePair("Native", BUILD_NATIVE_MENU),
				new NameValuePair("Custom", BUILD_CUSTOM_MENU)
			]);
			
			if (Settings.os != "win")
			{
				nvps.push(new NameValuePair("Native & Custom", BUILD_NATIVE_CUSTOM_MENU));
			}
			return Vector.<ISetting>([
				new MultiOptionSetting(this, "activeMenus", "Select your menu", nvps)
			]);
		}
		
		// Data structure for Application window on Mac, Window menu on Windows and to-be-figured-out on Lunix.
		protected var macMenu:MenuItem = new MenuItem(ConstantsCoreVO.IS_DEVELOPMENT_MODE ? "MoonshineDevelopment" : "Moonshine");
		protected var macMenuForDisableStateMac:MenuItem = new MenuItem(ConstantsCoreVO.IS_DEVELOPMENT_MODE ? "MoonshineDevelopment" : "Moonshine");
		protected var quitMenuItem:MenuItem = IDEModel.getInstance().flexCore.getQuitMenuItem();
		protected var quitMenuItemForDisableStateMac:MenuItem = IDEModel.getInstance().flexCore.getQuitMenuItem();
		protected var settingsMenuItem:MenuItem = IDEModel.getInstance().flexCore.getSettingsMenuItem();
		protected var aboutMenuItem:MenuItem = IDEModel.getInstance().flexCore.getAboutMenuItem();
		protected var windowMenus:Vector.<MenuItem> = IDEModel.getInstance().flexCore.getWindowsMenu();
		protected var windowMenusForDisableStateMac:Vector.<MenuItem> = new Vector.<MenuItem>();
		
		protected var topNativeMenuItemsForFileNew:Object;
		
		public var activeMenus:uint = ((Settings.os != "win") && ConstantsCoreVO.IS_AIR) ? BUILD_NATIVE_MENU : BUILD_CUSTOM_MENU;
		//public var activeMenus:uint = ( (Settings.os != "mac") && ConstantsCoreVO.IS_AIR) ? BUILD_NATIVE_MENU : BUILD_CUSTOM_MENU;
		
		protected static var shortcutManager:KeyboardShortcutManager = KeyboardShortcutManager.getInstance();
		private var buildingNativeMenu:Boolean = false;
		
		override public function activate():void
		{
			super.activate();
			init();
		}
		
		override public function deactivate():void
		{
		}
		
		public function addMenu(menu:MenuItem):void
		{
		}
		
		public function addPluginMenu(menu:MenuItem):void
		{
			if (!menu)
				return;
			// If we have an assigned parent, loop down & place the menu there.
	
			if (menu.parents)
			{
				recurseAssignMenu(menu, windowMenus);
			}
		}
		
		private function init():void
		{	
			if (ConstantsCoreVO.IS_AIR)
			{
				if (Settings.os == "mac") 
				{
					windowMenus.splice(0, 0, macMenu);
					macMenu.items = new Vector.<MenuItem>();
					macMenu.items.push(aboutMenuItem);
					macMenu.items.push(settingsMenuItem);
					
					windowMenusForDisableStateMac.splice(0, 0, macMenuForDisableStateMac);
					macMenuForDisableStateMac.items = new Vector.<MenuItem>();
					
					windowMenusForDisableStateMac[0].items.push(quitMenuItemForDisableStateMac);
				}
				else
				{
					windowMenus[0].items.push(new MenuItem(null));
					windowMenus[0].items.push(settingsMenuItem);
				}
				
				windowMenus[0].items.push(new MenuItem(null));
				windowMenus[0].items.push(quitMenuItem);
			}
			else
			{
				windowMenus[0].items.push(new MenuItem(null));
				windowMenus[0].items.push(settingsMenuItem);
				
				// this will populate template items inside File -> New
				var parentArray:Array = new Array('File','New');
				addSUBMenu(parentArray,windowMenus);
			}
			
			if (!activated) return;
			
			if (activeMenus == BUILD_NATIVE_MENU || activeMenus == BUILD_NATIVE_CUSTOM_MENU)
			{
				buildingNativeMenu = true;
				createMenu();
			}
			
			if (activeMenus == BUILD_CUSTOM_MENU || activeMenus == BUILD_NATIVE_CUSTOM_MENU)
			{
				buildingNativeMenu = false;
				createMenu();
			}
			
			dispatcher.addEventListener(ShortcutEvent.SHORTCUT_PRE_FIRED, handleShortcutPreFired);
			dispatcher.addEventListener(CHANGE_MENU_FILE_NEW_DISABLE_STATE, onDisableFileNewMenu);
			dispatcher.addEventListener(CHANGE_MENU_FILE_NEW_ENABLE_STATE, onEnableFileNewMenu);
			dispatcher.addEventListener(CHANGE_MENU_SDK_STATE, onSDKStateChange);
			
			if (ConstantsCoreVO.IS_MACOS) 
			{
				dispatcher.addEventListener(CHANGE_MENU_MAC_DISABLE_STATE, onMacDisableStateChange);
				dispatcher.addEventListener(CHANGE_MENU_MAC_NO_MENU_STATE, onMacNoMenuStateChange);
				dispatcher.addEventListener(CHANGE_MENU_MAC_ENABLE_STATE, onMacEnableStateChange);
			}
			
			// disable File-New menu as default
			onDisableFileNewMenu(null);
		}
		
		// Add submenu under parent
		private function addSUBMenu(parentItem:Array,windowmenu:Vector.<MenuItem>):void
		{
			var file:FileLocation;
			var menuitem:MenuItem;
			for each(var parent:String in parentItem)
			{
				for each(var m:MenuItem in windowmenu)
				{
					if(m.label==parent)
					{
						parentItem.splice(0, 1);
						if(parentItem.length == 0)
						{
							// add submenu
							m.items = new Vector.<MenuItem>;
							for each (file in ConstantsCoreVO.TEMPLATES_FILES)
							{
								var fileName:String = file.fileBridge.name.substring(0,file.fileBridge.name.lastIndexOf("."))
								menuitem = new MenuItem(fileName,null,fileName);
								m.items.push(menuitem);
							}
							menuitem = new MenuItem(null);
							m.items.push(menuitem);
							for each (file in ConstantsCoreVO.TEMPLATES_PROJECTS)
							{
								menuitem = new MenuItem(file.fileBridge.name,null,file.fileBridge.name);
								m.items.push(menuitem);
							}	
							break;
						}
						else{
							addSUBMenu(parentItem,m.items);
						}
					}
				}
			}
		}
		
		// Adds menu to internal menu representation at a given point. MenuItem.parents decide where it goes.
		protected function recurseAssignMenu(menuItem:MenuItem, children:Vector.<MenuItem>):void
		{
			var target:String = (menuItem.parents.length) ? menuItem.parents[0] : menuItem.label;
			
			for each (var m:MenuItem in children)
			{
				if (m && m.label == target)
				{
					if (m.items == null)
						m.items = new Vector.<MenuItem>(1);
					menuItem.parents.splice(0, 1);
					recurseAssignMenu(menuItem, m.items);
					return;
				}
			}
			
			if (menuItem.parents.length == 0)
			{
				// Target menu found, just add children.
				for each (var submenuItem:MenuItem in menuItem.items)
				{
					children.push(submenuItem);
				}
			}
			else
			{
				// Menu not found, add it.
				children.push(menuItem);
			}
		}
		
		private function createMenu():void
		{
			var mainMenu:* = buildingNativeMenu ? new NativeMenu() : new CustomMenu();
			addMenus(windowMenus, mainMenu);
			
			var noSDKOptionsRootIndex:int;
			if (buildingNativeMenu)
			{
				// native menu should only come for AIR version
				FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
				FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
				
				noSDKOptionsRootIndex = 1;
			}
			else
			{
				var menuBar:MenuBar = new MenuBar();
				menuBar.menu = mainMenu;
				IDEModel.getInstance().mainView.addChildAt(menuBar, 0);
			}
			
			// in case of OSX, top menu append with a new system level menu (i.e. Moonshine) at 0th index
			// thus, menu index for Windows what could be 0, shall be 1 in OSX
			noCodeCompletionOptionsToMenuMapping[2 + noSDKOptionsRootIndex] = [6, 7, 8];
			noSDKOptionsToMenuMapping[3 + noSDKOptionsRootIndex] = [2, 3, 4, 5, 6, 8];
			noSDKOptionsToMenuMapping[4 + noSDKOptionsRootIndex] = [0, 2, 3, 4];
			noSDKOptionsToMenuMapping[5 + noSDKOptionsRootIndex] = [0];
		}
		
		private function onDisableFileNewMenu(event:Event):void
		{
			if (!topNativeMenuItemsForFileNew)
			{
				// os == mac
				if (buildingNativeMenu)
				{
					var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
					var itemsInTopMenu:Array = tmpTopMenu.items; // top-level menus, i.e. Moonshine, File etc.
					var subItemsInItemOfTopMenu:Array = itemsInTopMenu[1].submenu.items; // i.e. File
					topNativeMenuItemsForFileNew = subItemsInItemOfTopMenu[0].submenu.items; // i.e. File -> New
				}
				else
				{
					var menuBarMenu:CustomMenu = (IDEModel.getInstance().mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
					topNativeMenuItemsForFileNew = (menuBarMenu.items[0] as CustomMenuItem).data.items[0].data.items;
				}
				
				for (var i:int=0; i < 6; i++)
				{
					topNativeMenuItemsForFileNew[i].enabled = false;
				}
			}
			else
			{
				for (var j:int=0; j < 6; j++)
				{
					topNativeMenuItemsForFileNew[j].enabled = false;
				}
			}
		}
		
		private function onEnableFileNewMenu(event:Event):void
		{
			if (topNativeMenuItemsForFileNew)
			{
				for (var i:int=0; i < 6; i++)
				{
					topNativeMenuItemsForFileNew[i].enabled = true;
				}
			}
		}
		
		private function onMacDisableStateChange(event:Event):void
		{
			var mainMenu:* = buildingNativeMenu ? new NativeMenu() : new CustomMenu();
			addMenus(windowMenusForDisableStateMac, mainMenu);
			
			// for mac only
			if (buildingNativeMenu)
			{
				FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
				FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
			}
		}
		
		private function onMacNoMenuStateChange(event:Event):void
		{
			var mainMenu:* = buildingNativeMenu ? new NativeMenu() : new CustomMenu();
			addMenus(new Vector.<MenuItem>(), mainMenu);
			
			// for mac only
			if (buildingNativeMenu)
			{
				FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
				FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
			}
		}
		
		private function onMacEnableStateChange(event:Event):void
		{
			var mainMenu:* = buildingNativeMenu ? new NativeMenu() : new CustomMenu();
			addMenus(windowMenus, mainMenu);
			
			// for mac only
			if (buildingNativeMenu)
			{
				FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
				FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
			}
		}
		
		private function onSDKStateChange(event:Event):void
		{
			var isEnable:Boolean = model.defaultSDK ? true : false;
			var itemsInTopMenu:Object;
			// os == mac
			if (buildingNativeMenu)
			{
				var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
				itemsInTopMenu = tmpTopMenu.items; // top-level menus, i.e. Moonshine, File etc.
			}
			else
			{
				itemsInTopMenu = ((IDEModel.getInstance().mainView.getChildAt(0) as MenuBar).menu as CustomMenu).items;
			}
			
			var tmpOptionsArr:Array;
			var subItemsInTopMenu:Object
			for (var i:String in noSDKOptionsToMenuMapping)
			{
				tmpOptionsArr = noSDKOptionsToMenuMapping[i];
				subItemsInTopMenu = itemsInTopMenu[int(i)].submenu.items;
				for (var j:String in tmpOptionsArr)
				{
					subItemsInTopMenu[tmpOptionsArr[j]].enabled = isEnable;
				}
			}
			
			if (!model.isCodeCompletionJavaPresent || !model.javaPathForTypeAhead) isEnable = false;
			else if (model.isCodeCompletionJavaPresent && model.javaPathForTypeAhead) isEnable = true;
			else isEnable = false;
			for (var k:String in noCodeCompletionOptionsToMenuMapping)
			{
				tmpOptionsArr = noCodeCompletionOptionsToMenuMapping[k];
				subItemsInTopMenu = itemsInTopMenu[int(k)].submenu.items;
				for (var l:String in tmpOptionsArr)
				{
					subItemsInTopMenu[tmpOptionsArr[l]].enabled = isEnable;
				}
			}
		}
		
		protected function createNewMenu():*
		{
			return buildingNativeMenu ? new NativeMenu() : new CustomMenu();
		}
		
		private function createNewMenuItem(item:MenuItem):*
		{
			var nativeMenuItem:NativeMenuItemLocation;
			var menuItem:CustomMenuItem;
			var shortcut:KeyboardShortcut = buildShortcut(item);
			if (buildingNativeMenu)
			{
				// in case of AIR
				nativeMenuItem = new NativeMenuItemLocation(item.label, item.isSeparator);
				if (item[Settings.os + "_key"])
					nativeMenuItem.item.keyEquivalent = item[Settings.os + "_key"];
				if (item[Settings.os + "_mod"])
					nativeMenuItem.item.keyEquivalentModifiers = item[Settings.os + "_mod"];
				if (item.event)
				{
					// TODO : don't like this
					nativeMenuItem.item.data = {
						eventData:item.data,
							event:item.event
					};
					eventToMenuMapping[item.event] = nativeMenuItem;
					nativeMenuItem.item.listener = redispatch;
					
				}
			}
			else
			{
				menuItem = new CustomMenuItem(item.label, item.isSeparator);
				if (shortcut)
				{
					menuItem.shortcut = shortcut;
				}
				else if (item.event)
				{
					// TODO : dont like this either :/
					menuItem.data = {
						eventData:item.data,
							event:item.event
					}
					eventToMenuMapping[item.event] = menuItem;
				}
				
			}
			if (shortcut)
				registerShortcut(shortcut);
			
			return buildingNativeMenu ? nativeMenuItem : menuItem;
			
		}
		
		private function buildShortcut(item:MenuItem):KeyboardShortcut
		{
			var key:String
			var mod:Array
			var event:String
			
			if (item[Settings.os + "_key"])
				key = item[Settings.os + "_key"];
			if (item[Settings.os + "_mod"])
				mod = item[Settings.os + "_mod"];
			if (item.event)
				event = item.event
			if (event && key)
				return new KeyboardShortcut(event, key, mod);
			return null;
		}
		
		private function registerShortcut(shortcut:KeyboardShortcut):void
		{
			shortcutManager.activate(shortcut);
		}
		
		// Loop through menu structure and add menus through handler
		protected function addMenus(items:Vector.<MenuItem>, parentMenu:*):void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				var item:MenuItem = items[i];
				
				if (item && item.items)
				{
					var newMenu:*;
					newMenu = createNewMenu();
					if (!newMenu)
						continue;
					addMenus(item.items, newMenu);
					parentMenu.addSubmenu(newMenu, item.label);
				}
				else if (item)
				{
					var menuItem:* = createNewMenuItem(item);
					if (menuItem)
						parentMenu.addItem((menuItem is NativeMenuItemLocation) ? NativeMenuItemLocation(menuItem).item.getNativeMenuItem : menuItem);
				}
			}
		}
		
		// Take events and redispatch them through GED.
		protected function redispatch(event:Event):void
		{
			if (event.target && event.target.data)
			{
				var eventType:String = event.target.data.event as String;
				if (eventType)
				{
					shortcutManager.stopEvent(eventType); // use to stop pending event from shortcut					
				}
			}
		}
		
		protected function handleShortcutPreFired(e:ShortcutEvent):void
		{
			if (!eventToMenuMapping[e.event])
				return;
			var data:Object = eventToMenuMapping[e.event].data;
			e.preventDefault();
			dispatcher.dispatchEvent(new MenuEvent(
				data.event, false, false,
				data.eventData))
		}
	}
}