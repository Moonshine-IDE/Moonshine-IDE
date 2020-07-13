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

	public class ActionScriptBuildEvent extends Event
	{
		public static const BUILD_AND_RUN:String = "compilerBuildAndRun";
		public static const BUILD_AND_DEBUG:String = "compilerBuildAndDebug";
		public static const RUN_AFTER_DEBUG:String = "compilerRunAfterDebug";
		public static const BUILD:String = "compilerBuild";
		public static const BUILD_RELEASE:String = "compilerBuildRelease";
		public static const PREBUILD:String = "compilerPrebuild";
		public static const POSTBUILD:String = "compilerPostbuild";
		public static const EXIT_FDB: String = "EXIT_FDB";
		public static const SAVE_BEFORE_BUILD:String = "saveBeforeBuild";
		
		public function ActionScriptBuildEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}