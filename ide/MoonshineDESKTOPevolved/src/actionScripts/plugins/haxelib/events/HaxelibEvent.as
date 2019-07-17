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
package actionScripts.plugins.haxelib.events
{
	import flash.events.Event;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public class HaxelibEvent extends Event
	{
		public static const HAXELIB_INSTALL:String = "haxelibInstall";
		public static const HAXELIB_INSTALL_COMPLETE:String = "haxelibInstallComplete";

		public var project:HaxeProjectVO;

		public function HaxelibEvent(type:String, project:HaxeProjectVO)
		{
			super(type, false, false);
			this.project = project;
		}
	}
}