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
package actionScripts.plugins.versionControl.event
{
	import flash.events.Event;
	
	public class VersionControlEvent extends Event
	{
		public static const OPEN_MANAGE_REPOSITORIES:String = "openManageRepositories";
		public static const OPEN_ADD_REPOSITORY:String = "openAddRepositoryView";
		public static const ADD_EDIT_REPOSITORY:String = "addOrEditRepository";
		public static const LOAD_REMOTE_SVN_LIST:String = "loadRemoteSvnList";
		public static const SEARCH_PROJECTS_IN_DIRECTORIES:String = "searchForProjectsInDirectories";
		
		public var value:Object;
		
		public function VersionControlEvent(type:String, value:Object=null, bubble:Boolean=false, cancelable:Boolean=true)
		{
			this.value = value;
			super(type, bubble, cancelable);
		}
	}
}