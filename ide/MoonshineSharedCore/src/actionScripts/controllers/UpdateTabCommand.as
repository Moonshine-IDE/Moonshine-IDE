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
package actionScripts.controllers
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;
    import mx.events.ResizeEvent;
    import mx.managers.PopUpManager;
    
    import spark.components.Button;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.UpdateTabEvent;
    import actionScripts.locator.IDEModel;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IContentWindowReloadable;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
    import components.popup.StandardPopup;

	public class UpdateTabCommand implements ICommand
	{
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var tabToUpdate:IContentWindow;
		private var pop:StandardPopup;

		public function execute(event:Event):void
		{
			if (event.hasOwnProperty('tab'))
				tabToUpdate = event['tab'];
			else
				tabToUpdate = model.activeEditor;	
			
			pop = new StandardPopup();
			pop.data = this; // Keep the command from getting GC'd
			
			var yesButton:Button = new Button();
			yesButton.styleName = "lightButton";
			
			var cancel:Button = new Button();
			cancel.styleName = "lightButton";
			
			if (event.type == UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE)
			{
				pop.text = tabToUpdate.label + " is removed from the filesystem. Do you want to save it?";
				
				yesButton.label = "Save Again";
				yesButton.addEventListener(MouseEvent.CLICK, saveButtonTab, false, 0, true);
				cancel.label = "Cancel";
				cancel.addEventListener(MouseEvent.CLICK, seeFileAgain, false, 0, true);
				
				var close:Button = new Button();
				close.styleName = "lightButton";
				close.label = "Close";
				close.addEventListener(MouseEvent.CLICK, closeFileAgain, false, 0, true);
				
				pop.buttons = [yesButton, close, cancel];
			}
			else
			{
				pop.text = tabToUpdate.label + " is changed outside. Do you want to reload it?";
				
				yesButton.label = "Yes";
				yesButton.addEventListener(MouseEvent.CLICK, yesButtonTab, false, 0, true);
				cancel.label = "No";
				cancel.addEventListener(MouseEvent.CLICK, seeFileAgain, false, 0, true);
				
				pop.buttons = [yesButton, cancel];
			}
			
			// Changed tabs are marked with * before the filename. Strip if found.
			if (pop.text.charAt(0) == "*")
			{
				pop.text = pop.text.substr(1);
			}
			
			PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, true);
			pop.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
			pop.x = (FlexGlobals.topLevelApplication.width-pop.width)/2;
			
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
		
		private function cleanUp():void
		{
			if (pop)
			{
				FlexGlobals.topLevelApplication.removeEventListener(ResizeEvent.RESIZE, onApplicationResized);
				dispatcher.removeEventListener(CloseTabEvent.EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT, onForceCloseRequest);
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));
				PopUpManager.removePopUp(pop);
				pop.data = null;
				pop = null;
				model.isIndividualCloseTabAlertShowing = false;
			}
			
			tabToUpdate = null;
		}
		
		private function onApplicationResized(event:ResizeEvent):void
		{
			if (pop) pop.x = (FlexGlobals.topLevelApplication.width-pop.width)/2;
		}
		
		private function onForceCloseRequest(event:Event):void
		{
			if (pop) cleanUp();
		}
		
		private function seeFileAgain(event:Event=null):void
		{
            if (tabToUpdate is BasicTextEditor)
            {
                model.mainView.mainContent.setSelectedTab(tabToUpdate as DisplayObject);
            }
			cleanUp();
		}
		
		private function yesButtonTab(event:Event=null):void
		{
			if (tabToUpdate is IContentWindowReloadable)
			{
				(tabToUpdate as IContentWindowReloadable).reload();
			}
			cleanUp();
		}
		
		private function saveButtonTab(event:Event=null):void
		{
			if (tabToUpdate is BasicTextEditor)
			{
				(tabToUpdate as BasicTextEditor).save();
			}
			cleanUp();
		}
		
		private function closeFileAgain(event:Event=null):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tabToUpdate as DisplayObject, true)
			);
			cleanUp();
		}
	}
}