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
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.utils.Dictionary;

import mx.core.FlexGlobals;
import mx.events.MenuEvent;

import actionScripts.events.ProjectEvent;
import actionScripts.events.ShortcutEvent;
import actionScripts.events.TemplatingEvent;
import actionScripts.factory.FileLocation;
import actionScripts.factory.NativeMenuItemLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
import actionScripts.plugin.settings.ISettingsProvider;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.MultiOptionSetting;
import actionScripts.plugin.settings.vo.NameValuePair;
import actionScripts.plugin.templating.TemplatingPlugin;
import actionScripts.ui.menu.interfaces.ICustomMenu;
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
		public static const MENU_SAVE_EVENT:String = "menuSaveEvent";
		public static const MENU_SAVE_AS_EVENT:String = "menuSaveAsEvent";
		public static const EVENT_ABOUT:String = "EVENT_ABOUT";
		public static const CHANGE_MENU_MAC_DISABLE_STATE:String = "CHANGE_MENU_MAC_DISABLE_STATE"; // shows only Quit command with File menu
		public static const CHANGE_MENU_MAC_NO_MENU_STATE:String = "CHANGE_MENU_MAC_NO_MENU_STATE"; // shows absolutely no top menu
		public static const CHANGE_MENU_MAC_ENABLE_STATE:String = "CHANGE_MENU_MAC_ENABLE_STATE";
		public static const CHANGE_MENU_SDK_STATE:String = "CHANGE_MENU_SDK_STATE";
		
		private const BUILD_NATIVE_MENU:uint = 1;
		private const BUILD_CUSTOM_MENU:uint = 2;
		private const BUILD_NATIVE_CUSTOM_MENU:uint = 3;
		
		// Menu Event to data mapping, used for passing extra information to 
		// listeners
		private var eventToMenuMapping:Dictionary = new Dictionary();
		private var noSDKOptionsToMenuMapping:Dictionary = new Dictionary();
		private var noCodeCompletionOptionsToMenuMapping:Dictionary = new Dictionary();
		private var isFileNewMenuIsEnabled:Boolean;

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
		private var lastSelectedProjectBeforeMacDisableStateChange:AS3ProjectVO;
		
		override public function activate():void
		{
			super.activate();
			init();
		}
		
		override public function deactivate():void
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
				var parentArray:Array = ['File','New'];
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
			dispatcher.addEventListener(CHANGE_MENU_SDK_STATE, onSDKStateChange);
			dispatcher.addEventListener(TemplatingEvent.ADDED_NEW_TEMPLATE, onNewMenuAddRequest, false, 0, true);
			dispatcher.addEventListener(TemplatingEvent.REMOVE_TEMPLATE, onNewMenuRemoveRequest, false, 0, true);
			dispatcher.addEventListener(TemplatingEvent.RENAME_TEMPLATE, onNewMenuRenameRequest, false, 0, true);
			//dispatcher.addEventListener(RecentlyOpenedPlugin.RECENT_PROJECT_LIST_UPDATED, updateRecetProjectList, false, 0, true);
			
			if (ConstantsCoreVO.IS_MACOS) 
			{
				dispatcher.addEventListener(CHANGE_MENU_MAC_DISABLE_STATE, onMacDisableStateChange);
				dispatcher.addEventListener(CHANGE_MENU_MAC_NO_MENU_STATE, onMacNoMenuStateChange);
				dispatcher.addEventListener(CHANGE_MENU_MAC_ENABLE_STATE, onMacEnableStateChange);
			}

			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, onMenusDisableStateChange);
			dispatcher.addEventListener(ProjectEvent.ACTIVE_PROJECT_CHANGED, onMenusDisableStateChange);
			
			// disable File-New menu as default
			isFileNewMenuIsEnabled = false;
            disableMenuOptionsForVEProject();
			disableNewFileMenuOptions();
		}

        private function onMenusDisableStateChange(event:ProjectEvent):void
        {
            disableNewFileMenuOptions();
			disableMenuOptionsForVEProject();
        }

		private function disableMenuOptionsForVEProject(lastSelectedProject:AS3ProjectVO=null):void
		{
			var activeProject:AS3ProjectVO = lastSelectedProject ? lastSelectedProject : model.activeProject as AS3ProjectVO;

			if (ConstantsCoreVO.IS_AIR)
            {
				var menu:Object = null;
                if (Settings.os == "win")
                {
                    menu = (model.mainView.getChildAt(0) as MenuBar).menu;
                }
				else if (Settings.os == "mac")
				{
                    menu = FlexGlobals.topLevelApplication.nativeApplication.menu;
				}

				if (menu)
                {
                    var countMenuItems:int = menu.items.length;
					var menuItem:Object;
                    for (var i:int = 0; i < countMenuItems; i++)
                    {
						menuItem = menu.items[i];
						if (menuItem.submenu)
                        {
                            recursiveDisabledMenuForVisualEditor(menuItem.submenu.items, activeProject);
                        }
                    }

                }
            }
		}

		private function recursiveDisabledMenuForVisualEditor(menuItems:Object, currentProject:AS3ProjectVO):void
		{
            var countMenuItems:int = menuItems.length;
            for (var i:int = 0; i < countMenuItems; i++)
            {
				var menuItem:Object = menuItems[i];
				menuItem.enabled = MenuUtils.isMenuItemEnabledInVisualEditor(menuItem.label);
				isFileNewMenuIsEnabled = menuItem.enabled;
				
				if (menuItem.submenu)
                {
                    recursiveDisabledMenuForVisualEditor(menuItem.submenu.items, currentProject);
                }
            }
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
							for each (file in TemplatingPlugin.fileTemplates)
							{
								var fileName:String = file.fileBridge.name.substring(0,file.fileBridge.name.lastIndexOf("."));
								menuitem = new MenuItem(fileName,null,fileName);
								m.items.push(menuitem);
							}
							menuitem = new MenuItem(null);
							m.items.push(menuitem);
							for each (file in TemplatingPlugin.projectTemplates)
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
			var currentMenu:Object = applyNewNativeMenu(windowMenus);
			var noSDKOptionsRootIndex:int;
			if (currentMenu is NativeMenu)
			{
				noSDKOptionsRootIndex = 1;
			}
			else
			{
				var menuBar:MenuBar = new MenuBar();
				menuBar.menu = currentMenu as ICustomMenu;
				model.mainView.addChildAt(menuBar, 0);
			}
			
			// in case of OSX, top menu append with a new system level menu (i.e. Moonshine) at 0th index
			// thus, menu index for Windows what could be 0, shall be 1 in OSX
			noCodeCompletionOptionsToMenuMapping[2 + noSDKOptionsRootIndex] = [6, 7, 8];
			noSDKOptionsToMenuMapping[3 + noSDKOptionsRootIndex] = [2, 3, 4, 5, 6, 8];
			noSDKOptionsToMenuMapping[4 + noSDKOptionsRootIndex] = [0, 2, 3, 4];
			noSDKOptionsToMenuMapping[5 + noSDKOptionsRootIndex] = [0];
		}

		private function disableNewFileMenuOptions():void
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
					var menuBarMenu:CustomMenu = (model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
					topNativeMenuItemsForFileNew = (menuBarMenu.items[0] as CustomMenuItem).data.items[0].data.items;
				}
			}
			
			isFileNewMenuIsEnabled = false;
			for (var j:int = 0; j < TemplatingPlugin.fileTemplates.length; j++)
			{
				topNativeMenuItemsForFileNew[j].enabled = false;
			}
		}
		
		private function onNewMenuAddRequest(event:TemplatingEvent):void
		{
			var tmpMI:MenuItem = new MenuItem(event.label, null, event.listener);
			var menuItem:* = createNewMenuItem(tmpMI);
			var itemToAddAt:int = event.isProject ? TemplatingPlugin.projectTemplates.length + TemplatingPlugin.fileTemplates.length : TemplatingPlugin.fileTemplates.length - 1;
			var menuObject:Object = (menuItem is NativeMenuItemLocation) ? NativeMenuItemLocation(menuItem).item.getNativeMenuItem : menuItem;
			if (!isFileNewMenuIsEnabled) menuObject.enabled = false; 
			
			// updating arraylist to use against VE project
			MenuUtils.menuItemsEnabledInVEProject.push(event.label);
			
			if (menuItem)
			{
				if (buildingNativeMenu)
				{
					var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
					var itemsInTopMenu:Array = tmpTopMenu.items; // top-level menus, i.e. Moonshine, File etc.
					var subItemsInItemOfTopMenu:Array = itemsInTopMenu[1].submenu.items; // i.e. File
					subItemsInItemOfTopMenu[0].submenu.items[0].menu.addItemAt(menuObject, itemToAddAt);
					
					windowMenus[1].items[0].items.insertAt(itemToAddAt, new MenuItem(event.label, null, event.listener));
				}
				else
				{
					var menuBarMenu:CustomMenu = (model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
					CustomMenuItem(menuBarMenu.items[0].submenu.items[0]).data.items.insertAt(itemToAddAt, menuObject);
				}
			}
		}
		
		private function onNewMenuRemoveRequest(event:TemplatingEvent):void
		{
			var subItemsInItemOfTopMenu:Object;
			if (buildingNativeMenu)
			{
				var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
				var itemsInTopMenu:Array = tmpTopMenu.items; // top-level menus, i.e. Moonshine, File etc.
				subItemsInItemOfTopMenu = itemsInTopMenu[1].submenu.items[0].submenu.items;
			}
			else
			{
				var menuBarMenu:CustomMenu = (model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
				subItemsInItemOfTopMenu = CustomMenuItem(menuBarMenu.items[0].submenu.items[0]).data.items;
			}
			
			// updating arraylist to use against VE project
			MenuUtils.menuItemsEnabledInVEProject.splice(MenuUtils.menuItemsEnabledInVEProject.indexOf(event.label), 1);
			
			for (var i:int=0; i < subItemsInItemOfTopMenu.length; i++)
			{
				if (subItemsInItemOfTopMenu[i].label == event.label)
				{
					if (buildingNativeMenu)	
					{
						itemsInTopMenu[1].submenu.items[0].submenu.items[0].menu.removeItemAt(i);
						windowMenus[1].items[0].items.removeAt(i);
					}
					else CustomMenuItem(menuBarMenu.items[0].submenu.items[0]).data.items.removeAt(i);
					return;
				}
			}
		}
		
		private function updateRecetProjectList(event:Event):void
		{
			var subItemsLength:int = -1;
			if (buildingNativeMenu)
			{
				var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
				subItemsLength = tmpTopMenu.items[1].submenu.items[2].submenu.items.length; // top-level menus, i.e. Moonshine, File etc.
			}
			else
			{
				var menuBarMenu:CustomMenu = (model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
				subItemsLength = CustomMenuItem(menuBarMenu.items[0].submenu.items[2]).data.items.length;
			}
			
			if (subItemsLength != -1)
			{
				for (var i:int; i < subItemsLength; i++)
				{
					if (buildingNativeMenu) 
					{
						tmpTopMenu.items[1].submenu.items[2].submenu.items[0].menu.removeItemAt(0);
						windowMenus[1].items[0].items.removeAt(0);
					}
					else
					{
						CustomMenuItem(menuBarMenu.items[0].submenu.items[2]).data.items.removeAt(0);
					}
				}
			}
		}
		
		private function onNewMenuRenameRequest(event:TemplatingEvent):void
		{
			var subItemsInItemOfTopMenu:Object;
			if (buildingNativeMenu)
			{
				var tmpTopMenu:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
				subItemsInItemOfTopMenu = tmpTopMenu.items[1].submenu.items[0].submenu.items;
			}
			else
			{
				var menuBarMenu:CustomMenu = (model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu;
				subItemsInItemOfTopMenu = CustomMenuItem(menuBarMenu.items[0].submenu.items[0]).data.items;
			}
			
			// updating arraylist to use against VE project
			MenuUtils.menuItemsEnabledInVEProject[MenuUtils.menuItemsEnabledInVEProject.indexOf(event.label)] = event.newLabel;
			
			for (var i:int=0; i < subItemsInItemOfTopMenu.length; i++)
			{
				if (subItemsInItemOfTopMenu[i].label == event.label)
				{
					subItemsInItemOfTopMenu[i].label = event.newLabel;
					subItemsInItemOfTopMenu[i].data.event = (event.isProject ? "eventNewProjectFromTemplate" : "eventNewFileFromTemplate")+ event.newLabel;
					subItemsInItemOfTopMenu[i].data.eventData = event.newFileTemplate;
					
					// in case of mac we need to update windowMenus for latter use
					if (buildingNativeMenu)
					{
						windowMenus[1].items[0].items[i].label = event.newLabel;
						windowMenus[1].items[0].items[i].event = (event.isProject ? "eventNewProjectFromTemplate" : "eventNewFileFromTemplate")+ event.newLabel;
						windowMenus[1].items[0].items[i].data = event.newFileTemplate;
					}
					return;
				}
			}
		}

		private function onMacDisableStateChange(event:Event):void
		{
            applyNewNativeMenu(windowMenusForDisableStateMac);
			
			lastSelectedProjectBeforeMacDisableStateChange = model.activeProject as AS3ProjectVO;
		}
		
		private function onMacNoMenuStateChange(event:Event):void
		{
            applyNewNativeMenu(new Vector.<MenuItem>());
			
			lastSelectedProjectBeforeMacDisableStateChange = model.activeProject as AS3ProjectVO;
		}

		private function onMacEnableStateChange(event:Event):void
		{
			applyNewNativeMenu(windowMenus);
			
			// update menus for VE project
			disableMenuOptionsForVEProject(lastSelectedProjectBeforeMacDisableStateChange);
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
				itemsInTopMenu = ((model.mainView.getChildAt(0) as MenuBar).menu as CustomMenu).items;
			}
			
			var tmpOptionsArr:Array;
			var subItemsInTopMenu:Object;
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
					};
					eventToMenuMapping[item.event] = menuItem;
				}
				
			}
			if (shortcut)
				registerShortcut(shortcut);
			
			return buildingNativeMenu ? nativeMenuItem : menuItem;
			
		}
		
		private function buildShortcut(item:MenuItem):KeyboardShortcut
		{
			var key:String;
			var mod:Array;
			var event:String;
			
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

        private function applyNewNativeMenu(menuItems:Vector.<MenuItem>):Object
        {
            var mainMenu:Object = buildingNativeMenu ? new NativeMenu() : new CustomMenu();
            addMenus(menuItems, mainMenu);

            // for mac only
            if (buildingNativeMenu)
            {
				// for #162 feature request
				// introduce hide/unhide/show-all in macOS menu
				ensureHideUnhideMenuOption(mainMenu);
				
                FlexGlobals.topLevelApplication.nativeApplication.menu = mainMenu;
                FlexGlobals.topLevelApplication.nativeWindow.menu = mainMenu;
            }

            return mainMenu;
        }
		
		private function ensureHideUnhideMenuOption(nativeMenu:Object):void
		{
			var topLevel:Object = FlexGlobals.topLevelApplication.nativeApplication.menu;
			
			// the receipe is get-remove-add to make it work correctly
			var itemsToExtract:Array = ["hide adl", "hide moonshine", "hide others", "show all"];
			
			// we want the above options to come before Quit option
			var quitOptionIndex:int = nativeMenu.items[0].submenu.items.length - 2;
			
			// search against each items we needs
			for each (var i:String in itemsToExtract)
			{
				var itemsToExtractFrom:Array = topLevel.getItemAt(0).submenu.items;
				for (var j:int=0; j < itemsToExtractFrom.length; j++)
				{
					if (itemsToExtractFrom[j].label.toLowerCase() == i)
					{
						var tmpOption: * = itemsToExtractFrom[j];
						topLevel.getItemAt(0).submenu.removeItemAt(j);
						nativeMenu.items[0].submenu.addItemAt(tmpOption, ++quitOptionIndex);
						break;
					}
				}
			}
			
			// we also wants to add a separator!
			var separatorItem:* = createNewMenuItem(new MenuItem(null));
			nativeMenu.items[0].submenu.addItemAt(NativeMenuItemLocation(separatorItem).item.getNativeMenuItem, ++quitOptionIndex);
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
