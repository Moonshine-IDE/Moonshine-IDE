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
package actionScripts.ui.parser.context
{
	public class ContextSwitchManager {
		private var switches:Object = {};
		
		function ContextSwitchManager(switches:Vector.<ContextSwitch>) {
			for each (var swtch:ContextSwitch in switches)
			{
				addSwitch(swtch);
			}
		}
		
		public function addSwitch(swtch:ContextSwitch, highPriority:Boolean = false):void
		{
			for each (var from:int in swtch.from)
			{
				if (!switches[from]) switches[from] = new Vector.<ContextSwitch>();
				
				if (highPriority) switches[from].unshift(swtch);
				else switches[from].push(swtch);
			}
		}
		
		public function getSwitches(from:int):Vector.<ContextSwitch>
		{
			return switches[from];
		}
	}
}