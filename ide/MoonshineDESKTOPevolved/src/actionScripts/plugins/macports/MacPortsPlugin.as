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
package actionScripts.plugins.macports
{
	import flash.filesystem.File;

	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class MacPortsPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.macports::MacPortsPlugin";
		
		override public function get name():String			{ return "MacPorts"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to MacPorts support from Moonshine-IDE"; }
		
		private var pathSetting:PathSetting;
		private var defaultMacportsPath:String;

		public function get macportsPath():String
		{
			return model ? model.macportsPath : null;
		}
		public function set macportsPath(value:String):void
		{
			if (model.macportsPath != value)
			{
				model.macportsPath = value;
			}
		}

		override public function activate():void
		{
			super.activate();

			if (!ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				var macportsPath:File = new File("/opt/local/bin");
				defaultMacportsPath = macportsPath.exists ? macportsPath.nativePath : null;
				if (defaultMacportsPath && !model.macportsPath)
				{
					model.macportsPath = defaultMacportsPath;
				}
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
		}

		override public function resetSettings():void
		{
			macportsPath = null;
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}

		override protected function outputMsg(msg:*):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, msg));
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'macportsPath', 'MacPorts Home', true, macportsPath, false, false, defaultMacportsPath);

			return Vector.<ISetting>([
				pathSetting
			]);
        }
	}
}