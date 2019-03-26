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
		public static const JUMP_TO_SEARCH_LINE:String = "jumpToLineEvent";
		
		public var files:Vector.<FileLocation>;
		public var atLine:int;
		public var atChar:int = -1;
		public var wrappers:Vector.<FileWrapper>;
		public var openAsTourDe:Boolean;
		public var tourDeSWFSource:String;
		
		public var independentOpenFile:Boolean; // when arbitrary file opened off-Moonshine, or drag into off-Moonshine  
		
		public function OpenFileEvent(type:String, files:Array=null, atLine:int = -1, wrappers:Array=null, ...param)
		{
			try
			{
				if (files) this.files = Vector.<FileLocation>(files as Array);
				if (wrappers) this.wrappers = Vector.<FileWrapper>(wrappers as Array);
			} 
			catch (e:Error)
			{
				trace("Error:: Unrecognized 'Open' object type.");
			}
			
			this.atLine = atLine;
			if (files.length > 1)
			{
				if (param && param.length > 0)
				{
					this.openAsTourDe = param[0];
					if (this.openAsTourDe) this.tourDeSWFSource = param[1];
				}
			}
			
			super(type, false, true);
		}
	}
}