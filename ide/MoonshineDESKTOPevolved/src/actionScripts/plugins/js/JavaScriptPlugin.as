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
package actionScripts.plugins.js
{
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.events.SdkEvent;
	import flash.filesystem.File;
	
	public class JavaScriptPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "JavaScript"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "JavaScript Plugin"; }

		public function JavaScriptPlugin()
		{
			super();

			if(!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				// because most users install Node.js to a standard installation
				// directory, we can try to use it as the default, if it exists.
				// if the user saves a different path (or clears the path) in
				// the settings, these default values will be safely ignored.
				var nodeDir:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : "C:\\Program Files\\nodejs")
				defaultNodePath = (nodeDir.exists && nodeDir.isDirectory) ? nodeDir.nativePath : null;
				if(defaultNodePath && model.nodePath == null)
				{
					model.nodePath = defaultNodePath;
				}
			}
		}
		
		private var nodePathSetting:PathSetting;
		private var defaultNodePath:String;

        public function get nodePath():String
        {
            return model ? model.nodePath : null;
        }

        public function set nodePath(value:String):void
        {
            if (model.nodePath != value)
            {
                model.nodePath = value;
			    dispatcher.dispatchEvent(new SdkEvent(SdkEvent.CHANGE_NODE_SDK));
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			nodePathSetting = new PathSetting(this, 'nodePath', 'Node.js Home', true, nodePath, false, false, defaultNodePath);
			
			return Vector.<ISetting>([
                nodePathSetting
			]);
        }
		
		override public function onSettingsClose():void
		{
			if (nodePathSetting)
			{
				nodePathSetting = null;
			}
		}
	}
}
		