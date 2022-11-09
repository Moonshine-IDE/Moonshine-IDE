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
package actionScripts.controllers
{
    import actionScripts.ui.editor.BasicTextEditor;

    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;
    import mx.events.ResizeEvent;
    import mx.managers.PopUpManager;

    import feathers.controls.Button;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.locator.IDEModel;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabView;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.HamburgerMenuTabsVO;
    
    import moonshine.components.StandardPopupView;
    import actionScripts.ui.FeathersUIWrapper;
    import moonshine.theme.MoonshineTheme;

	public class CloseTabCommand implements ICommand
	{
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var tabToClose:IContentWindow;
		private var pop:StandardPopupView;
		private var popWrapper:FeathersUIWrapper;

		public function execute(event:Event):void
		{
			var tabView:TabView;
			if (event.type == CloseTabEvent.EVENT_CLOSE_ALL_TABS)
			{
                tabView = model.mainView.mainContent;
				if (tabView)
				{
					tabView.removeTabsFromCache();
				}
				UtilsCore.closeAllRelativeEditors(null);
				return;
			}

			if (event.type == CloseTabEvent.EVENT_CLOSE_ALL_OTHER_TABS)
			{
				tabView = model.mainView.mainContent;
				if (tabView)
				{
					tabView.removeTabsFromCache(model.activeEditor);
				}
				UtilsCore.closeAllRelativeEditors(
						null, false, null, true,
						model.activeEditor
				);
				return;
			}
			
			if (event.hasOwnProperty('tab'))
				tabToClose = event['tab'];
			else
				tabToClose = model.activeEditor;	
			
			var forceClose:Boolean;
			if (event.hasOwnProperty('forceClose'))
				forceClose = event['forceClose'];

			if (!forceClose && tabToClose.isChanged())
			{	
				pop = new StandardPopupView();
				pop.data = this; // Keep the command from getting GC'd
				pop.text = tabToClose.label + " is changed.";
				
				// Changed tabs are marked with * before the filename. Strip if found.
				if (pop.text.charAt(0) == "*")
				{
					pop.text = pop.text.substr(1);
				}
				
				var save:Button = new Button();
				save.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
				save.text = "Save file";
				save.addEventListener(MouseEvent.CLICK, saveTab, false, 0, false);
				
				var close:Button = new Button();
				close.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
				close.text = "Discard";
				close.addEventListener(MouseEvent.CLICK, closeTab, false, 0, false);
				
				var cancel:Button = new Button();
				cancel.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
				cancel.text = "See file again";
				cancel.addEventListener(MouseEvent.CLICK, seeFileAgain, false, 0, false);
				 
				pop.controls = [save, close, cancel];
				
				popWrapper = new FeathersUIWrapper(pop);
				PopUpManager.addPopUp(popWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
				popWrapper.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
				popWrapper.x = (FlexGlobals.topLevelApplication.width-popWrapper.width)/2;
				popWrapper.assignFocus("top");
				
				model.isIndividualCloseTabAlertShowing = true;
				
				// @devsena
				// we need this because if application frame resized when above alert
				// opened, the alert didn't make it's position at center of the application but static
				FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, onApplicationResized);
				
				// @devsena
				// if quitCommand ask this to close, then close it
				dispatcher.addEventListener(CloseTabEvent.EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT, onForceCloseRequest);
				// disable file menus in OSX
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_NO_MENU_STATE));
			}
			else
			{
				closeTab();
			}
			
		}
		
		private function cleanUp():void
		{
			if (popWrapper)
			{
				FlexGlobals.topLevelApplication.removeEventListener(ResizeEvent.RESIZE, onApplicationResized);
				dispatcher.removeEventListener(CloseTabEvent.EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT, onForceCloseRequest);
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));
				PopUpManager.removePopUp(popWrapper);
				pop.data = null;
				pop = null;
				popWrapper = null;
				model.isIndividualCloseTabAlertShowing = false;
			}
			
			tabToClose = null;
		}
		
		private function onApplicationResized(event:ResizeEvent):void
		{
			if (popWrapper) popWrapper.x = (FlexGlobals.topLevelApplication.width-popWrapper.width)/2;
		}
		
		private function onForceCloseRequest(event:Event):void
		{
			if (pop) cleanUp();
		}
		
		private function seeFileAgain(event:Event=null):void
		{
            if (tabToClose is BasicTextEditor)
            {
                model.mainView.mainContent.setSelectedTab(tabToClose as DisplayObject);
            }
			cleanUp();
		}
		
		private function saveTab(event:Event=null):void
		{
			tabToClose.save();
			closeTab();
			
			cleanUp();
		}
		
		private function closeTab(event:Event=null):void
		{
			//if (tabToClose is TourDeTextEditor) TourDeTextEditor(tabToClose).disposeFootprint();
			model.removeEditor(tabToClose);
			
			// Notify everyone we closed the tab
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_TAB_CLOSED, tabToClose as DisplayObject)
			);
			
			// Dispatch for the given tab as well (to reduce global listeners)
			tabToClose.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_TAB_CLOSED, tabToClose as DisplayObject)
			);

            var tabView:TabView = model.mainView.mainContent;
            if (tabView)
            {
                var hamburgerMenuTabs:ArrayCollection = tabView.model.hamburgerTabs;
                for (var i:int = 0; i < hamburgerMenuTabs.length; i++)
				{
					var item:HamburgerMenuTabsVO = hamburgerMenuTabs.getItemAt(i) as HamburgerMenuTabsVO;
					if (item.tabData == tabToClose)
					{
						hamburgerMenuTabs.removeItemAt(i);
						break;
					}
				}
            }

            cleanUp();
			
			// If we have a default tab that should be displayed, give it a shot now
			if (model.editors.length == 0)
			{
				dispatcher.dispatchEvent(
					new CloseTabEvent(CloseTabEvent.EVENT_ALL_TABS_CLOSED, null)
				);
			}
		}
	}
}