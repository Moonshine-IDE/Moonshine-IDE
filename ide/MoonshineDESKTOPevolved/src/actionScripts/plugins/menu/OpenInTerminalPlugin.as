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
package actionScripts.plugins.menu
{
	import actionScripts.events.FilePluginEvent;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;

	public class OpenInTerminalPlugin extends ConsoleBuildPluginBase
	{
		override public function get name():String			{ return "OpenInTerminalPlugin"; }
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			dispatcher.addEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal, false, 0, true);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(FilePluginEvent.EVENT_OPEN_PATH_IN_TERMINAL, onOpenPathInTerminal);
		}
		
		private function onOpenPathInTerminal(event:FilePluginEvent):void
		{
		}
	}
}