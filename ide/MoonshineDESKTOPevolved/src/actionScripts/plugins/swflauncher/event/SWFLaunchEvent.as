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
package actionScripts.plugins.swflauncher.event
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.valueObjects.ProjectVO;

	public class SWFLaunchEvent extends Event
	{
		public static const EVENT_LAUNCH_SWF:String = "launchSwfEvent";
		public static const EVENT_UNLAUNCH_SWF:String = "unLaunchSwfEvent";
		
		public var file:File;
		public var project:ProjectVO;
		public var sdk:File;
		
		public function SWFLaunchEvent(type:String, file:File, project:ProjectVO=null, sdk:File=null)
		{
			this.file = file;
			this.project = project; 
			this.sdk = sdk;
			
			super(type, false, true);
		}
		
	}
}