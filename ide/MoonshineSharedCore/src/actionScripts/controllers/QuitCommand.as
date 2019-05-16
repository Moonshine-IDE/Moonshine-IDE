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
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;
    import mx.events.ResizeEvent;
    import mx.managers.PopUpManager;
    
    import spark.components.Button;
    
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.settings.event.SetSettingsEvent;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.LayoutModifier;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
    import components.popup.QuitPopup;
    import components.popup.StandardPopup;
    import components.views.splashscreen.SplashScreen;

	public class QuitCommand implements ICommand
	{
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		private static var pop:StandardPopup;
		private var quitPopup:QuitPopup;
		private var timedOutClosingLanguageServers:Boolean = false;
		private var isGradleDaemonClosed:Boolean;
		private var languageServerTimeoutID:uint = uint.MAX_VALUE;

		private var commandEvent:Event;
		
		public function execute(event:Event):void
		{
            if (!quitPopup && model.confirmApplicationExit)
            {
                commandEvent = event;
                quitPopup = new QuitPopup();
                quitPopup.addEventListener("quitConfirmed", onQuitPopupConfirmed);
                quitPopup.addEventListener(Event.CLOSE, onQuitPopupClose);

                PopUpManager.addPopUp(quitPopup, FlexGlobals.topLevelApplication as DisplayObject, true);
				PopUpManager.centerPopUp(quitPopup);
            }
			else
			{
				internalExecute(event);
			}
		}

        private function onQuitPopupClose(event:Event):void
        {
            saveStateOfQuitPopup();
		   	cleanUpQuitPopup();
        }

        private function onQuitPopupConfirmed(event:Event):void
        {
            saveStateOfQuitPopup();
			internalExecute();
        }

		private function internalExecute(event:Event = null):void
		{
            dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW, null));
			dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.APPLICATION_EXIT));
            var editors:ArrayCollection = model.editors;

            var editorsToClose:Array = [];
            for each (var tab:IContentWindow in editors)
            {
                if (!tab.isChanged() && !(tab is SplashScreen))
                {
                    editorsToClose.push(tab);
                }
            }

            for each (tab in editorsToClose)
            {
                dispatcher.dispatchEvent(
                        new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
                );
            }

            // One editor is auto-created when last is removed
            if (editors.length == 0 || ((editors.length == 1) && editors[0] is SplashScreen))
            {
                onApplicationClosing();
            }
            else
            {
                if (commandEvent)
				{
					commandEvent.preventDefault();
                }
				else
				{
					event.preventDefault();
				}

                askToSave(editors.length-1);
            }
		}
		/**
		 * Moved from application file to this file
		 * as unknown reason demonstrated Event.CLOSING never fired
		 * in macOSX; it's hard to found which newer component/plugin
		 * integration creates the problem thus
		 * an alternative way to determine the exit situation
		 */
		protected function onApplicationClosing():void
		{
			ConstantsCoreVO.IS_APPLICATION_CLOSING = true;
			
			if(!timedOutClosingLanguageServers && model.languageServerCore.connectedProjectCount > 0)
			{
				timedOutClosingLanguageServers = false;
				dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onLanguageServerClosed);
				//if something goes wrong shutting down the language servers,
				//this timeout allows us to quit anyway
				languageServerTimeoutID = setTimeout(onLanguageServerCloseTimeout, 10000);
				return;
			}

			if(languageServerTimeoutID != uint.MAX_VALUE)
			{
				clearTimeout(languageServerTimeoutID);
			}
			
			// gradle daemon closing
			if (!isGradleDaemonClosed)
			{
				dispatcher.addEventListener(GradleBuildEvent.GRADLE_DAEMON_CLOSED, onGradleDaemonClosed);
				dispatcher.dispatchEvent(new Event(GradleBuildEvent.STOP_GRADLE_DAEMON));
				return;
			}

			LayoutModifier.saveLastSidebarState();
			
			// we also needs to close any scope bookmarked opened
			CONFIG::OSX
			{
				var tmpText:String = model.fileCore.getSSBInterface().closeAllPaths();
				if (tmpText == "Closed Scoped Paths.")
				{
                    model.fileCore.getSSBInterface().dispose();
					FlexGlobals.topLevelApplication.stage.nativeWindow.close();
				}
				
				return;
			}
			
			// for non-CONFIG:OSX
			FlexGlobals.topLevelApplication.stage.nativeWindow.close();
		}
		
		private function askToSave(num:int):void
		{
			if (pop) return;
			pop = new StandardPopup();
			pop.data = this; // Keep the command from getting GC'd
			if (model.editors.length == 1)
			{
				// show this only when there's no individual close alert already showing
				if (model.isIndividualCloseTabAlertShowing) 
				{
					pop = null;
					return;
				}
				
				pop.text = model.editors[0].label + " is changed.";
			}
			else
			{
				// show this but by closing any existing individual close alert first
				if (model.isIndividualCloseTabAlertShowing) dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_DISMISS_INDIVIDUAL_TAB_CLOSE_ALERT, null));
				
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
			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_NO_MENU_STATE));
		}

		private function onLanguageServerClosed(event:ProjectEvent):void
		{
			if(model.languageServerCore.connectedProjectCount > 0)
			{
				//keep waiting for the rest of them to close
				return;
			}
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onLanguageServerClosed);
			this.onApplicationClosing();
		}
		
		private function onGradleDaemonClosed(event:Event):void
		{
			dispatcher.removeEventListener(GradleBuildEvent.GRADLE_DAEMON_CLOSED, onGradleDaemonClosed);
			
			isGradleDaemonClosed = true;
			this.onApplicationClosing();
		}

		private function onLanguageServerCloseTimeout():void
		{
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_CLOSED, onLanguageServerClosed);
			languageServerTimeoutID = uint.MAX_VALUE;
			timedOutClosingLanguageServers = true;
			this.onApplicationClosing();
		}
		
		private function onApplicationResized(event:ResizeEvent):void
		{
			if (pop) pop.x = (FlexGlobals.topLevelApplication.width-pop.width)/2;
		}
		
		private function saveFiles(event:Event):void
		{
			cleanUp();
			
			var saveAs:Boolean;
			var editors:Array = model.editors.source.concat();
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
						dispatcher.dispatchEvent(
							new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
						);
					}
				}
				else
				{
					tab.save();
					dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, tab as DisplayObject)
					);
				}
			}
			
			if (!saveAs)
			{
				onApplicationClosing();
			}
		}
		
		private function closeFiles(event:Event):void
		{
			onApplicationClosing();
		}
		
		private function cancelQuit(event:Event):void
		{
			cleanUp();	
		}
		
		private function cleanUp():void
		{
			if (pop)
			{
                cleanUpQuitPopup();

				FlexGlobals.topLevelApplication.removeEventListener(ResizeEvent.RESIZE, onApplicationResized);
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));
				PopUpManager.removePopUp(pop);
				pop.data = null;
				pop = null;
			}
		}

		private function saveStateOfQuitPopup():void
		{
			if (!quitPopup.doNotAskMeAgain) return;

			var settings:Vector.<ISetting> = Vector.<ISetting>([
				new BooleanSetting({confirmApplicationExit: false}, "confirmApplicationExit", "")
			]);

			model.confirmApplicationExit = false;
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugin.actionscript.as3project.save::SaveFilesPlugin", settings));
        }

		private function cleanUpQuitPopup():void
		{
			if (!quitPopup) return;

            quitPopup.removeEventListener(Event.CLOSE, onQuitPopupClose);
            quitPopup.removeEventListener("quitConfirmed", onQuitPopupConfirmed);
            quitPopup = null;
		}
	}
}