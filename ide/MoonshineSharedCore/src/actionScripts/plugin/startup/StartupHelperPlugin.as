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
package actionScripts.plugin.startup
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.events.CollectionEvent;
	
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.popup.JavaPathSetupPopup;
	import components.popup.SDKUnzipConfirmPopup;

	public class StartupHelperPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Startup Helper Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Startup Helper Plugin. Esc exits."; }
		
		public static const EVENT_TYPEAHEAD_REQUIRES_SDK:String = "EVENT_TYPEAHEAD_REQUIRES_SDK";
		public static const EVENT_SDK_HELPER_DOWNLOAD_REQUEST:String = "EVENT_SDK_HELPER_DOWNLOAD_REQUEST";
		public static const EVENT_SDK_UNZIP_REQUEST:String = "EVENT_SDK_UNZIP_REQUEST";
		
		private static const SDK_XTENDED:String = "SDK_XTENDED";
		private static const CC_JAVA:String = "CC_JAVA";
		private static const CC_SDK:String = "CC_SDK";
		
		private var sdkNotificationView:SDKUnzipConfirmPopup;
		private var ccNotificationView:JavaPathSetupPopup;
		private var sequences:Array;
		private var sequenceIndex:int = 0;
		private var isSDKSetupShowing:Boolean;
		
		/**
		 * INITIATOR
		 */
		override public function activate():void
		{
			super.activate();
			
			// we want this to be work in desktop version only
			if (!ConstantsCoreVO.IS_AIR) return;
			
			sequences = new Array();
			sequences.push(SDK_XTENDED);
			sequences.push(CC_JAVA);
			sequences.push(CC_SDK);
			
			// just a little delay to see things visually right
			setTimeout(startHelping, 1000);
			
			// event listner to open up #sdk-extended from File in OSX
			CONFIG::OSX
			{
				dispatcher.addEventListener(EVENT_SDK_HELPER_DOWNLOAD_REQUEST, onSDKhelperDownloadRequest, false, 0, true);
			}
		}
		
		/**
		 * Starts the checks and starup sequences
		 * to setup SDK, Java etc.
		 */
		private function startHelping():void
		{
			var tmpSequence:String = sequences[sequenceIndex];
			
			switch(tmpSequence)
			{
				case SDK_XTENDED:
				{
					checkDefaultSDK();
					break;
				}
				case CC_JAVA:
				{
					checkJavaPathPresenceForTypeahead();
					break;
				}
				case CC_SDK:
				{
					checkSDKPrsenceForTypeahead();
					break;
				}
			}
		}
		
		/**
		 * Checks default SDK to Moonshine
		 */
		private function checkDefaultSDK(forceShow:Boolean=false):void
		{
			sequenceIndex++;
			
			if (!model.defaultSDK && (!ConstantsCoreVO.IS_MACOS || (ConstantsCoreVO.IS_MACOS && (!ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS || forceShow))))
			{
				triggerSDKNotificationView(false, false);
			}
			else if (model.defaultSDK)
			{
				// restart rest of the checkings
				startHelping();
			}
			else if (!model.defaultSDK)
			{
				// lets show up the default sdk requirement strip at bottom
				setTimeout(function():void
				{
					dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_SDK_STATE));
				}, 1000);
			}
		}
		
		/**
		 * Checks code-completion Java presence
		 */
		private function checkJavaPathPresenceForTypeahead():void
		{
			sequenceIndex++;
			
			if (!model.javaPathForTypeAhead && !ccNotificationView)
			{
				setTimeout(triggerJavaSetupViewWithParam, 1000, false);
				
				// add the listener only if flexJS 0.7.0+ not present
				/*var path:String = UtilsCore.checkCodeCompletionFlexJSSDK();
				if (!path) model.userSavedSDKs.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSDKListUpdated);*/
			}
			else if (model.javaPathForTypeAhead)
			{
				// restart rest of the checkings
				startHelping();
			}
		}
		
		/**
		 * Checks code-completion sdk requisites
		 */
		private function checkSDKPrsenceForTypeahead():void
		{
			sequenceIndex++;
			
			//var path:String = UtilsCore.checkCodeCompletionFlexJSSDK();
			if (!model.defaultSDK && !ccNotificationView && !isSDKSetupShowing)
			{
				setTimeout(triggerJavaSetupViewWithParam, 1000, true);
			}
			else if (!model.defaultSDK && isSDKSetupShowing)
			{
				showNoSDKStripAndListenForDefaultSDK();
			}
			else if (model.defaultSDK && model.javaPathForTypeAhead)
			{
				// starting server
				model.flexCore.startTypeAheadWithJavaPath(model.javaPathForTypeAhead.fileBridge.nativePath);
				dispatcher.addEventListener(EVENT_TYPEAHEAD_REQUIRES_SDK, onTypeaheadFailedDueToSDK);
			}
		}
		
		/**
		 * Opening SDK notification prompt
		 */
		private function triggerSDKNotificationView(showAsDownloader:Boolean, showAsRequiresSDKNotif:Boolean):void
		{
			sdkNotificationView = new SDKUnzipConfirmPopup;
			sdkNotificationView.horizontalCenter = sdkNotificationView.verticalCenter = 0;
			sdkNotificationView.addEventListener(Event.CLOSE, onSDKNotificationClosed, false, 0, true);
			FlexGlobals.topLevelApplication.addElement(sdkNotificationView);
		}
		
		/**
		 * Opens Java detection etc. for code-completion prompt
		 */
		private function triggerJavaSetupViewWithParam(showAsRequiresSDKNotif:Boolean):void
		{
			ccNotificationView = new JavaPathSetupPopup;
			ccNotificationView.showAsRequiresSDKNotification = showAsRequiresSDKNotif;
			ccNotificationView.horizontalCenter = ccNotificationView.verticalCenter = 0;
			ccNotificationView.addEventListener(Event.CLOSE, onJavaPromptClosed, false, 0, true);
			FlexGlobals.topLevelApplication.addElement(ccNotificationView);
		}
		
		/**
		 * Showing no sdk strip at bottom and also listens for
		 * default SDK setup event
		 */
		private function showNoSDKStripAndListenForDefaultSDK():void
		{
			// lets show up the default sdk requirement strip at bottom
			// at very end of startup prompt being shown
			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_SDK_STATE));
			// in case of Windows, we open-up MXMLC Plugin section and shall
			// wait for the user to add/download a default SDK
			sequenceIndex --;
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On SDK notification prompt close
		 */
		private function onSDKNotificationClosed(event:Event):void
		{
			sdkNotificationView.removeEventListener(Event.CLOSE, onSDKNotificationClosed);
			FlexGlobals.topLevelApplication.removeElement(sdkNotificationView);
			
			var isSDKSetupSectionOpened:Boolean = sdkNotificationView.isSDKSetupSectionOpened;
			sdkNotificationView = null;
			
			// restart rest of the checkings
			if (!isSDKSetupSectionOpened) startHelping();
			else 
			{
				// in case of Windows, we open-up MXMLC Plugin section and shall
				// wait for the user to add/download a default SDK
				dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
			}
		}
		
		/**
		 * On code-completion Java prompt close
		 */
		private function onJavaPromptClosed(event:Event):void
		{
			ccNotificationView.removeEventListener(Event.CLOSE, onJavaPromptClosed);
			FlexGlobals.topLevelApplication.removeElement(ccNotificationView);
			
			var isDiscardedCodeCompletionProcedure:Boolean = ccNotificationView.isDiscarded;
			var showAsRequiresSDKNotif:Boolean = ccNotificationView.showAsRequiresSDKNotification;
			isSDKSetupShowing = ccNotificationView.isSDKSetupShowing;
			ccNotificationView = null;
			
			// restart rest of the checkings
			if (!isDiscardedCodeCompletionProcedure) startHelping();
			else if (!model.defaultSDK && (isDiscardedCodeCompletionProcedure || showAsRequiresSDKNotif))
			{
				showNoSDKStripAndListenForDefaultSDK();
			}
		}
		
		/**
		 * On SDK list updated
		 */
		private function onSDKListUpdated(event:CollectionEvent):void
		{
			var path:String = UtilsCore.checkCodeCompletionFlexJSSDK();
			if (path && model.javaPathForTypeAhead)
			{
				model.userSavedSDKs.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onSDKListUpdated);
				
				// starting server
				model.flexCore.startTypeAheadWithJavaPath(model.javaPathForTypeAhead.fileBridge.nativePath);
			}
			else if (path && !model.javaPathForTypeAhead)
			{
				// if flexJS required SDK added that meets code-completion but Java 
				// prompt the user again if they wants to setup Java?
				triggerJavaSetupViewWithParam(false);
			}
		}
		
		/**
		 * During code-completion server started and
		 * required SDK removed from SDK list
		 */
		private function onTypeaheadFailedDueToSDK(event:Event):void
		{
			triggerJavaSetupViewWithParam(true);
		}
		
		/**
		 * When settings tab closed after default SDK setup
		 * done in Windows process
		 */
		private function onSettingsTabClosed(event:CloseTabEvent):void
		{
			if ((event.tab is SettingsView) && (SettingsView(event.tab).longLabel == "Settings") && SettingsView(event.tab).isSaved)
			{
				dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
				startHelping();
			}
		}
		
		/**
		 * On helper application download requrest from File menu
		 * in OSX
		 */
		private function onSDKhelperDownloadRequest(event:Event):void
		{
			sequenceIndex = 0;
			checkDefaultSDK(true);
		}
	}
}