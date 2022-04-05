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
	import actionScripts.factory.FileLocation;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.changes.TextEditorChange;
	import moonshine.editor.text.utils.LspTextEditorUtil;
	import moonshine.editor.text.utils.TextEditorUtil;
	import moonshine.lsp.TextEdit;

	public function applyTextEditsToFile(file:FileLocation, textEdits:Array /* Array<TextEdit> */):void
	{
		var textEditor:TextEditor = findOpenTextEditor(file);
		if(textEditor !== null)
		{
			applyTextEditsToTextEditor(textEditor, textEdits);
			return;
		}

		var content:String = file.fileBridge.read() as String;
		var contentLines:Array = content.split("\n");
		
		var changes:Array = textEdits.map(function(textEdit:TextEdit, index:int, array:Array):TextEditorChange
		{
			return LspTextEditorUtil.lspTextEditToTextEditorChange(textEdit);
		});
		changes.forEach(function(textEditorChange:TextEditorChange, index:int, array:Array):void
		{
			contentLines = TextEditorUtil.applyTextChangeToLines(contentLines, textEditorChange);
		});

		content = contentLines.join("\n");

		file.fileBridge.save(content);
	}
}
