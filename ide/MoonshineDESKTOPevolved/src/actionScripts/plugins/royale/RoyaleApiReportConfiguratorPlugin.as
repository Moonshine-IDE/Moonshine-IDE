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
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.events.RoyaleApiReportEvent;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;

	import flash.display.DisplayObject;

	import flash.events.Event;

	public class RoyaleApiReportConfiguratorPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Apache Royale Api Report Configurator Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Configurator Plugin."; }

		private var configView:SettingsView;

		public var royaleSdkPath:String;
		public var flexSdkPath:String;
		public var mainAppFile:String;
		public var outputPath:String;

		public function RoyaleApiReportConfiguratorPlugin():void
		{
			super();
		}

		override public function activate():void
		{
			super.activate();

			configView = new SettingsView();
			configView.addCategory("Report");

			configView.addEventListener(SettingsView.EVENT_SAVE, onRunReport);
			configView.addEventListener(SettingsView.EVENT_CLOSE, onCancelReport);

			dispatcher.addEventListener(RoyaleApiReportEvent.LAUNCH_REPORT_CONFIGURATION, onLaunchReportConfigration);
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

			var mainAppFile:ISetting = getMainApplicationFileSetting();
			apiReportItems.push(mainAppFile);

			var outputPath:ISetting = getOutputPath();
			apiReportItems.push(outputPath);

			var settingsWrapper:SettingsWrapper = new SettingsWrapper("Royale Api Report", apiReportItems);

			configView.addSetting(settingsWrapper, "Report");
		}

		private function getRoyaleSdkSetting():ISetting
		{
			var royaleSdk:SDKReferenceVO = null;
			for each (var sdk:SDKReferenceVO in model.userSavedSDKs)
			{
				if (sdk.type == SDKTypes.ROYALE)
				{
					royaleSdk = sdk;
					break;
				}
			}

			return new PathSetting(this, "royaleSdkPath", "Apache Royale SDK", true, royaleSdk ? royaleSdk.path : null, true);
		}

		private function getFlexSdkSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			return new PathSetting(this, "flexSdkPath", "Apache Flex SDK", true, (currentProject as AS3ProjectVO).customSDKPath, true);
		}

		private function getMainApplicationFileSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var asProject:AS3ProjectVO = currentProject as AS3ProjectVO;
			var targets:Vector.<FileLocation> = asProject.targets;

			return new PathSetting(this, "mainAppFile", "Main application file", false, targets[0].fileBridge.name, false);
		}

		private function getOutputPath():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			return new PathSetting(this, "outputPath", "Output Path", true, (currentProject as AS3ProjectVO).outputPath);
		}

		override public function deactivate():void
		{
			super.deactivate();
		}

		private function onRunReport(event:Event):void
		{

		}

		private function onCancelReport(event:Event):void
		{
			configView.removeEventListener(SettingsView.EVENT_CLOSE, onRunReport);
			configView.removeEventListener(SettingsView.EVENT_SAVE, onCancelReport);

			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));
		}

		private function onLaunchReportConfigration(event:Event):void
		{
			addReportItems();
			dispatcher.dispatchEvent(new AddTabEvent(configView));
		}
	}
}