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
	import flash.events.Event;

	public class GrailsBuildEvent extends Event
	{
		public static const BUILD_AND_RUN:String = "grailsBuildAndRun";
		public static const BUILD:String = "grailsBuild";
		public static const BUILD_RELEASE:String = "grailsBuildRelease";
		public static const CLEAN:String = "grailsClean";
		public static const CREATE_APP:String = "grailsCreateApp";
		
		public function GrailsBuildEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}