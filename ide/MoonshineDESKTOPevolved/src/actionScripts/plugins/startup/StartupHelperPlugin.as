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
package actionScripts.plugins.startup
{
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SdkEvent;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.impls.IHelperMoonshineBridgeImp;
	import actionScripts.managers.InstallerItemsManager;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.PluginSetting;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.feathersWrapper.help.GettingStartedViewWrapper;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.views.HelperViewWrapper;
	import actionScripts.utils.EnvironmentUtils;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.SDKInstallerPolling;
	import actionScripts.utils.SDKUtils;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.SDKReferenceVO;
	
	import components.popup.GettingStartedPopup;
	import components.popup.JavaPathSetupPopup;
	import components.popup.SDKUnzipConfirmPopup;
	
	import moonshine.components.HelperView;
	import moonshine.events.HelperEvent;
	import moonshine.plugin.help.view.GettingStartedView;
	
	public class StartupHelperPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Startup Helper Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Startup Helper Plugin."; }
		
		public static const EVENT_GETTING_STARTED:String = "gettingStarted";
		public static const EVENT_GETTING_STARTED_AS3:String = "gettingStartedAS3";
		
		private var dependencyCheckUtil:IHelperMoonshineBridgeImp = new IHelperMoonshineBridgeImp();
		private var installerItemsManager:InstallerItemsManager = InstallerItemsManager.getInstance();
		private var sdkNotificationView:SDKUnzipConfirmPopup;
		private var ccNotificationView:JavaPathSetupPopup;
		private var gettingStartedPopup:GettingStartedPopup;
		private var environmentUtil:EnvironmentUtils;
		private var isSDKSetupShowing:Boolean;
		private var gettingStartedViewWrapper:GettingStartedViewWrapper;
		private var gettingStartedView:GettingStartedView;
		
		private var javaSetupPathTimeout:uint;
		private var startHelpingTimeout:uint;
		private var didShowPreviouslyOpenedTabs:Boolean;
		
		private var _isAllDependenciesPresent:Boolean = true;
		private function set isAllDependenciesPresent(value:Boolean):void
		{
			_isAllDependenciesPresent = value;
		}
		private function get isAllDependenciesPresent():Boolean
		{
			return _isAllDependenciesPresent;
		}
		
		/**
		 * INITIATOR
		 */
		override public function activate():void
		{
			super.activate();
			
			// we want this to be work in desktop version only
			if (!ConstantsCoreVO.IS_AIR) return;
			
			dispatcher.addEventListener(StartupHelperEvent.EVENT_RESTART_HELPING, onRestartRequest, false, 0, true);
			dispatcher.addEventListener(EVENT_GETTING_STARTED_AS3, onGettingStartedRequest, false, 0, true);
			dispatcher.addEventListener(EVENT_GETTING_STARTED, onGettingStartedHaxeRequest, false, 0, true);
			dispatcher.addEventListener(HelperConstants.WARNING, onWarningUpdated, false, 0, true);
			dispatcher.addEventListener(InvokeEvent.INVOKE, onInvokeEventFired, false, 0, true);
			
			// event listner to open up #sdk-extended from File in OSX
			CONFIG::OSX
			{
				//dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_SETUP_REQUEST, onSDKSetupRequest, false, 0, true);
				dispatcher.addEventListener(StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST, onMoonshineHelperDownloadRequest, false, 0, true);
			}

			SDKUtils.initBundledSDKs();
			preInitHelping();
		}
		
		override public function resetSettings():void
		{
			if (gettingStartedPopup)
			{
				dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, gettingStartedPopup));
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  SDKs DETECTION AND RELATED
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Pre-initialization helping process
		 */
		private function preInitHelping():void
		{
			clearTimeout(startHelpingTimeout);
			
			// env.variable parsing only available for Windows
			if (!ConstantsCoreVO.IS_MACOS)
			{
				environmentUtil = new EnvironmentUtils();
				addEventListenersToEnvironmentUtil();
				environmentUtil.readValues();
			}
			else
			{
				continueOnHelping();
			}
		}
		
		/**
		 * Starts the checks and starup sequences
		 * to setup SDK, Java etc.
		 */
		private function startHelping():void
		{
			clearTimeout(startHelpingTimeout);
			startHelpingTimeout = 0;
			
			toggleListenersInstallerItemsManager(true);
			
			HelperConstants.IS_MACOS = ConstantsCoreVO.IS_MACOS;
			installerItemsManager.dependencyCheckUtil = dependencyCheckUtil;
			installerItemsManager.environmentUtil = environmentUtil;
			installerItemsManager.loadItemsAndDetect();
			
			if (!didShowPreviouslyOpenedTabs)
			{
				didShowPreviouslyOpenedTabs = true;
				var timeoutValue:uint = setTimeout(function():void
				{
					clearTimeout(timeoutValue);
					dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SHOW_PREVIOUSLY_OPENED_PROJECTS));
				}, 2000);
			}
		}
		
		/**
		 * On any items found not installed by the installer
		 */
		private function onComponentNotDownloadedEvent(event:HelperEvent):void
		{
			isAllDependenciesPresent = false;
			PathSetupHelperUtil.updateFieldPath((event.data as ComponentVO).type, null);
			onPostDetectionEvent(event.data as ComponentVO);
		}
		
		private function onAnyComponentDownloaded(event:HelperEvent):void
		{
			// autoset moonshine internal fields as appropriate
			var component:ComponentVO = event.data as ComponentVO;
			PathSetupHelperUtil.updateFieldPath(component.type, component.installToPath);
			onPostDetectionEvent(component);
		}
		
		/**
		 * When all the items complete testing by the installer
		 */
		private function onAllComponentTestedEvent(event:HelperEvent):void
		{
			toggleListenersInstallerItemsManager(false);
			checkDefaultSDK();
			
			if (!isAllDependenciesPresent && !ConstantsCoreVO.IS_GETTING_STARTED_DNS)
			{
				openOrFocusGettingStartedHaxe();
			}
		}
		
		/**
		 * Post-detection event against individual
		 * component tested by sdk installer
		 */
		private function onPostDetectionEvent(item:ComponentVO):void
		{
			var isPresent:Boolean;
			switch (item.type)
			{
				case ComponentTypes.TYPE_FLEX:
				case ComponentTypes.TYPE_FLEX_HARMAN:
				case ComponentTypes.TYPE_FEATHERS:
				case ComponentTypes.TYPE_FLEXJS:
				case ComponentTypes.TYPE_ROYALE:
					isPresent = dependencyCheckUtil.isDefaultSDKPresent();
					if (!isPresent)
					{
						isAllDependenciesPresent = false;
						showNoSDKStripAndListenForDefaultSDK();
					}
					break;
				case ComponentTypes.TYPE_OPENJAVA:
					isPresent = dependencyCheckUtil.isJavaPresent();
					if (isPresent && !dispatcher.hasEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK))
					{
						// starting server
						dispatcher.addEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK, onTypeaheadFailedDueToSDK);
					}
					break;
			}
		}
		
		/**
		 * Checks default SDK to Moonshine
		 */
		private function checkDefaultSDK():void
		{
			var isPresent:Boolean = dependencyCheckUtil.isDefaultSDKPresent();
			if (!isPresent)
			{
				// in case of no default sdk set by
				// sdk installer default location or system
				// environment variable, and if a relevant sdk
				// exists in sdk-list, set it
				if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFlexSDKAvailable(), ComponentTypes.TYPE_FLEX)) return;
				if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFlexJSSDKAvailable(), ComponentTypes.TYPE_FLEXJS)) return;
				if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isRoyaleSDKAvailable(), ComponentTypes.TYPE_ROYALE)) return;
				if (checkAndSetDefaultSDKObject(dependencyCheckUtil.isFeathersSDKAvailable(), ComponentTypes.TYPE_FEATHERS)) return;
			}
			
			/*
			* @local
			*/
			function checkAndSetDefaultSDKObject(value:Object, type:String):Boolean
			{
				if (value) 
				{
					PathSetupHelperUtil.updateFieldPath(type, (value as SDKReferenceVO).path);
					return true;
				}
				return false;
			}
		}
		
		/**
		 * Add or remove listeners from itemsManager
		 */
		private function toggleListenersInstallerItemsManager(toggle:Boolean):void
		{
			if (toggle)
			{
				installerItemsManager.addEventListener(HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded);
				installerItemsManager.addEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
				installerItemsManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
			}
			else
			{
				installerItemsManager.removeEventListener(HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded);
				installerItemsManager.removeEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
				installerItemsManager.removeEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
			}
		}
		
		private function continueOnHelping():void
		{
			// just a little delay to see things visually right
			removeEventListenersFromEnvironmentUtil();
			startHelpingTimeout = setTimeout(startHelping, 1000);
			copyToLocalStoragePayaraEmbededLauncher();
		}
		
		private function addEventListenersToEnvironmentUtil():void
		{
			environmentUtil.addEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvironmentVariableReadCompleted);
			environmentUtil.addEventListener(EnvironmentUtils.ENV_READ_ERROR, onEnvironmentVariableReadError);
		}
		
		private function removeEventListenersFromEnvironmentUtil():void
		{
			if (!environmentUtil) return;
			
			environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_COMPLETED, onEnvironmentVariableReadCompleted);
			environmentUtil.removeEventListener(EnvironmentUtils.ENV_READ_ERROR, onEnvironmentVariableReadError);
		}
		
		private function onEnvironmentVariableReadError(event:HelperEvent):void
		{
			error("Unable to read environment variable: "+ (event.data as String));
			continueOnHelping();
		}
		
		private function onEnvironmentVariableReadCompleted(event:Event):void
		{
			continueOnHelping();
		}
		
		//--------------------------------------------------------------------------
		//
		//  GETTING-STARTED TAB
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On getting started menu item
		 */
		private function onGettingStartedRequest(event:Event):void
		{
			openOrFocusGettingStarted();
			startHelpingTimeout = setTimeout(preInitHelping, 300);
		}
		
		/**
		 * On getting started menu item
		 */
		private function onGettingStartedHaxeRequest(event:Event):void
		{
			openOrFocusGettingStartedHaxe();
			startHelpingTimeout = setTimeout(preInitHelping, 300);
		}
		
		/**
		 * Opens or focus Getting Started tab
		 */
		private function openOrFocusGettingStarted():void
		{
			if (!gettingStartedPopup)
			{
				gettingStartedPopup = new GettingStartedPopup;
				gettingStartedPopup.dependencyCheckUtil = dependencyCheckUtil;
				gettingStartedPopup.environmentUtil = environmentUtil;
				gettingStartedPopup.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed, false, 0, true);
				
				// start polling only in case of Windows
				togglePolling(true);
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(gettingStartedPopup as IContentWindow)
				);
			}
			else
			{
				model.activeEditor = gettingStartedPopup;
			}
		}
		
		/**
		 * Opens or focus Getting Started tab
		 */
		private function openOrFocusGettingStartedHaxe():void
		{
			if (!gettingStartedView)
			{
				var ps:PluginSetting = new PluginSetting(ConstantsCoreVO.MOONSHINE_IDE_LABEL +" is Installed. What's Next?", ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team", "Moonshine includes an extensive set of features by default. Some optional features (shown below) require access to third-party software. If you already have the third-party software installed, press the Configure button, otherwise press Download button.", false);
				gettingStartedView = new GettingStartedView();
				gettingStartedView.setting = ps;

				// HelperView initialize get called before
				// HelperViewWrapper could set the value to const
				HelperConstants.IS_RUNNING_IN_MOON = true;
				
				var tmpHelperViewWrapper:HelperViewWrapper = new HelperViewWrapper(new HelperView());
				tmpHelperViewWrapper.isRunningInsideMoonshine = HelperConstants.IS_RUNNING_IN_MOON;
				tmpHelperViewWrapper.dependencyCheckUtil = dependencyCheckUtil;
				tmpHelperViewWrapper.environmentUtil = environmentUtil;
				gettingStartedView.helperView = tmpHelperViewWrapper.feathersUIControl;
				
				gettingStartedViewWrapper = new GettingStartedViewWrapper(gettingStartedView);
				gettingStartedViewWrapper.percentWidth = 100;
				gettingStartedViewWrapper.percentHeight = 100;
				gettingStartedViewWrapper.minWidth = 0;
				gettingStartedViewWrapper.minHeight = 0;

				gettingStartedViewWrapper.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedHaxeClosed, false, 0, true);
				
				// start polling only in case of Windows
				//togglePolling(true);
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(gettingStartedViewWrapper as IContentWindow)
				);
				
				// since we're not attaching the HelperViewWrapper to
				// the displayObject physically, we need call its 
				// initialize() manually to start its operation.
				tmpHelperViewWrapper.initialize();
			}
			else
			{
				model.activeEditor = gettingStartedViewWrapper;
			}
		}
		
		/**
		 * On getting started closed
		 */
		private function onGettingStartedClosed(event:Event):void
		{
			// polling only in case of Windows
			togglePolling(false);
			
			gettingStartedPopup.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed);
			gettingStartedPopup = null;
		}
		
		private function onGettingStartedHaxeClosed(event:Event):void
		{
			gettingStartedViewWrapper.dispose();
			gettingStartedViewWrapper.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedHaxeClosed);
			gettingStartedView = null;
			gettingStartedViewWrapper = null;
		}
		
		/**
		 * Start/remove Windows polling
		 */
		private function togglePolling(start:Boolean):void
		{
			if (!ConstantsCoreVO.IS_MACOS) 
			{
				if (start)
				{
					dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION, onInstallerFileNotifierFound, false, 0, true);
					SDKInstallerPolling.getInstance().startPolling();
				}
				else
				{
					dispatcher.removeEventListener(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION, onInstallerFileNotifierFound);
					SDKInstallerPolling.getInstance().stopPolling();
					
					gettingStartedPopup.dispose();
				}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  GETTING-STARTED UPDATE API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * In case of polling only on Windows
		 */
		private function onInstallerFileNotifierFound(event:StartupHelperEvent):void
		{
			onInvokeEventFired(null);
		}
		
		/**
		 * To listen updates from SDK Installer
		 */
		private function onInvokeEventFired(event:InvokeEvent):void
		{
			var updateNotifierFile:File = HelperConstants.HELPER_STORAGE.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);
			if (updateNotifierFile.exists)
			{
				var type:String;
				var path:String;
				var pathValidation:String;
				var notifierValue:XML = new XML(FileUtils.readFromFile(updateNotifierFile) as String);
				for each (var item:XML in notifierValue.items.item)
				{
					type = String(item.@type);
					path = String(item.path);
					pathValidation = String(item.pathValidation);
					
					// validate before set
					if (type == ComponentTypes.TYPE_GIT || type == ComponentTypes.TYPE_SVN) pathValidation = null;
					if (!HelperUtils.isValidSDKDirectoryBy(type, path, pathValidation)) continue;
					
					if ((type == ComponentTypes.TYPE_GIT || type == ComponentTypes.TYPE_SVN) && ConstantsCoreVO.IS_MACOS)
					{
						updateGitAndSVN(path);
					}
					else
					{
						if (!gettingStartedPopup)
						{
							PathSetupHelperUtil.updateFieldPath(type, path);
						}
						else
						{
							gettingStartedPopup.onInvokeEvent(type, path);
						}
					}
				}
			}
		}
		
		/**
		 * When getting warning updates
		 */
		private function onWarningUpdated(event:HelperEvent):void
		{
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(event.data.type);
			if (tmpComponent) tmpComponent.hasWarning = event.data.message;
		}
		
		/**
		 * Multiple component update requirement
		 */
		private function updateGitAndSVN(path:String):void
		{
			if (!gettingStartedPopup)
			{
				PathSetupHelperUtil.updateFieldPath(ComponentTypes.TYPE_GIT, path);
				PathSetupHelperUtil.updateFieldPath(ComponentTypes.TYPE_SVN, path);
			}
			else
			{
				gettingStartedPopup.onInvokeEvent(ComponentTypes.TYPE_GIT, path);
				gettingStartedPopup.onInvokeEvent(ComponentTypes.TYPE_SVN, path);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Opening SDK notification prompt
		 */
		private function triggerSDKNotificationView(showAsDownloader:Boolean, showAsRequiresSDKNotif:Boolean):void
		{
			sdkNotificationView = new SDKUnzipConfirmPopup;
			sdkNotificationView.showAsHelperDownloader = showAsDownloader;
			sdkNotificationView.horizontalCenter = sdkNotificationView.verticalCenter = 0;
			sdkNotificationView.addEventListener(Event.CLOSE, onSDKNotificationClosed, false, 0, true);
			FlexGlobals.topLevelApplication.addElement(sdkNotificationView);
		}
		
		/**
		 * Opens Java detection etc. for code-completion prompt
		 */
		private function triggerJavaSetupViewWithParam(showAsRequiresSDKNotif:Boolean):void
		{
			clearTimeout(javaSetupPathTimeout);
			javaSetupPathTimeout = 0;
			
			ccNotificationView = new JavaPathSetupPopup();
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
			dispatcher.dispatchEvent(new Event(SdkEvent.CHANGE_SDK));
			// in case of Windows, we open-up MXMLC Plugin section and shall
			// wait for the user to add/download a default SDK
			//sequenceIndex --;
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
		}
		
		/**
		 * To restart helping process
		 */
		private function onRestartRequest(event:StartupHelperEvent):void
		{
			sdkNotificationView = null;
			ccNotificationView = null;
			isSDKSetupShowing = false;
			ConstantsCoreVO.IS_OSX_CODECOMPLETION_PROMPT = false;
			
			preInitHelping();
		}
		
		/**
		 * On SDK notification prompt close
		 */
		private function onSDKNotificationClosed(event:Event):void
		{
			var wasShowingAsHelperDownloaderOnly:Boolean = sdkNotificationView.showAsHelperDownloader;
			
			sdkNotificationView.removeEventListener(Event.CLOSE, onSDKNotificationClosed);
			FlexGlobals.topLevelApplication.removeElement(sdkNotificationView);
			
			var isSDKSetupSectionOpened:Boolean = sdkNotificationView.isSDKSetupSectionOpened;
			sdkNotificationView = null;
			
			if (wasShowingAsHelperDownloaderOnly) return;
			
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
		 * During code-completion server started and
		 * required SDK removed from SDK list
		 */
		private function onTypeaheadFailedDueToSDK(event:StartupHelperEvent):void
		{
			triggerJavaSetupViewWithParam(true);
		}
		
		/**
		 * When settings tab closed after default SDK setup
		 * done in Windows process
		 */
		private function onSettingsTabClosed(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				var tmpEvent:CloseTabEvent = event as CloseTabEvent;
				if ((tmpEvent.tab is SettingsView) && (SettingsView(tmpEvent.tab).longLabel == "Settings") && SettingsView(tmpEvent.tab).isSaved)
				{
					dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, onSettingsTabClosed);
				}
			}
		}
		
		/**
		 * On helper application download requrest from File menu
		 * in OSX
		 */
		private function onSDKSetupRequest(event:StartupHelperEvent):void
		{
			//sequenceIndex = -1;
			checkDefaultSDK();
		}
		
		/**
		 * On Moonshine App Store Helper request from top menu
		 */
		private function onMoonshineHelperDownloadRequest(event:Event):void
		{
			triggerSDKNotificationView(true, false);
		}
		
		private function copyToLocalStoragePayaraEmbededLauncher():void
		{
			var payaraLocation:String = "elements".concat(model.fileCore.separator, "projects", model.fileCore.separator, "PayaraEmbeddedLauncher");
			var payaraAppPath:FileLocation = model.fileCore.resolveApplicationDirectoryPath(payaraLocation);
			model.payaraServerLocation = model.fileCore.resolveApplicationStorageDirectoryPath("projects".concat(model.fileCore.separator, "PayaraEmbeddedLauncher"));
			try
			{
				payaraAppPath.fileBridge.copyTo(model.payaraServerLocation, true);
			}
			catch (e:Error)
			{
				warning("Problem with updating PayaraEmbeddedLauncher %s", e.message);
			}
		}
	}
}