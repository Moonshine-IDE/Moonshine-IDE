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
package actionScripts.plugin.console
{
    import flash.events.Event;

	public class ConsoleOutputEvent extends Event
	{
		public static const CONSOLE_OUTPUT:String = "consoleOutput";
		public static const CONSOLE_CLEAR:String = "consoleClear";
		
		public var text:*;
		public var hideOtherOutput:Boolean;
		
		/*
			Text can be String or array of TextLineModel
		*/
		public function ConsoleOutputEvent(type:String,
										   text:*,
										   hideOtherOutput:Boolean=false, cancelable:Boolean=false)
		{
			this.text = text;
			this.hideOtherOutput = hideOtherOutput;
			super(type, false, cancelable);
		}
	}
}