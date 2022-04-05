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
	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.changes.TextEditorChange;
	import moonshine.editor.text.events.TextEditorChangeEvent;
	import moonshine.editor.text.utils.LspTextEditorUtil;
	import moonshine.lsp.TextEdit;

	public function applyTextEditsToTextEditor(textEditor:TextEditor, textEdits:Array /* Array<TextEdit> */):void
	{
		var changes:Array = textEdits.map(function(textEdit:TextEdit, index:int, array:Array):TextEditorChange
		{
			return LspTextEditorUtil.lspTextEditToTextEditorChange(textEdit);
		});

		textEditor.dispatchEvent(new TextEditorChangeEvent(TextEditorChangeEvent.TEXT_CHANGE, changes));
	}
}
