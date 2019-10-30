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
package actionScripts.plugins.debugAdapter.events
{
	import flash.events.Event;
	import actionScripts.valueObjects.ProjectVO;

	public class DebugAdapterEvent extends Event
	{
		public static const START_DEBUG_ADAPTER:String = "startDebugAdapter";

		public function DebugAdapterEvent(eventType:String, project:ProjectVO, adapterID:String, request:String, additionalProperties:Object)
		{
			super(eventType, false, false);
			this.project = project;
			this.adapterID = adapterID;
			this.request = request;
			this.additionalProperties = additionalProperties;
		}
		
		public var project:ProjectVO;
		public var adapterID:String;
		public var request:String;
		public var additionalProperties:Object;
	}
}
