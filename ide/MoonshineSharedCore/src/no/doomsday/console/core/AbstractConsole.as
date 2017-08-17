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
package no.doomsday.console.core 
{
	import no.doomsday.console.core.interfaces.ILogger;
	import no.doomsday.console.core.messages.Message;
	import no.doomsday.console.core.commands.ConsoleCommand;
	import flash.display.Sprite;
	import flash.events.Event;
	import no.doomsday.console.core.interfaces.IConsole;
	import no.doomsday.console.core.messages.MessageTypes;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class AbstractConsole extends Sprite implements IConsole, ILogger
	{
		protected static const VERSION:String = "1.06a";
		
		public function AbstractConsole() 
		{
			//throw new Error("Not implemented");
		}
		
		/* INTERFACE no.doomsday.console.core.interfaces.IConsole */
		
		public function show():void
		{
			throw new Error("Not implemented");
		}
		
		public function hide():void
		{
			throw new Error("Not implemented");
		}
		
		public function setInvokeKeys(...keyCodes:Array):void
		{
			throw new Error("Not implemented");
		}
		
		public function setRepeatFilter(filter:int):void
		{
			throw new Error("Not implemented");
		}
		
		public function toggleStats(e:Event = null):void
		{
			throw new Error("Not implemented");
		}
		
		public function routeToJS():void
		{
			throw new Error("Not implemented");
		}
		
		public function alertErrors():void
		{
			throw new Error("Not implemented");
		}
		
		public function screenshot(e:Event = null):void
		{
			throw new Error("Not implemented");
		}
		
		public function addCommand(command:ConsoleCommand):void
		{
			throw new Error("Not implemented");
		}
		
		public function print(str:String, type:uint = 2):Message
		{
			throw new Error("Not implemented");
		}
		
		public function clear():void
		{
			throw new Error("Not implemented");
		}
		
		public function saveLog(e:Event = null):void
		{
			throw new Error("Not implemented");
		}
		
		public function setPassword(pwd:String):void
		{
			throw new Error("Not implemented");
		}
		
		public function runBatch(batch:String):Boolean
		{
			throw new Error("Not implemented");
		}
		
		public function runBatchFromUrl(url:String):void
		{			
			throw new Error("Not implemented");
		}
		
		public function maximize():void
		{
			throw new Error("Not implemented");
		}
		
		public function minimize():void
		{
			throw new Error("Not implemented");
		}
		
		public function onEvent(e:Event):void
		{
			throw new Error("Not implemented");
		}
		
		public function trace(...args:Array):void
		{
			throw new Error("Not implemented");
		}
		
		public function log(...args:Array):void
		{
			throw new Error("Not implemented");
		}
		
		public function dock(value:String):void
		{
			throw new Error("Not implemented");
		}
		
		public function setChromeTheme(backgroundColor:uint = 0, backgroundAlpha:Number = 0.8, borderColor:uint = 0x333333, inputBackgroundColor:uint = 0, helpBackgroundColor:uint = 0x222222):void
		{
			throw new Error("Not implemented");
		}
		
		public function setTextTheme(input:uint = 0xFFD900, oldMessage:uint = 0xBBBBBB, newMessage:uint = 0xFFFFFF, system:uint = 0x00DD00, timestamp:uint = 0xAAAAAA, error:uint = 0xEE0000, help:uint = 0xbbbbbb, trace:uint = 0x9CB79B, event:uint = 0x009900, warning:uint = 0xFFD900):void
		{
			throw new Error("Not implemented");
		}
		
	}

}