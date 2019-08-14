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
package actionScripts.controllers
{
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.TextEditorModel;
	import actionScripts.valueObjects.Location;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.ProjectVO;

	import flash.events.Event;

	public class OpenLocationCommand implements ICommand
	{
		public function execute(event:Event):void
		{
			var location:Location = OpenLocationEvent(event).location;
			var uri:String = location.uri;
			var lsc:ILanguageServerBridge = IDEModel.getInstance().languageServerCore;
			var project:ProjectVO = IDEModel.getInstance().activeProject;
			if(!lsc.hasCustomTextEditorForUri(uri, project))
			{
				//we should never get here, but this will save us if we do
				return;
			}
			
			var colonIndex:int = uri.indexOf(":");
			var scheme:String = uri.substr(0, colonIndex);
			if(scheme == "file")
			{
				var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
					[new FileLocation(location.uri, true)], location.range.start.line);
				openEvent.atChar = location.range.start.character;
				GlobalEventDispatcher.getInstance().dispatchEvent(openEvent);
			}
			else
			{
				var editor:BasicTextEditor = lsc.getCustomTextEditorForUri(uri, project, true);
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(editor)
				);
				var start:Position = location.range.start;
				if (start.line > -1)
				{
					var editorComponent:TextEditor = editor.getEditorComponent();
					editorComponent.scrollTo(start.line, OpenFileEvent.OPEN_FILE);
					editorComponent.selectLine(start.line);
					if(start.character > -1)
					{
						editorComponent.model.caretIndex = start.character;
					}
				}
				editor.callLater(function():void
				{
					//for some reason this does not work immediately
					editor.setFocus();
				});
			}
		}
	}
}