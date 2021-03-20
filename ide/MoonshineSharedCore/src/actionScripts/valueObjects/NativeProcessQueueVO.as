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
package actionScripts.valueObjects
{
	public class NativeProcessQueueVO
	{
		public var com:String;
		public var showInConsole:Boolean;
		public var processType:String;
		
		public var extraArguments:Array;
		
		public function NativeProcessQueueVO(com:String, showInConsole:Boolean, processType:String=null, ...args)
		{
			this.com = com;
			this.showInConsole = showInConsole;
			this.processType = processType;
			
			extraArguments = args;
		}
	}
}