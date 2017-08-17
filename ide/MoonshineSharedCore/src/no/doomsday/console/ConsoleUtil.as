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
package no.doomsday.console
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.utils.describeType;
	import no.doomsday.console.core.AbstractConsole;
	import no.doomsday.console.core.commands.FunctionCallCommand;
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.DLogger;
	import no.doomsday.console.utilities.ContextMenuUtil;   
	// import no.doomsday.console.utilities.ContextMenuUtilAir;
	import no.doomsday.console.utilities.measurement.MeasurementTool;
	import no.doomsday.console.core.messages.MessageTypes;
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ConsoleUtil 
	{
		
		public static const MODE_CONSOLE:String = "console";
		public static const MODE_LOGGER:String = "logger";
		private static var _instance:AbstractConsole;
		public function ConsoleUtil() 
		{
			throw new Error("Use static methods");
		}
		/**
		 * Get the singleton console instance
		 */
		public static function get instance():AbstractConsole {
			return getInstance();
		}
		
		public static function getInstance(type:String = MODE_CONSOLE):AbstractConsole {
			if (!_instance) {
				switch(type) {
					case MODE_LOGGER:
						_instance = new DLogger();
						trace("Logger mode set");
						break;
					default:
						_instance = new DConsole();
						trace("Console mode set");
				}
			}
			return _instance;
		}
		/**
		 * Add a message
		 * @param       msg
		 */
		public static function print(input:Object):void {
			instance.print(input.toString());
		}
		/**
		 * Add a message with system color coding
		 * @param       msg
		 */
		public static function addSystemMessage(msg:String):void {
			instance.print(msg, MessageTypes.SYSTEM);
		}
		/**
		 * Add a message with error color coding
		 * @param       msg
		 */
		public static function addErrorMessage(msg:String):void {
			instance.print(msg, MessageTypes.ERROR);
		}
		/**
		 * Legacy, deprecated. Use "createCommand" instead
		 */
		public static function linkFunction(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			createCommand(triggerPhrase, func, commandGroup, helpText);
		}
		/**
		 * Create a command for calling a specific function
		 * @param       triggerPhrase
		 * The trigger word for the command
		 * @param       func
		 * The function to call
		 * @param       commandGroup
		 * Optional: The group name you want the command sorted under
		 * @param       helpText
		 */
		public static function createCommand(triggerPhrase:String, func:Function, commandGroup:String = "Application", helpText:String = ""):void {
			instance.addCommand(new FunctionCallCommand(triggerPhrase, func, commandGroup, helpText));
		}
		/**
		 * Use this to print event messages on dispatch (addEventListener(Event.CHANGE, ConsoleUtil.onEvent))
		 */
		public static function get onEvent():Function {
			return instance.onEvent;
		}
		/**
		 * Add a message to the trace buffer
		 */
		public static function get trace():Function {
			return instance.trace;
		}
		public static function log(...args):void {
			instance.log.apply(instance, args);
		}
		public static function get clear():Function {
			return instance.clear;
		}
		/**
		 * Show the console
		 */
		public static function show():void {
			instance.show();
		}
		/**
		 * Hide the console
		 */
		public static function hide():void {
			instance.hide();
		}
		/**
		 * Sets the console docking position
		 * @param       position
		 * "top" or "bot"/"bottom"
		 */
		public static function dock(position:String):void {
			instance.dock(position);
		}
		
		public static function set password(s:String):void {
			instance.setPassword(s);
		}
		public static function setKeyStroke(keyCodes:Array = null, charCodes:Array = null):void {
			if (!charCodes) charCodes = [];
			if (!keyCodes) keyCodes = [];
			instance.setInvokeKeys(keyCodes, charCodes);
		}
	}
}
