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
package actionScripts.plugin.actionscript.as3project.vo
{
	public class LibrarySettingsVO
	{
		public static const FLEX_LIBRARY:String = "Flex Library Project";
		public static const ACTIONSCRIPT_LIBRARY:String = "ActionScript Library Project";
		public static const MOBILE_LIBRARY:String = "Mobile Library Project";
		public static const GENERIC:String = "Generic library (for use with web, desktop and mobile projects)";
		public static const MOBILE:String = "Mobile library (for use with mobile projects only)";
		
		public var type:String = FLEX_LIBRARY;
		public var output:String = GENERIC;
		public var includeAIR:Boolean;
		
		public function LibrarySettingsVO()
		{
		}
	}
}