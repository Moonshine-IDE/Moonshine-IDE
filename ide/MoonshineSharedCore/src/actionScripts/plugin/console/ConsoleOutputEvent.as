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
		public static const CONSOLE_PRINT:String = "consolePrint"; // this uses regular commands to print message to console other than how things works by CONSOLE_OUTPUT
		
		public static const TYPE_ERROR:String = "typeError";
		public static const TYPE_INFO:String = "typeInfo";
		public static const TYPE_SUCCESS:String = "typeSuccess";
		public static const TYPE_NOTE:String = "typeNotice";
		
		public static const CONSOLE_ACTIVATE:String = "activateConsoleView";
		
		public var text:*;
		public var hideOtherOutput:Boolean;
		public var messageType:String;
		
		/*
			Text can be String or array of TextLineModel
		*/
		public function ConsoleOutputEvent(type:String,
										   text:*,
										   hideOtherOutput:Boolean=false, cancelable:Boolean=false, messageType:String=TYPE_INFO)
		{
			this.text = text;
			this.hideOtherOutput = hideOtherOutput;
			this.messageType = messageType;
			super(type, false, cancelable);
		}
	}
}