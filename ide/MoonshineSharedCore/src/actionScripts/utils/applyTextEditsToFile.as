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
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.valueObjects.TextEdit;

	public function applyTextEditsToFile(file:FileLocation, textEdits:Vector.<TextEdit>):void
	{
		var textEditor:TextEditor = findOpenTextEditor(file);
		if(textEditor !== null)
		{
			applyTextEditsToTextEditor(textEditor, textEdits);
			return;
		}

		var content:String = file.fileBridge.read() as String;
		var contentLines:Array = content.split("\n");
		var textModelLines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
		for (var i:int = 0; i < contentLines.length; i++)
		{
			var text:String = contentLines[i];
			var lineModel:TextLineModel = new TextLineModel(text);
			textModelLines.push(lineModel);
		}
		
		var change:TextChangeBase = getTextChangeFromTextEdits(textEdits);
		change.apply(textModelLines);

		content = textModelLines.join("\n");

		file.fileBridge.save(content);
	}
}
