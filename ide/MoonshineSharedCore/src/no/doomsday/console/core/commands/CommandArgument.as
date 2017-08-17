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
	import no.doomsday.console.core.references.ReferenceManager;
	import no.doomsday.console.core.text.ParseUtils;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class CommandArgument
	{
		public var data:*;
		public function CommandArgument(data:String,commandManager:CommandManager,referenceManager:ReferenceManager) 
		{
			var tmp:* = data;
			
			switch(data.charAt(0)) {
				case "[":
				case "{":
				tmp = ParseUtils.parseForJson(data);
				break;
				case "(":
				tmp = tmp.slice(1, tmp.length - 1);
				tmp = commandManager.tryCommand(tmp, true);
				break;
				case "<":
				tmp = new XML(tmp);
				break;
			}
			if (tmp is String) {
				if (tmp == "false") {
					tmp = false;
				}else if (tmp == "true") {
					tmp = true;
				}
				try{
					tmp = referenceManager.parseForReferences([tmp])[0];
				}catch (e:Error) {
					
				}
			}
			this.data = tmp;
		}
		public function toString():String {
			return data.toString();
		}
		
	}

}