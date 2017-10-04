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
package actionScripts.ui.editor.text
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.ui.editor.text.events.DebugLineEvent;

	public class DebugHighlightManager
	{
		public static var LAST_DEBUG_LINE_RENDERER:TextLineRenderer;
		public static var LAST_DEBUG_LINE_OBJECT:TextLineModel;
		public static var NONOPENED_DEBUG_FILE_PATH:String;
		public static var NONOPENED_DEBUG_FILE_LINE:int;
		
		private static var LAST_DEBUG_TEXT_EDITOR_OBJECT:TextEditorModel;
		private static var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		public static function init():void
		{
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_FINISH, onDebugFinishedEvent, false, 0, true);
		}
		
		public static function verifyNewFileOpen(value:TextEditorModel):void
		{
			if (LAST_DEBUG_TEXT_EDITOR_OBJECT && (value != LAST_DEBUG_TEXT_EDITOR_OBJECT)) onDebugFinishedEvent(null);
			LAST_DEBUG_TEXT_EDITOR_OBJECT = value;
		}
		
		private static function onDebugFinishedEvent(event:DebugLineEvent):void
		{
			if (!LAST_DEBUG_LINE_OBJECT) return;
			
			LAST_DEBUG_LINE_OBJECT.debuggerLineSelection = false;
			LAST_DEBUG_LINE_RENDERER.showTraceLines = LAST_DEBUG_LINE_RENDERER.traceFocus = false;
			LAST_DEBUG_TEXT_EDITOR_OBJECT.hasTraceSelection = false;
			LAST_DEBUG_LINE_OBJECT = null;
			LAST_DEBUG_LINE_RENDERER = null;
			LAST_DEBUG_TEXT_EDITOR_OBJECT = null;
		}
	}
}