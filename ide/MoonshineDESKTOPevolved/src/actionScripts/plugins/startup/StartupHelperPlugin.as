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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.HelperEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SdkEvent;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.impls.IHelperMoonshineBridgeImp;
	import actionScripts.managers.InstallerItemsManager;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.EnvironmentUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.SDKInstallerPolling;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.SDKTypes;
	
	import components.popup.GettingStartedPopup;
	import components.popup.JavaPathSetupPopup;
	import components.popup.SDKUnzipConfirmPopup;
	
	public class StartupHelperPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Startup Helper Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Startup Helper Plugin. Esc exits."; }
		
		public static const EVENT_GETTING_STARTED:String = "gettingStarted";
		
		private static const CC_JAVA:String = "CC_JAVA";
		private static const CC_SDK:String = "CC_SDK";
		private static const CC_ANT:String = "CC_ANT";
		private static const CC_MAVEN:String = "CC_MAVEN";
		private static const CC_GIT:String = "CC_GIT";
		private static const CC_SVN:String = "CC_SVN";
		private static const CC_OTHER:String = "CC_OTHER";
		
		private var dependencyCheckUtil:IHelperMoonshineBridgeImp = new IHelperMoonshineBridgeImp();
		private var installerItemsManager:InstallerItemsManager = InstallerItemsManager.getInstance();
		private var sdkNotificationView:SDKUnzipConfirmPopup;
		private var ccNotificationView:JavaPathSetupPopup;
		private var gettingStartedPopup:GettingStartedPopup;
		private var environmentUtil:EnvironmentUtils;
		private var sequences:Array;
		private var isSDKSetupShowing:Boolean;
		
		private var javaSetupPathTimeout:uint;
		private var startHelpingTimeout:uint;
		private var changeMenuSDKTimeout:uint;
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
			dispatcher.addEventListener(EVENT_GETTING_STARTED, onGettingStartedRequest, false, 0, true);
			dispatcher.addEventListener(HelperConstants.WARNING, onWarningUpdated, false, 0, true);
			dispatcher.addEventListener(InvokeEvent.INVOKE, onInvokeEventFired, false, 0, true);
			
			// event listner to open up #sdk-extended from File in OSX
			CONFIG::OSX
				{
					dispatcher.addEventListener(StartupHelperEvent.EVENT_SDK_SETUP_REQUEST, onSDKSetupRequest, false, 0, true);
					dispatcher.addEventListener(StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST, onMoonshineHelperDownloadRequest, false, 0, true);
				}
				
				preInitHelping();
		}
		
		override public function resetSettings():void
		{
			if (gettingStartedPopup)
			{
				dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, gettingStartedPopup));
			}
		}
		
		/**
		 * Pre-initialization helping process
		 */
		private function preInitHelping():void
		{
			clearTimeout(startHelpingTimeout);
			sequences = [CC_SDK, CC_JAVA, CC_ANT, CC_MAVEN, CC_GIT, CC_SVN, CC_OTHER];
			
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
			
			if (sequences.length == 0)
			{
				// if we have a reason to open Getting Started tab
				if (!isAllDependenciesPresent && !ConstantsCoreVO.IS_GETTING_STARTED_DNS) 
					openOrFocusGettingStarted();
				return;
			}
			
			var tmpSequence:String = sequences.shift();
			switch(tmpSequence)
			{
				case CC_SDK:
				{
					checkDefaultSDK();
					break;
				}
				case CC_JAVA:
				{
					checkJavaPathPresenceForTypeahead();
					break;
				}
				case CC_ANT:
				{
					checkAntPathPresence();
					break;
				}
				case CC_MAVEN:
				{
					checkMavenPathPresence();
					break;
				}
				case CC_GIT:
				{
					checkGitPathPresence();
					break;
				}
				case CC_SVN:
				{
					checkSVNPathPresence();
					break;
				}
				case CC_OTHER:
				{
					checkOtherPendingItems();
					break;	
				}
			}
			
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
		 * Checks default SDK to Moonshine
		 */
		private function checkDefaultSDK(forceShow:Boolean=false):void
		{
			var isPresent:Boolean = dependencyCheckUtil.isDefaultSDKPresent();
			if (!isPresent && (!ConstantsCoreVO.IS_MACOS || (ConstantsCoreVO.IS_MACOS && (!ConstantsCoreVO.IS_SDK_HELPER_PROMPT_DNS || forceShow))))
			{
				//triggerSDKNotificationView(false, false);
				
				// check if env.variable has any FLEX_HOME found or not
				if (environmentUtil && environmentUtil.environments.FLEX_HOME)
				{
					// set as default SDK
					PathSetupHelperUtil.updateFieldPath(SDKTypes.FLEX, environmentUtil.environments.FLEX_HOME.path.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
				}
			}
			else if (!isPresent)
			{
				// lets show up the default sdk requirement strip at bottom
				changeMenuSDKTimeout = setTimeout(function():void
				{
					clearTimeout(changeMenuSDKTimeout);
					isAllDependenciesPresent = false;
					showNoSDKStripAndListenForDefaultSDK();
				}, 1000);
			}
			
			startHelping();
		}
		
		/**
		 * Checks code-completion Java presence
		 */
		private function checkJavaPathPresenceForTypeahead():void
		{
			var isPresent:Boolean = dependencyCheckUtil.isJavaPresent();
			if (!isPresent && !ccNotificationView && !isSDKSetupShowing)
			{
				// check if env.variable has JAVA_HOME with JDK setup
				if (environmentUtil && environmentUtil.environments.JAVA_HOME)
				{
					PathSetupHelperUtil.updateFieldPath(SDKTypes.OPENJAVA, environmentUtil.environments.JAVA_HOME.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
					model.javaPathForTypeAhead = null;
				}
				//javaSetupPathTimeout = setTimeout(triggerJavaSetupViewWithParam, 1000, false);
			}
			else if (isPresent)
			{
				// starting server
				dispatcher.addEventListener(StartupHelperEvent.EVENT_TYPEAHEAD_REQUIRES_SDK, onTypeaheadFailedDueToSDK);
			}
			
			startHelping();
		}
		
		/**
		 * Checks internal Ant path
		 */
		private function checkAntPathPresence():void
		{
			if (!dependencyCheckUtil.isAntPresent())
			{
				if (environmentUtil && environmentUtil.environments.ANT_HOME)
				{
					PathSetupHelperUtil.updateFieldPath(SDKTypes.ANT, environmentUtil.environments.ANT_HOME.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
				}
			}
			
			startHelping();
		}
		
		/**
		 * Checks internal Maven path
		 */
		private function checkMavenPathPresence():void
		{
			if (!dependencyCheckUtil.isMavenPresent())
			{
				if (environmentUtil && environmentUtil.environments.MAVEN_HOME)
				{
					PathSetupHelperUtil.updateFieldPath(SDKTypes.MAVEN, environmentUtil.environments.MAVEN_HOME.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
				}
			}
			
			startHelping();
		}
		
		/**
		 * Checks internal Git path
		 */
		private function checkGitPathPresence():void
		{
			if (!dependencyCheckUtil.isGitPresent())
			{
				if (environmentUtil && environmentUtil.environments.GIT_HOME)
				{
					PathSetupHelperUtil.updateFieldPath(SDKTypes.GIT, environmentUtil.environments.GIT_HOME.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
				}
			}
			
			startHelping();
		}
		
		/**
		 * Checks internal SVN path
		 */
		private function checkSVNPathPresence():void
		{
			if (!dependencyCheckUtil.isSVNPresent())
			{
				if (environmentUtil && environmentUtil.environments.SVN_HOME)
				{
					PathSetupHelperUtil.updateFieldPath(SDKTypes.SVN, environmentUtil.environments.SVN_HOME.nativePath);
				}
				else
				{
					isAllDependenciesPresent = false;
				}
			}
			
			startHelping();
		}
		
		/**
		 * Checks if any other items are pending from install
		 * in SDK Installer list
		 */
		private function checkOtherPendingItems():void
		{
			// if something already found not installed
			// do not run this - not installed items will anyway
			// display when getting started tab;
			// also do not execute when user choose not to
			// see getting started information
			if (isAllDependenciesPresent && !ConstantsCoreVO.IS_GETTING_STARTED_DNS)
			{
				toggleListenersInstallerItemsManager(true);
				
				HelperConstants.IS_MACOS = ConstantsCoreVO.IS_MACOS;
				installerItemsManager.dependencyCheckUtil = dependencyCheckUtil;
				installerItemsManager.environmentUtil = environmentUtil;
				
				installerItemsManager.loadItemsAndDetect();
			}
			else
			{
				startHelping();
			}
		}
		
		/**
		 * On any items found not installed by the installer
		 */
		private function onComponentNotDownloadedEvent(event:HelperEvent):void
		{
			toggleListenersInstallerItemsManager(false);
			isAllDependenciesPresent = false;
			startHelping();
		}
		
		/**
		 * When all the items complete testing by the installer
		 */
		private function onAllComponentTestedEvent(event:HelperEvent):void
		{
			toggleListenersInstallerItemsManager(false);
			startHelping();
		}
		
		/**
		 * Add or remove listeners from itemsManager
		 */
		private function toggleListenersInstallerItemsManager(toggle:Boolean):void
		{
			if (toggle)
			{
				installerItemsManager.addEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
				installerItemsManager.addEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
			}
			else
			{
				installerItemsManager.removeEventListener(HelperEvent.COMPONENT_NOT_DOWNLOADED, onComponentNotDownloadedEvent);
				installerItemsManager.removeEventListener(HelperEvent.ALL_COMPONENTS_TESTED, onAllComponentTestedEvent);
			}
		}
		
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
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------

		private function onEnvironmentVariableReadError(event:HelperEvent):void
		{
			error("Unable to read environment variable: "+ (event.value as String));
			continueOnHelping();
		}

		private function onEnvironmentVariableReadCompleted(event:Event):void
		{
			continueOnHelping();
		}

		/**
		 * To restart helping process
		 */
		private function onRestartRequest(event:StartupHelperEvent):void
		{
			sdkNotificationView = null;
			ccNotificationView = null;
			sequences = null;
			isSDKSetupShowing = false;
			ConstantsCoreVO.IS_OSX_CODECOMPLETION_PROMPT = false;
			
			preInitHelping();
		}
		
		/**
		 * On getting started menu item
		 */
		private function onGettingStartedRequest(event:Event):void
		{
			openOrFocusGettingStarted();
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
		 * On getting started closed
		 */
		private function onGettingStartedClosed(event:Event):void
		{
			// polling only in case of Windows
			togglePolling(false);
			
			gettingStartedPopup.removeEventListener(CloseTabEvent.EVENT_TAB_CLOSED, onGettingStartedClosed);
			gettingStartedPopup = null;
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
					startHelping();
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
			checkDefaultSDK(true);
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
			var updateNotifierFile:FileLocation = model.fileCore.resolveApplicationStorageDirectoryPath("MoonshineHelperNewUpdate.xml");
			if (updateNotifierFile.fileBridge.exists)
			{
				var type:String;
				var path:String;
				var pathValidation:String;
				var notifierValue:XML = new XML(updateNotifierFile.fileBridge.read() as String);
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
			if (!gettingStartedPopup)
			{
				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
			}
			else
			{
				gettingStartedPopup.onWarningUpdate(event);
			}
		}
		
		/**
		 * Multiple component update requirement
		 */
		private function updateGitAndSVN(path:String):void
		{
			var gitComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
			var svnComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);
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
	}
}