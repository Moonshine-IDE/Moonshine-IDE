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
package actionScripts.ui.feathersWrapper.help
{
	import actionScripts.plugins.domino.DominoPlugin;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.utils.PathSetupHelperUtil;

	import flash.events.Event;

	import moonshine.events.HelperEvent;

	import mx.controls.Alert;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.interfaces.IViewWithTitle;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.IContentWindow;
	import actionScripts.utils.MSDKIdownloadUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ComponentVO;
	import actionScripts.valueObjects.ComponentTypes;
	import actionScripts.utils.HelperUtils;
	
	import air.update.events.DownloadErrorEvent;
	
	import moonshine.plugin.help.events.GettingStartedViewEvent;
	import moonshine.plugin.help.view.GettingStartedView;
	
	public class GettingStartedViewWrapper extends FeathersUIWrapper implements IViewWithTitle, IContentWindow
	{
		private static const LABEL:String = "Getting Started";
		
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var msdkiDownloadUtil:MSDKIdownloadUtil = MSDKIdownloadUtil.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  CLASS API
		//
		//--------------------------------------------------------------------------
		
		public function GettingStartedViewWrapper(feathersUIControl:GettingStartedView=null)
		{
			super(feathersUIControl);
		}
		
		override public function initialize():void
		{
			super.initialize();
			this.feathersUIControl.addEventListener(
				GettingStartedView.EVENT_DOWNLOAD_3RDPARTY_SOFTWARE, onDownload3rdPartySoftware,
				false, 0, true);
			this.feathersUIControl.addEventListener(
				GettingStartedViewEvent.EVENT_DO_NOT_SHOW, onDoNotShowCheckboxChanged,
				false, 0, true
			);

			// events from the HelperView
			(this.feathersUIControl as GettingStartedView).helperView.addEventListener(
					HelperEvent.DOWNLOAD_COMPONENT, onDownload3rdPartySoftware,
					false, 0, true
			);
			(this.feathersUIControl as GettingStartedView).helperView.addEventListener(
					HelperEvent.OPEN_MOON_SETTINGS, onOpenSettings,
					false, 0, true
			);
			(this.feathersUIControl as GettingStartedView).helperView.addEventListener(
					HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded,
					false, 0, true
			);
		}
		
		//--------------------------------------------------------------------------
		//
		//  INTERFACE API
		//
		//--------------------------------------------------------------------------
		
		public function get title():String 		{	return LABEL;	}
		public function get label():String 		{	return LABEL;	}
		public function get longLabel():String 	{	return LABEL;	}
		public function save():void				{}
		public function isChanged():Boolean 	{	return false;	}
		public function isEmpty():Boolean		{	return false;	}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------
		
		public function dispose():void
		{
			this.feathersUIControl.removeEventListener(GettingStartedViewEvent.EVENT_DO_NOT_SHOW, onDoNotShowCheckboxChanged);
			this.feathersUIControl.removeEventListener(GettingStartedView.EVENT_DOWNLOAD_3RDPARTY_SOFTWARE, onDownload3rdPartySoftware);

			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.DOWNLOAD_COMPONENT, onDownload3rdPartySoftware
			);
			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.OPEN_MOON_SETTINGS, onOpenSettings
			);
			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded
			);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function onDoNotShowCheckboxChanged(event:GettingStartedViewEvent):void
		{
			ConstantsCoreVO.IS_GETTING_STARTED_DNS = event.data;
			dispatcher.dispatchEvent(new StartupHelperEvent(StartupHelperEvent.EVENT_DNS_GETTING_STARTED));
		}
		
		private function onDownload3rdPartySoftware(event:Event):void
		{
			if (!ConstantsCoreVO.IS_MACOS)
			{
				if (!msdkiDownloadUtil.is64BitSDKInstallerExists())
				{
					addRemoveInstallerDownloadEvents(true);
					(this.feathersUIControl as GettingStartedView).sdkInstallerInstallingMess = 
						"Moonshine SDK Installer is downloading. Please wait.";
				}
				else
				{
					(this.feathersUIControl as GettingStartedView).sdkInstallerInstallingMess = 
						"Moonshine SDK Installer requested. This may take a few seconds.";
				}
			}
			
			msdkiDownloadUtil.runOrDownloadSDKInstaller();
		}

		private function onOpenSettings(event:HelperEvent):void
		{
			var component:ComponentVO = event.data as ComponentVO;
			if ((component.type == ComponentTypes.TYPE_GIT) && ConstantsCoreVO.IS_MACOS)
			{
				var gitComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);
				var svnComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_SVN);

				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				gitComponent.hasWarning = svnComponent.hasWarning = null;
			}
			else if (component.type == ComponentTypes.TYPE_NOTES && ConstantsCoreVO.IS_MACOS)
			{
				dispatcher.dispatchEvent(new Event(DominoPlugin.RELAY_MAC_NOTES_PERMISSION_REQUEST));
			}
			else
			{
				PathSetupHelperUtil.openSettingsViewFor(component.type);
			}
		}

		private function onAnyComponentDownloaded(event:HelperEvent):void
		{
			// autoset moonshine internal fields as appropriate
			var component:ComponentVO = event.data as ComponentVO;
			PathSetupHelperUtil.updateFieldPath(component.type, component.installToPath);
		}
		
		private function addRemoveInstallerDownloadEvents(add:Boolean):void
		{
			if (add)
			{
				msdkiDownloadUtil.addEventListener(GeneralEvent.DONE, onUnzipCompleted, false, 0, true);
				msdkiDownloadUtil.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onSDKInstallerDownloadError, false, 0, true);
			}
			else
			{
				msdkiDownloadUtil.removeEventListener(GeneralEvent.DONE, onUnzipCompleted);
				msdkiDownloadUtil.removeEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, onSDKInstallerDownloadError);
			}
		}
		
		private function onUnzipCompleted(event:GeneralEvent):void
		{
			(this.feathersUIControl as GettingStartedView).sdkInstallerInstallingMess = null;
			addRemoveInstallerDownloadEvents(false);
		}
		
		private function onSDKInstallerDownloadError(event:DownloadErrorEvent):void
		{
			addRemoveInstallerDownloadEvents(false);
			Alert.show(event.text, "Error!");
		}
	}
}