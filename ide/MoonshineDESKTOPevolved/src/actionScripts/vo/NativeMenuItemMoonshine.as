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
/**
 * [props..]
 * [enableTypes]
 * null = To avail option against any type of project
 * [ProjectMenuTypes.., ProjectMenuTypes..] = To avail option against specific type of project(s)
 * [] = (Not recommended) May disable option against all type of project(s)
 */
package actionScripts.vo
{
	import flash.display.NativeMenuItem;
	
	public class NativeMenuItemMoonshine extends NativeMenuItem
	{
		public var enableTypes:Array;
		
		public function NativeMenuItemMoonshine(label:String="", isSeparator:Boolean=false)
		{
			super(label, isSeparator);
		}
	}
}