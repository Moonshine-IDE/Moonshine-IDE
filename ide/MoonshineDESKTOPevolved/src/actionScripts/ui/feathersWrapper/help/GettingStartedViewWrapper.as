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
package actionScripts.ui.feathersWrapper.help
{
	import actionScripts.managers.DetectionManager;
	import actionScripts.plugins.domino.DominoPlugin;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.ui.views.HelperViewWrapper;
	import actionScripts.utils.PathSetupHelperUtil;
	import actionScripts.utils.UtilsCore;

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

		public var helperViewWrapper:HelperViewWrapper;
		
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
			this.feathersUIControl.addEventListener(
					GettingStartedView.EVENT_REFRESH_STATUS, onRefreshStatusRequest,
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

			// events from helperViewWrapper
			this.helperViewWrapper.itemsManager.detectionManager.addEventListener(
					DetectionManager.EVENT_DETECTION_ENDS, onStatusUpdateEnds, false, 0, true
			)
			this.dispatcher.addEventListener(
					StartupHelperEvent.REFRESH_GETTING_STARTED, onRefreshStatusRequest, false, 0, true
			);
			this.msdkiDownloadUtil.addEventListener(
					MSDKIdownloadUtil.EVENT_NEW_VERSION_DETECTED, onNewVersionDetected, false, 0, true
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
			this.feathersUIControl.removeEventListener(GettingStartedView.EVENT_REFRESH_STATUS, onRefreshStatusRequest);

			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.DOWNLOAD_COMPONENT, onDownload3rdPartySoftware
			);
			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.OPEN_MOON_SETTINGS, onOpenSettings
			);
			(this.feathersUIControl as GettingStartedView).helperView.removeEventListener(
					HelperEvent.COMPONENT_DOWNLOADED, onAnyComponentDownloaded
			);

			this.helperViewWrapper.itemsManager.detectionManager.removeEventListener(
					DetectionManager.EVENT_DETECTION_ENDS, onStatusUpdateEnds
			)
			this.dispatcher.removeEventListener(
					StartupHelperEvent.REFRESH_GETTING_STARTED, onRefreshStatusRequest
			);
			this.msdkiDownloadUtil.removeEventListener(
					MSDKIdownloadUtil.EVENT_NEW_VERSION_DETECTED, onNewVersionDetected
			);
		}

		public function onInvokeEvent(componentId:String, path:String=null):void
		{
			(this.feathersUIControl as GettingStartedView).onInvokeEvent(componentId, path);
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

		private function onRefreshStatusRequest(event:Event):void
		{
			(this.feathersUIControl as GettingStartedView).isRefreshInProgress = true;
			helperViewWrapper.checkForUpdate();
		}

		private function onStatusUpdateEnds(event:Event):void
		{
			(this.feathersUIControl as GettingStartedView).isRefreshInProgress = false;
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
			if ((component.type == ComponentTypes.TYPE_GIT) && ConstantsCoreVO.IS_MACOS && !UtilsCore.isGitPresent())
			{
				var gitComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GIT);

				dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				gitComponent.hasWarning = null;
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

		private function onNewVersionDetected(event:Event):void
		{
			(this.feathersUIControl as GettingStartedView).sdkInstallerInstallingMess =
					"Downloading new version of Moonshine SDK Installer. Please wait.";
		}
	}
}