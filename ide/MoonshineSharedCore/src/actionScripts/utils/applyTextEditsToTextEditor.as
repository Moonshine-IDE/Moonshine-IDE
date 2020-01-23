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
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.TextEdit;

	public function applyTextEditsToTextEditor(textEditor:TextEditor, textEdits:Vector.<TextEdit>):void
	{
		var change:TextChangeBase = getTextChangeFromTextEdits(textEdits);

		var line:int = textEditor.model.selectedLineIndex;
		var char:int = textEditor.model.caretIndex;
		var scrollPosition:int = textEditor.model.scrollPosition;
		var textEditsCount:int = textEdits.length;
		for(var i:int = 0; i < textEditsCount; i++)
		{
			var textEdit:TextEdit = textEdits[i];
			var range:Range = textEdit.range;
			var start:Position = range.start;
			var end:Position = range.end;
			if(start.line !== end.line || start.character !== end.character)
			{
				if(end.line > start.line)
				{
					line -= (end.line - start.line);
				}
			}
			if(start.line <= line)
			{
				var newLines:Array = textEdit.newText.split("\n");
				line += (newLines.length - 1);
			}
		}

		textEditor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change));
		textEditor.model.selectedLineIndex = line;
		textEditor.model.caretIndex = char;
		textEditor.scrollTo(scrollPosition);
	}
}
