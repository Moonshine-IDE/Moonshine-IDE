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
package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.events.ASModulesEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;

	public class FlashModuleOptions 
	{
		public var modulePaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var abcd:Boolean;
		
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		public function FlashModuleOptions()
		{
			dispatcher.addEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent, false, 0, true);
			dispatcher.addEventListener(ASModulesEvent.EVENT_REMOVE_MODULE, onRemoveModuleEvent, false, 0, true);
		}
		
		public function getSettings():Vector.<ISetting>
		{
			var settings:Vector.<ISetting> = new Vector.<ISetting>();
			
			settings.push(
				new StaticLabelSetting("Select Modules to auto-compile during project a build.", 14, 0x686868)
				);
			
			for each (var path:FileLocation in modulePaths)
			{
				settings.push(
					new BooleanSetting(this, "abcd", path.fileBridge.nativePath)
					);
			}
			
			return settings;
		}
		
		private function onAddModuleEvent(event:ASModulesEvent):void
		{
			modulePaths.push(event.moduleFilePath);
			event.project.saveSettings();
		}
		
		private function onRemoveModuleEvent(event:ASModulesEvent):void
		{
			
		}
    }
}