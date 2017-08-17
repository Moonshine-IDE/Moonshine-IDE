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
package no.doomsday.console.core.persistence 
{
	import flash.net.SharedObject;
	import no.doomsday.console.core.commands.ConsoleCommand;
	import no.doomsday.console.core.DConsole;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class PersistenceManager
	{
		private var console:DConsole;
		private var _numLines:int = 10;
		private var _previousCommands:Array;
		private var _commandIndex:int;
		private var historySO:SharedObject;
		public var maxHistory:int = 10;
		private var _dockState:int = 0;
		public function PersistenceManager(console:DConsole) 
		{
			this.console = console;
			historySO = SharedObject.getLocal("consoleHistory");
			if (!historySO.data.history) historySO.data.history = [];
			if (!historySO.data.numLines) historySO.data.numLines = numLines;
			if (!historySO.data.dockState) historySO.data.dockState = _dockState;
			numLines = historySO.data.numLines;
			previousCommands = historySO.data.history;
			_dockState = historySO.data.dockState;
			commandIndex = previousCommands.length;
		}
		public function clearHistory():void
		{
			historySO.data.history = [];
		}
		
		public function get dockState():int { return _dockState; }
		
		public function set dockState(value:int):void 
		{
			_dockState = value;
			historySO.data.dockState = _dockState;
		}
		
		public function get commandIndex():int { return _commandIndex; }
		
		public function set commandIndex(value:int):void 
		{
			_commandIndex = value;
		}
		
		public function get previousCommands():Array { return _previousCommands; }
		
		public function set previousCommands(value:Array):void 
		{
			_previousCommands = value;
			historySO.data.history = _previousCommands;
		}
		
		public function get numLines():int { return _numLines; }
		
		public function set numLines(value:int):void 
		{
			_numLines = value;
			historySO.data.numLines = _numLines;
		}
		
		public function historyUp():String {
			if(previousCommands.length>0){
				commandIndex = Math.max(commandIndex-=1,0);
				return previousCommands[commandIndex];
			}
			return "";
		}
		public function historyDown():String {
			if(commandIndex<previousCommands.length-1){
				commandIndex = Math.min(commandIndex += 1, previousCommands.length - 1);
				return previousCommands[commandIndex];
			}
			return "";
		}
		public function addtoHistory(cmdStr:String):Boolean {
			if (previousCommands[previousCommands.length - 1] != cmdStr) {
				previousCommands.push(cmdStr);
				if (previousCommands.length > maxHistory) {
					previousCommands.shift();
				}
			}
			commandIndex = previousCommands.length;
			return true;
		}
		
	}

}