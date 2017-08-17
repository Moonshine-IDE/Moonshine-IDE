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
	import flash.events.Event;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.ProjectVO;

	public class NewFileEvent extends Event
	{
		public static const EVENT_NEW_FILE:String = "newFileEvent";
		public static const EVENT_NEW_FOLDER:String = "EVENT_NEW_FOLDER";
		public static const EVENT_ANT_BIN_URL_SET:String = "EVENT_ANT_BIN_URL_SET";
		public static const EVENT_FILE_RENAMED:String = "EVENT_FILE_RENAMED";
		public static const EVENT_PROJECT_SELECTED:String = "EVENT_PROJECT_SELECTED";
		public static const EVENT_FILE_SELECTED:String = "EVENT_FILE_SELECTED";
		
		public var filePath:String;
		public var fileName:String;
		public var fromTemplate:FileLocation;
		public var insideLocation:FileWrapper;
		public var extraParameters:Array;
		
		public var ofProject:ProjectVO;
		
		public function NewFileEvent(type:String, filePath:String=null, fromTemplate:FileLocation=null, insideLocation:FileWrapper=null, ...param)
		{
			this.filePath = filePath;
			this.fromTemplate = fromTemplate;
			this.insideLocation = insideLocation;
			this.extraParameters = param;
			
			super(type, false, true);
		}
		
	}
}