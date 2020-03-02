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
package actionScripts.plugins.domino
{
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class DominoPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "Notes Domino"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Domino Plugin"; }
		
		private var nodePathSetting:PathSetting;

        public function get notesPath():String
        {
            return model ? model.notesPath : null;
        }

        public function set notesPath(value:String):void
        {
            if (model.notesPath != value)
            {
                model.notesPath = value;
			    //dispatcher.dispatchEvent(new SdkEvent(SdkEvent.CHANGE_NODE_SDK));
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			nodePathSetting = new PathSetting(this, 'notesPath', 'IBM/HCL Notes Executable', ConstantsCoreVO.IS_MACOS ? false : true, notesPath);
			
			return Vector.<ISetting>([
                nodePathSetting
			]);
        }
		
		override public function resetSettings():void
		{
			notesPath = null;
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