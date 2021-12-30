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
package actionScripts.plugins.vagrant
{
	import actionScripts.events.FilePluginEvent;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.vagrant.utils.VagrantUtil;

	import com.adobe.utils.StringUtil;
	
	import flash.filesystem.File;

	import mx.collections.ArrayCollection;

	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.externalEditors.importer.ExternalEditorsImporter;
	import actionScripts.plugins.externalEditors.utils.ExternalEditorsSharedObjectUtil;
	import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class VagrantPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.vagrant::VagrantPlugin";
		
		public static var editors:ArrayCollection; 
		
		override public function get name():String			{ return "Vagrant"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Vagrant support from Moonshine-IDE"; }
		
		public var updateSitePath:String;

		private var pathSetting:PathSetting;
		private var defaultVagrantPath:String;

		public function get vagrantPath():String
		{
			return model ? model.vagrantPath : null;
		}
		public function set vagrantPath(value:String):void
		{
			if (model.vagrantPath != value)
			{
				model.vagrantPath = value;
			}
		}
		
		override public function activate():void
		{
			super.activate();
			updateEventListeners();

			if (!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				// because most users install Vagrant to a standard installation
				// directory, we can try to use it as the default, if it exists.
				// if the user saves a different path (or clears the path) in
				// the settings, these default values will be safely ignored.
				var vagrantFile:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin/vagrant" : "C:\\HashiCorp\\Vagrant\\bin\\vagrant.exe");
				defaultVagrantPath = vagrantFile.exists ? vagrantFile.nativePath : null;
				if (defaultVagrantPath && !model.vagrantPath)
				{
					model.vagrantPath = defaultVagrantPath;
				}
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
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
			pathSetting = new PathSetting(this, 'vagrantPath', 'Vagrant Binary', false, vagrantPath, false, false, defaultVagrantPath);

			return Vector.<ISetting>([
				pathSetting
			]);
        }

		private function updateEventListeners():void
		{
			var eventName:String;
			for each (var option:String in VagrantUtil.VAGRANT_MENU_OPTIONS)
			{
				eventName = "eventVagrant"+ option;
				dispatcher.addEventListener(eventName, onVagrantOptionSelect, false, 0, true);
			}
		}

		private function onVagrantOptionSelect(event:FilePluginEvent):void
		{
			var optionSelected:String = event.type.replace("eventVagrant", "");
			trace(optionSelected);
		}

		private function runExternalEditor(editor:ExternalEditorVO, onPath:FileLocation):void
		{
			var command:String;
			var extraArguments:String = (editor.extraArguments && StringUtil.trim(editor.extraArguments).length != 0) ? editor.extraArguments : null;
			if (ConstantsCoreVO.IS_MACOS) 
			{
				command = "open -a '"+ editor.installPath.nativePath +"' '"+ onPath.fileBridge.nativePath +"'";
				if (extraArguments) command += " --args "+ extraArguments;
			}
			else
			{
				command = '"'+ editor.installPath.nativePath +'" "'+ onPath.fileBridge.nativePath +'"';
				if (extraArguments) command += " "+ extraArguments;
			}
			print("%s", command);
			
			this.start(
				new <String>[command], null
			);
		}
	}
}