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
package no.doomsday.console.core.messages
{
	
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class Message 
	{
		public var timestamp:String = "";
		public var text:String = "";
		public var repeatcount:int = 0;
		public var type:uint = 0;
		
		public function Message(text:String, timestamp:String, type:uint = 0) 
		{
			this.text = text;
			this.timestamp = timestamp;
			this.type = type;
		}
		
	}
	
}