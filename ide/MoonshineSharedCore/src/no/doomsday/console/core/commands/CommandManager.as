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
package no.doomsday.console.core.commands 
{
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.introspection.InspectionUtils;
	import no.doomsday.console.core.messages.MessageTypes;
	import no.doomsday.console.core.persistence.PersistenceManager;
	import no.doomsday.console.core.references.ReferenceManager;
	import no.doomsday.console.core.text.ParseUtils;
	import no.doomsday.console.core.text.TextUtils;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CommandManager
	{
		private var console:DConsole;
		private var persistence:PersistenceManager;
		private var	commands:Vector.<ConsoleCommand>;
		private var password:String = "";
		private var authenticated:Boolean = true;
		private var authCommand:FunctionCallCommand = new FunctionCallCommand("authorize", authenticate, "System", "Input password to gain console access");
		private var deAuthCommand:FunctionCallCommand = new FunctionCallCommand("deauthorize", lock, "System", "Lock the console from unauthorized user access");
		private var authenticationSetup:Boolean;
		private var referenceManager:ReferenceManager;
		public function CommandManager(console:DConsole,persistence:PersistenceManager,referenceManager:ReferenceManager) 
		{
			this.persistence = persistence;
			this.console = console;
			this.referenceManager = referenceManager;
			commands = new Vector.<ConsoleCommand>();
		}
		public function addCommand(c:ConsoleCommand):void {
			commands.push(c);
			commands.sort(sortCommands);
		}
		private function sortCommands(a:ConsoleCommand,b:ConsoleCommand):int
		{
			if (a.grouping == b.grouping) return -1;
			return 1;
		}
		public function tryCommand(input:String, sub:Boolean = false ):*
		{
			var cmdStr:String = TextUtils.stripWhitespace(input);
			var args:Array;
			try{
				args = ArgumentSplitterUtil.slice(cmdStr);
			}catch (e:Error) {
				console.print(e.getStackTrace(), MessageTypes.ERROR);
				throw e;
			}
			var str:String = args.shift().toLowerCase();
			if (!authenticated&&str!=authCommand.trigger) {
				if(!sub) console.print("Not authenticated", MessageTypes.ERROR);
				throw new Error("Not authenticated");
			}
			if (str != authCommand.trigger&&!sub) {
				persistence.addtoHistory(input);
			}
			
			var commandArgs:Vector.<CommandArgument> = new Vector.<CommandArgument>();
			for (var i:int = 0; i < args.length; i++) 
			{
				commandArgs.push(new CommandArgument(args[i],this,referenceManager));
			}
			
			for (i = 0; i < commands.length; i++) 
			{
				if (commands[i].trigger.toLowerCase() == str) {
					try{
						var val:* = doCommand(commands[i], commandArgs, sub);
					}catch (e:Error) {
						throw(e);
					}
					if(!sub && val!=null && val!=undefined) console.print(val);
					return val;
				}
			}
			throw new Error("No such command");
		}
		public function doCommand(command:ConsoleCommand,commandArgs:Vector.<CommandArgument> = null,sub:Boolean = false):*
		{
			if (!commandArgs) commandArgs = new Vector.<CommandArgument>();
			var args:Array = [];
			for (var i:int = 0; i < commandArgs.length; i++) 
			{
				args.push(commandArgs[i].data);
			}
			var val:*;
			if (command is FunctionCallCommand) {
				var func:FunctionCallCommand = (command as FunctionCallCommand);
				try {
					val = func.callback.apply(null, args);
					return val;
				}catch (e:Error) {
					//try again with all args as string
					try {
						var joint:String = args.join(" ");
						if (joint.length>0){
							val = func.callback.call(null, joint);
						}else {
							val = func.callback.call(null);
						}
						return val;
					}catch (e:Error) {
						console.print(e.getStackTrace(), MessageTypes.ERROR);
						return null;
					}
					throw new Error(e.message);
				}catch (e:Error) {
					console.print(e.getStackTrace(), MessageTypes.ERROR);
					return null;
				}
			}else {
				console.print("Abstract command, no action", MessageTypes.ERROR);
				return null;
			}
		}
		
		/**
		 * List available command phrases
		 */
		public function listCommands(searchStr:String = null):void {
			var str:String = "Available commands: ";
			if (searchStr) str += " (search for '" + searchStr+"')";
			console.print(str,MessageTypes.SYSTEM);
			for (var i:int = 0; i < commands.length; i++) 
			{
				if (searchStr) {
					var joint:String = commands[i].grouping + commands[i].trigger + commands[i].helpText + commands[i].returnType;
					if (joint.toLowerCase().indexOf(searchStr) == -1) continue;
				}
				console.print("	--> "+commands[i].grouping+" : "+commands[i].trigger,MessageTypes.SYSTEM);
			}
		}
		public function parseForCommand(str:String):ConsoleCommand {
			for (var i:int = commands.length; i--; ) 
			{
				if (commands[i].trigger.toLowerCase() == str.split(" ")[0].toLowerCase()) {
					return commands[i];
				}
			}
			throw new Error("No command found");
		}
		public function parseForSubCommand(arg:String):* {
			
			return arg;
		}
		
		//authentication
		public function setupAuthentication(password:String):void {
			this.password = password;
			authenticated = false;
			if (authenticationSetup) return;
			authenticationSetup = true;
			console.addCommand(authCommand);
			console.addCommand(deAuthCommand);
		}
		
		private function lock():void
		{
			authenticated = false;
			console.print("Deauthorized", MessageTypes.SYSTEM);
		}
		public function authenticate(password:String):void {
			if (password == this.password) {
				authenticated = true;
				console.print("Authorized", MessageTypes.SYSTEM);
			}else {
				console.print("Not authorized", MessageTypes.ERROR);
			}
		}
		public function doSearch(search:String):Vector.<String>
		{
			var result:Vector.<String> = new Vector.<String>;
			var s:String = search.toLowerCase();
			for (var i:int = 0; i < commands.length; i++) 
			{
				var c:ConsoleCommand = commands[i];
				if (c.trigger.toLowerCase().indexOf(s, 0) > -1) {
					result.push(c.trigger);
				}
			}
			return result;
		}
		
		
	}

}