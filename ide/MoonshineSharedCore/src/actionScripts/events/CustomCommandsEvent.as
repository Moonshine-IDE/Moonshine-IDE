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
	
	import actionScripts.interfaces.ICustomCommandRunProvider;
	import actionScripts.plugin.build.vo.BuildActionVO;
	
	public class CustomCommandsEvent extends Event
	{
		public static const OPEN_CUSTOM_COMMANDS_ON_SDK:String = "openCustomCommandsInterfaceForSDKtype";
		public static const RUN_CUSTOM_COMMAND_ON_SDK:String = "runCustomCommandForSDKtype";
		
		public var commands:Array;
		public var selectedCommand:BuildActionVO;
		public var executableNameToDisplay:String;
		public var origin:ICustomCommandRunProvider;
		
		public function CustomCommandsEvent(type:String, executableNameToDisplay:String, commands:Array, origin:ICustomCommandRunProvider, selectedCommand:BuildActionVO=null)
		{
			this.commands = commands;
			this.selectedCommand = selectedCommand;
			this.origin = origin;
			this.executableNameToDisplay = executableNameToDisplay;
			
			super(type, false, false);
		}
	}
}