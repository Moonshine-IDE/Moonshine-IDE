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
	
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.valueObjects.FileWrapper;

	public class TreeMenuItemEvent extends Event
	{
		public static const RIGHT_CLICK_ITEM_SELECTED:String = "menuItemSelectedEvent";
		public static const EDIT_INIT:String = "editInit";
		public static const EDIT_CANCEL:String = "editCancel";
		public static const EDIT_END:String = "editEnd";
		public static const ADD_NEW_FOLDER:String = "ADD_NEW_FOLDER";
		public static const NEW_FILE_CREATED:String = "NEW_FILE_CREATED";
		
		public var menuLabel:String;
		public var data:FileWrapper;
		public var renderer:FTETreeItemRenderer;
		public var extra:*;
		
		public function TreeMenuItemEvent(type:String, menuLabel:String, data:FileWrapper)
		{
			this.menuLabel = menuLabel;
			this.data = data;
			
			super(type, true, false);
		}
		
	}
}