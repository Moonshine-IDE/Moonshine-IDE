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
package actionScripts.events
{
	import flash.events.Event;
	import actionScripts.valueObjects.Position;

	public class HoverEvent extends Event
	{
		public static const EVENT_SHOW_HOVER:String = "newShowHover";
		
		public var contents:Vector.<String>;
		public var uri:String;
		public var position:Position;

		public function HoverEvent(type:String, contents:Vector.<String>, uri:String, position:Position)
		{
			super(type, false, true);
			this.contents = contents;
			this.uri = uri;
			this.position = position;
		}

	}
}