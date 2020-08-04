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
package actionScripts.plugin.actionscript.modules
{
    import actionScripts.events.ASModulesEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
	public class FlashModulesPlugin extends PluginBase
	{
		override public function get name():String 			{ return "Flash Modules Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Flash Modules importing, exporting & scaffolding."; }
		
		override public function activate():void
		{
			dispatcher.addEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent);
			dispatcher.addEventListener(ASModulesEvent.EVENT_REMOVE_MODULE, onRemoveModuleEvent);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent);
			dispatcher.removeEventListener(ASModulesEvent.EVENT_REMOVE_MODULE, onRemoveModuleEvent);
			
			super.deactivate();
		}
		
		private function onAddModuleEvent(event:ASModulesEvent):void
		{
			event.project.modulePaths.push(event.moduleFilePath);
			event.project.saveSettings();
		}

        private function onRemoveModuleEvent(event:ASModulesEvent):void
        {
            
        }
	}
}