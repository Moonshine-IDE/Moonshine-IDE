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
package actionScripts.plugin.settings.event
{
	import flash.events.Event;
	
	import actionScripts.plugin.IPlugin;

	public class RequestSettingByNameEvent extends Event
	{
		public static const REQUEST_SETTING:String = "requestSettingByName";
		public var name:String;
		public var value:IPlugin;

		public function RequestSettingByNameEvent(name:String)
		{
			this.name = name;
			super(REQUEST_SETTING, false, false);
		}
	}
}