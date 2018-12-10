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
	
	public class TemplatingEvent extends Event
	{
		public static const ADDED_NEW_TEMPLATE:String = "ADDED_NEW_TEMPLATE";
		public static const REMOVE_TEMPLATE:String = "REMOVE_TEMPLATE";
		public static const RENAME_TEMPLATE:String = "RENAME_TEMPLATE";
		
		public var label:String;
		public var newLabel:String;
		public var newFileTemplate:FileLocation;
		public var listener:String;
		public var isProject:Boolean;
		
		public function TemplatingEvent(type:String, isProject:Boolean, label:String, listener:String=null, newLabel:String=null, newFileTemplate:FileLocation=null)
		{
			this.isProject = isProject;
			this.label = label;
			this.newLabel = newLabel;
			this.newFileTemplate = newFileTemplate;
			this.listener = listener;
			
			super(type, false, false);
		}
		
		public override function clone():Event
		{
			return new TemplatingEvent(type, isProject, label, listener, newLabel);
		}
	}
}