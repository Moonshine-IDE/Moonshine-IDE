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
package actionScripts.plugin 
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.console.view.ConsoleModeEvent;
	
	public class PluginBase extends ConsoleOutputter implements IPlugin 
	{
		protected namespace console;
		
		override public function get name():String			{ throw new Error("You need to give a unique name.") }
		public function get author():String			{ return "N/A"; }
		public function get description():String	{ return "A plugin base that plugins can extend to gain easier access to some functionality."; }
		
		/**
		 * ensures if the plugin will be activated by default when the plugin 
		 * is loaded for the first time (without settings xml file written)
		 * */
		public function get activatedByDefault():Boolean { return true; }
		
		console static var commands:Dictionary = new Dictionary(true);
		console static var mode:String = "";

		protected var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();
		protected var model:IDEModel = IDEModel.getInstance();
		
		protected var _activated:Boolean = false;
		public function get activated():Boolean 
		{
			return _activated;
		}
		
		public function activate():void
		{
			_activated = true;
		}
		public function deactivate():void
		{
			_activated = false;
		}
		
		
		public function PluginBase() {}
		
		// Console command functions
		protected function registerCommand(commandName:String, commandObj:Object):void
		{
			console::commands[commandName] = commandObj;
		}
		
		protected function unregisterCommand(commandName:String):void
		{
			delete console::commands[commandName];
		}
		
		protected function enterConsoleMode(newMode:String):void
		{
			console::mode = newMode;
			dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, newMode));
		}
		
		protected function exitConsoleMode():void
		{
			console::mode = "";
			dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, ""));
		}
		
		
	}
}