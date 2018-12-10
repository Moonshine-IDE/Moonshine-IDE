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
	import actionScripts.events.ChangeEvent;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.TextEdit;

	public function applyTextEditsToTextEditor(textEditor:TextEditor, textEdits:Vector.<TextEdit>):void
	{
		var multi:TextChangeMulti = new TextChangeMulti();
		var textEditsCount:int = textEdits.length;
		var line:int = textEditor.model.selectedLineIndex;
		var char:int = textEditor.model.caretIndex;
		for(var i:int = 0; i < textEditsCount; i++)
		{
			var change:TextEdit = textEdits[i];
			var range:Range = change.range;
			var start:Position = range.start;
			var end:Position = range.end;
			var insert:TextChangeInsert = new TextChangeInsert(start.line, start.character, Vector.<String>(change.newText.split("\n")));
			if(start.line !== end.line || start.character !== end.character)
			{
				var remove:TextChangeRemove = new TextChangeRemove(start.line, start.character, end.line, end.character);
				multi.changes.push(remove);
				if(end.line > start.line)
				{
					line -= (end.line - start.line);
				}
			}
			multi.changes.push(insert);
			if(start.line <= line)
			{
				line += (insert.textLines.length - 1);
			}
		}
		textEditor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, multi));
		textEditor.model.selectedLineIndex = line;
		textEditor.model.caretIndex = char;
	}
}
