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
package no.doomsday.console.core.events
{
	import flash.events.Event;
	
	public class DLoggerEvent extends Event
	{
		public static const LOG:String 			= "log";
		public static const DESCRIBE:String 	= "describe";
		
		public static const CODE_SUCCESS:uint 	= 0;
		public static const CODE_INFO:uint 		= 2;
		public static const CODE_EVENT:uint 	= 2;
		public static const CODE_ERROR:uint 	= 3;
		public static const CODE_WARNING:uint 	= 4;
		public static const CODE_TRACE:uint 	= 5;
		
		public var appendLast:Boolean;
		public var message:Object;
		public var severity:uint;
		public var origin:Object;
		
		public function DLoggerEvent(	$type:String,
										$message:Object,
										$appendLast:Boolean = false,
										$severity:uint = 0,
										$origin:Object = null,
										$bubbles:Boolean = false,
										$cancelable:Boolean = false)
		{
			super($type, $bubbles, $cancelable);
			
			message 	= $message;
			appendLast 	= $appendLast;
			severity 	= $severity;
			origin 		= $origin;
		}
		
		/**
		 * Creates and returns a copy of the current instance.
		 * @return A copy of the current instance.
		 */
		public override function clone():Event
		{
			return new DLoggerEvent(type, message, appendLast, severity, origin, bubbles, cancelable);
		}
		
		/**
		 * Returns a String containing all the properties of the current
		 * instance.
		 * @return A string representation of the current instance.
		 */
		public override function toString():String
		{
			return formatToString("AILoggerEvent","type","message","appendLast","severity","origin","bubbles","cancelable","eventPhase");
		}
	}
}