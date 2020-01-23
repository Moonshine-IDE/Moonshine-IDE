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
package actionScripts.plugins.royale
{
	import actionScripts.events.AddTabEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.royale.RoyaleApiConfigView;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.events.RoyaleApiReportEvent;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectConst;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RoyaleApiReportVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;

	import flash.display.DisplayObject;

	import flash.events.Event;
	import flash.net.SharedObject;

	import mx.events.CloseEvent;

	public class RoyaleApiReportConfiguratorPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Apache Royale Api Report Configurator Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Configurator Plugin."; }

		private var configView:RoyaleApiConfigView;

		public var royaleSdkPath:String;
		public var flexSdkPath:String;
		public var libraries:Vector.<FileLocation>;
		public var mainAppFile:String;
		public var outputPath:String;

		public function RoyaleApiReportConfiguratorPlugin():void
		{
			super();
		}

		private var _folderLocation:FileLocation;
		public function get folderLocation():FileLocation
		{
			return _folderLocation;
		}

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(RoyaleApiReportEvent.LAUNCH_REPORT_CONFIGURATION, onLaunchReportConfigration);
			dispatcher.addEventListener(RoyaleApiReportEvent.REPORT_GENERATION_COMPLETED, onReportCompleted);
		}

		private function addReportItems():void
		{
			if (!model.activeProject)
			{
				return;
			}

			var apiReportItems:Vector.<ISetting> = Vector.<ISetting>([]);

			var royaleSdk:ISetting = getRoyaleSdkSetting();
			apiReportItems.push(royaleSdk);

			var flexSdk:ISetting = getFlexSdkSetting();
			apiReportItems.push(flexSdk);

			var projectLibraries:ISetting = getLibraries();
			apiReportItems.push(projectLibraries);

			var mainAppFile:ISetting = getMainApplicationFileSetting();
			apiReportItems.push(mainAppFile);

			var outputPath:ISetting = getOutputPath();
			apiReportItems.push(outputPath);

			var settingsWrapper:SettingsWrapper = new SettingsWrapper("Royale Api Report", apiReportItems);

			configView.addCategory("Report");
			configView.addSetting(settingsWrapper, "Report");
		}

		private function getRoyaleSdkSetting():ISetting
		{
			var royaleSdkPath:String = null;
			for each (var sdk:SDKReferenceVO in model.userSavedSDKs)
			{
				if (sdk.type == SDKTypes.ROYALE)
				{
					royaleSdkPath = sdk.path;
					break;
				}
			}

			this.royaleSdkPath = royaleSdkPath;
			return new PathSetting(this, "royaleSdkPath", "Apache Royale SDK", true, royaleSdkPath, true, false, royaleSdkPath);
		}

		private function getFlexSdkSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var as3Project:AS3ProjectVO =  (currentProject as AS3ProjectVO);

			this.flexSdkPath = as3Project.customSDKPath;
			return new PathSetting(this, "flexSdkPath", "Apache Flex SDK", true, as3Project.customSDKPath, true, false, as3Project.customSDKPath);
		}

		public function getLibraries():ISetting
		{
			var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;

			libraries = new Vector.<FileLocation>();
			for each (var library:FileLocation in as3Project.libraries)
			{
				libraries.push(library);
			}

			_folderLocation = model.activeProject.folderLocation;
			return new PathListSetting(this, "libraries", "Libraries", model.activeProject.folderLocation);
		}

		private function getMainApplicationFileSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var asProject:AS3ProjectVO = currentProject as AS3ProjectVO;
			var targets:Vector.<FileLocation> = asProject.targets;

			this.mainAppFile = targets[0].fileBridge.nativePath;
			return new PathSetting(this, "mainAppFile", "Main application file", false, targets[0].fileBridge.nativePath, false, false, targets[0].fileBridge.nativePath);
		}

		private function getOutputPath():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var as3Project:AS3ProjectVO =  (currentProject as AS3ProjectVO);

			this.outputPath = as3Project.outputPath;
			return new PathSetting(this, "outputPath", "Output Path", true, as3Project.outputPath, false, false, as3Project.outputPath);
		}

		override public function deactivate():void
		{
			super.deactivate();
		}

		private function onRunReport(event:Event):void
		{
			configView.enabled = false;
			var reportConfiguration:RoyaleApiReportVO = new RoyaleApiReportVO(
					this.royaleSdkPath,
					this.flexSdkPath,
					this.libraries,
					this.mainAppFile,
					this.outputPath,
					model.activeProject.projectFolder.nativePath
			);

			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			cookie.data["doNotShowRoyaleApiPrompt"] = configView.doNotShowPromptAgain;
			cookie.flush();

			dispatcher.dispatchEvent(new RoyaleApiReportEvent(RoyaleApiReportEvent.LAUNCH_REPORT_GENERATION, reportConfiguration));
		}

		private function onCancelReport(event:CloseEvent):void
		{
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));

			cleanUp();
		}

		private function cleanUp():void
		{
			configView.removeEventListener(SettingsView.EVENT_CLOSE, onRunReport);
			configView.removeEventListener(SettingsView.EVENT_SAVE, onCancelReport);

			configView = null;

			royaleSdkPath = null;
			flexSdkPath = null;
			libraries = null;
			mainAppFile = null;
			outputPath = null;
		}

		private function onLaunchReportConfigration(event:Event):void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);

			configView = new RoyaleApiConfigView();
			configView.label = "API Report Configuration";
			configView.defaultSaveLabel = "Run";
			configView.doNotShowPromptAgain = Boolean(cookie.data.doNotShowRoyaleApiPrompt);

			configView.addEventListener(SettingsView.EVENT_SAVE, onRunReport);
			configView.addEventListener(CloseEvent.CLOSE, onCancelReport);

			addReportItems();
			dispatcher.dispatchEvent(new AddTabEvent(configView));
		}

		private function onReportCompleted(event:RoyaleApiReportEvent):void
		{
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));

			cleanUp();
		}
	}
}