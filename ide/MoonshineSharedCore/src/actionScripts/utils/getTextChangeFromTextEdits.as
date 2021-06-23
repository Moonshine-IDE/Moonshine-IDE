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
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import moonshine.lsp.TextEdit;
	import moonshine.lsp.Range;
	import moonshine.lsp.Position;
	import actionScripts.ui.editor.text.change.TextChangeMulti;

	public function getTextChangeFromTextEdits(textEdits:Array /* Array<TextEdit> */):TextChangeBase
	{
		var multi:TextChangeMulti = new TextChangeMulti();
		var textEditsCount:int = textEdits.length;
		for(var i:int = 0; i < textEditsCount; i++)
		{
			var textEdit:TextEdit = TextEdit(textEdits[i]);
			var range:Range = textEdit.range;
			var start:Position = range.start;
			var end:Position = range.end;
			var newLines:Vector.<String> = Vector.<String>(textEdit.newText.split("\n"));
			var insert:TextChangeInsert = new TextChangeInsert(start.line, start.character, newLines);
			if(start.line !== end.line || start.character !== end.character)
			{
				var remove:TextChangeRemove = new TextChangeRemove(start.line, start.character, end.line, end.character);
				multi.changes.push(remove);
			}
			multi.changes.push(insert);
		}
		return multi;
	}
}