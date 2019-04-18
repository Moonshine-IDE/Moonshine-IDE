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
package actionScripts.plugins.groovy
{
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.core.compiler.CompilerEventBase;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;

    import flash.events.Event;
	
	public class GroovyCPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String			{ return "Groovy Build Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Builds Groovy projects"; }
		
		public function GroovyCPlugin() 
		{
		}
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			
			dispatcher.addEventListener(CompilerEventBase.BUILD, buildHandler);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return null;
		}
		
		private function buildHandler(event:Event):void 
		{
		}
	}
}