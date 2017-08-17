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
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.StandardPopup;

	public class QuitCommand implements ICommand
	{
		private var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		private static var pop:StandardPopup;
		
		public function execute(event:Event):void
		{
			var editors:ArrayCollection = IDEModel.getInstance().editors;
			
			var editorsToClose:Array = [];
			for each (var tab:IContentWindow in editors)
			{
				if (!tab.isChanged())
				{
					editorsToClose.push(tab);
				}
			}
			
			for each (tab in editorsToClose)
			{
				ged.dispatchEvent(
					new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
				);
			}

			// One editor is auto-created when last is removed
			if (editors.length == 1 
				&& editors.getItemAt(0).isChanged() == false)
			{
				IDEModel.getInstance().flexCore.exitApplication();
			}
			else
			{
				event.preventDefault();
				askToSave(editors.length);
			}
		}
		
		private function askToSave(num:int):void
		{
			if (pop) return;
			pop = new StandardPopup();
			pop.data = this; // Keep the command from getting GC'd
			if (IDEModel.getInstance().editors.length == 1)
			{
				// show this only when there's no individual close alert already showing
				if (model.isIndividualCloseTabAlertShowing) 
				{
					pop = null;
					return;
				}
				
				pop.text = IDEModel.getInstance().editors[0].label + " is changed.";
			}
			else
			{
				// show this but by closing any existing individual close alert first
				if (model.isIndividualCloseTabAlertShowing) ged.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT, null));
				
				pop.text = num + " files are changed.";
			}
			
			var save:Button = new Button();
			save.styleName = "lightButton";
			save.label = "Save file";
			if (num > 1) save.label += "s";
			save.addEventListener(MouseEvent.CLICK, saveFiles, false, 0, false);
			
			var close:Button = new Button();
			close.styleName = "lightButton";
			close.label = "Quit anyway";
			close.addEventListener(MouseEvent.CLICK, closeFiles, false, 0, false);
			
			var cancel:Button = new Button();
			cancel.styleName = "lightButton";
			cancel.label = "See file";
			if (num > 1) cancel.label += "s";
			cancel.addEventListener(MouseEvent.CLICK, cancelQuit, false, 0, false);
			 
			pop.buttons = [save, close, cancel];
			
			PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, true);
			pop.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
			pop.x = ((FlexGlobals.topLevelApplication as DisplayObject).width-pop.width)/2;
			
			// @devsena
			// we need this because if application frame resized when above alert
			// opened, the alert didn't make it's position at center of the application but static
			FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, onApplicationResized);
			// disable file menus in OSX
			ged.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_NO_MENU_STATE));
		}
		
		private function onApplicationResized(event:ResizeEvent):void
		{
			if (pop) pop.x = (FlexGlobals.topLevelApplication.width-pop.width)/2;
		}
		
		private function saveFiles(event:Event):void
		{
			cleanUp();
			
			var saveAs:Boolean;
			var editors:Array = IDEModel.getInstance().editors.source.concat();
			for each (var tab:IContentWindow in editors)
			{
				var editor:BasicTextEditor = tab as BasicTextEditor;
				if (editor)
				{
					if (!editor.currentFile)
					{
						// Don't spawn multiple Save As dialogs
						if (saveAs) continue;
						saveAs = true;
						editor.save();
					}
					else
					{
						editor.save();
						ged.dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
						);
					}
				}
				else
				{
					tab.save();
					ged.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
					);
				}
			}
			
			if (!saveAs)
			{
				IDEModel.getInstance().flexCore.exitApplication();
			}
		}
		
		private function closeFiles(event:Event):void
		{
			IDEModel.getInstance().flexCore.exitApplication();
		}
		private function cancelQuit(event:Event):void
		{
			cleanUp();	
		}
		
		private function cleanUp():void
		{
			if (pop)
			{
				FlexGlobals.topLevelApplication.removeEventListener(ResizeEvent.RESIZE, onApplicationResized);
				ged.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));
				PopUpManager.removePopUp(pop);
				pop.data = null;
				pop = null;
			}
		}
	}
}