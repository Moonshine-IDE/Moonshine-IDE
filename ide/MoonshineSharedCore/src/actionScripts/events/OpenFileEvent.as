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

	public class OpenFileEvent extends Event
	{
		public static const OPEN_FILE:String = "openFileEvent";
		public static const TRACE_LINE:String = "traceLineEvent";
		
		public var file:FileLocation;
		public var atLine:int;
		public var atChar:int = -1;
		public var wrapper:FileWrapper;
		public var openAsTourDe:Boolean;
		public var tourDeSWFSource:String;
		
		public function OpenFileEvent(type:String, file:FileLocation=null, atLine:int = -1, wrapper:FileWrapper=null, ...param)
		{
			this.file = file;
			this.atLine = atLine;
			this.wrapper = wrapper;
			if (param && param.length > 0)
			{
				this.openAsTourDe = param[0];
				if (this.openAsTourDe) this.tourDeSWFSource = param[1];
			}
			
			super(type, false, true);
		}
		
	}
}