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
package actionScripts.plugin.core.compiler
{
	import actionScripts.factory.FileLocation;

	import flash.events.Event;

	public class ProjectActionEvent extends Event
	{
		public static const CLEAN_PROJECT:String = "cleanproject";
		public static const SET_DEFAULT_APPLICATION:String = "setDefaultApplication";

		public function ProjectActionEvent(type:String, defaultApplicationFile:FileLocation = null)
		{
			super(type, bubbles, cancelable);

			_defaultApplicationFile = defaultApplicationFile;
		}

		private var _defaultApplicationFile:FileLocation;
		public function get defaultApplicationFile():FileLocation
		{
			return _defaultApplicationFile;
		}
	}
}