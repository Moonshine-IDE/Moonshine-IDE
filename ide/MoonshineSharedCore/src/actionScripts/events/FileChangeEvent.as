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
	import actionScripts.factory.FileLocation;
	
	import flash.events.Event;

	public class FileChangeEvent extends Event
	{
		public static const EVENT_FILECHANGE:String = "newFileChangeEvent";
		
		public var filePath:String;
		public var rootPath:String;
		public var lineNumner:Number;
		public var carPosition:Number;
		public var version:Number;
		
		
		
		public function FileChangeEvent(type:String, filePath:String=null, lineNumner:Number = 0, carPosition:Number = 0,version:Number = 0 )
		{
			this.filePath = filePath;
			//this.rootPath = rootPath;
			this.lineNumner = lineNumner;
			this.carPosition = carPosition;
			this.version = version;
			super(type, false, true);
		}
		
	}
}