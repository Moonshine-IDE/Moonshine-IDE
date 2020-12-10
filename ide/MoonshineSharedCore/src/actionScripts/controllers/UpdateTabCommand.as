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
    
    import mx.core.FlexGlobals;
    import mx.events.ResizeEvent;
    import mx.managers.PopUpManager;
    
    import feathers.controls.Button;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.UpdateTabEvent;
    import actionScripts.locator.IDEModel;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IContentWindowReloadable;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
    import moonshine.components.StandardPopupView;
    import actionScripts.ui.FeathersUIWrapper;
    import moonshine.theme.MoonshineTheme;

	public class UpdateTabCommand implements ICommand
	{
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var tabToUpdate:IContentWindow;
		private var pop:StandardPopupView;
		private var popWrapper:FeathersUIWrapper;

		public function execute(event:Event):void
		{
			if (event.hasOwnProperty('tab'))
				tabToUpdate = event['tab'];
			else
				tabToUpdate = model.activeEditor;
			
			// probable termination
			if ((tabToUpdate is BasicTextEditor) && 
				(model.individualTabAlertShowingFilePath == (tabToUpdate as BasicTextEditor).currentFile.fileBridge.nativePath))
			{
				return;
			}
			
			pop = new StandardPopupView();
			pop.data = this; // Keep the command from getting GC'd
			
			var yesButton:Button = new Button();
			yesButton.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
			
			var cancel:Button = new Button();
			cancel.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
			
			if (event.type == UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE)
			{
				pop.text = tabToUpdate.label + " is removed from the filesystem. Do you want to save it?";
				
				yesButton.text = "Save Again";
				yesButton.addEventListener(MouseEvent.CLICK, saveButtonTab, false, 0, true);
				cancel.text = "Cancel";
				cancel.addEventListener(MouseEvent.CLICK, seeFileAgain, false, 0, true);
				
				var close:Button = new Button();
				close.variant = MoonshineTheme.THEME_VARIANT_LIGHT_BUTTON;
				close.text = "Close";
				close.addEventListener(MouseEvent.CLICK, closeFileAgain, false, 0, true);
				
				pop.controls = [yesButton, close, cancel];
			}
			else
			{
				pop.text = tabToUpdate.label + " is changed outside. Do you want to reload it?";
				
				yesButton.text = "Yes";
				yesButton.addEventListener(MouseEvent.CLICK, yesButtonTab, false, 0, true);
				cancel.text = "No";
				cancel.addEventListener(MouseEvent.CLICK, seeFileAgain, false, 0, true);
				
				pop.controls = [yesButton, cancel];
			}
			
			// Changed tabs are marked with * before the filename. Strip if found.
			if (pop.text.charAt(0) == "*")
			{
				pop.text = pop.text.substr(1);
			}
			
			popWrapper = new FeathersUIWrapper(pop);
			PopUpManager.addPopUp(popWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
			popWrapper.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
			popWrapper.x = (FlexGlobals.topLevelApplication.width-popWrapper.width)/2;
			popWrapper.assignFocus("top");
			
			model.isIndividualCloseTabAlertShowing = true;
			model.individualTabAlertShowingFilePath = (tabToUpdate is BasicTextEditor) ? 
				(tabToUpdate as BasicTextEditor).currentFile.fileBridge.nativePath : null;
			
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
			
			tabToUpdate = null;
			model.individualTabAlertShowingFilePath = null;
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
            /*if (tabToUpdate is BasicTextEditor)
            {
                model.mainView.mainContent.setSelectedTab(tabToUpdate as DisplayObject);
            }*/
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