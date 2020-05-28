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
package actionScripts.plugins.externalEditors
{	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.SettingsEvent;
	import actionScripts.plugin.actionscript.as3project.settings.SimpleInformationOnlySetting;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.domino.settings.UpdateSitePathSetting;
	import actionScripts.plugins.externalEditors.importer.ExternalEditorsImporter;
	import actionScripts.plugins.externalEditors.utils.ExternalEditorsSharedObjectUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.containers.DominoSettingsInstruction;
	
	public class ExternalEditorsPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.externalEditors::ExternalEditorsPlugin";
		
		public static var editors:ArrayCollection; 
		
		override public function get name():String			{ return "External Editors"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Integration of External Editors to Moonshine-IDE"; }
		
		public var updateSitePath:String;
		
		private var pathSetting:PathSetting;
		private var updateSitePathSetting:UpdateSitePathSetting;
		
		override public function activate():void
		{
			super.activate();
			
			generateEditorsList();
			
			dispatcher.addEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(SettingsEvent.EVENT_SETTINGS_SAVED, onSettingsSaved);
		}

		override public function resetSettings():void
		{
			ExternalEditorsSharedObjectUtil.resetExternalEditorsInSO();
			editors = ExternalEditorsImporter.getDefaultEditors();
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			
			// check if all dependencies for 'update site > generate'
			// functionality, are present

			updateSitePathSetting = new UpdateSitePathSetting(this, 'updateSitePath', 'Update Site', true, updateSitePath);
			
			var instructions:SimpleInformationOnlySetting = new SimpleInformationOnlySetting();
			instructions.renderer = new DominoSettingsInstruction();
			
			return Vector.<ISetting>([
                pathSetting,
				updateSitePathSetting,
				instructions
			]);
        }
		
		private function generateEditorsList():void
		{
			editors = ExternalEditorsSharedObjectUtil.getExternalEditorsFromSO();
			if (!editors)
			{
				editors = ExternalEditorsImporter.getDefaultEditors();
			}
		}
		
		private function onSettingsSaved(event:SettingsEvent):void
		{
			
		}
	}
}