////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc. 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.events
{
	import flash.events.Event;
	
	public class StatusBarEvent extends Event
	{
		public static const PROJECT_BUILD_STARTED:String = "PROJECT_BUILD_STARTED";
		public static const PROJECT_BUILD_ENDED:String = "PROJECT_BUILD_ENDED";
		public static const PROJECT_DEBUG_STARTED:String = "PROJECT_DEBUG_STARTED";
		public static const PROJECT_DEBUG_ENDED:String = "PROJECT_DEBUG_ENDED";
		public static const PROJECT_BUILD_TERMINATE:String = "PROJECT_BUILD_TERMINATE";
		
		public var projectName:String;
		public var notificationSuffix:String;
		
		public function StatusBarEvent(type:String, projectName:String=null, notificationSuffix:String=null)
		{
			this.projectName = projectName;
			this.notificationSuffix = notificationSuffix;
			
			super(type, true, false);
		}
	}
}