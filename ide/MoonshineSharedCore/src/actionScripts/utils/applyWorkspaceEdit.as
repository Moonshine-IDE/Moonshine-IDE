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
package actionScripts.utils
{
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.valueObjects.TextEdit;

	import flash.events.Event;

	import mx.core.FlexGlobals;
	import actionScripts.valueObjects.WorkspaceEdit;

	public function applyWorkspaceEdit(edit:WorkspaceEdit):void
	{
		var changes:Object = edit.changes;
		for(var uri:String in changes)
		{
			var file:FileLocation = new FileLocation(uri, true);
			var textEdits:Vector.<TextEdit> = changes[uri];
			applyTextEditsToFile(file, textEdits);
		}
	}
}
