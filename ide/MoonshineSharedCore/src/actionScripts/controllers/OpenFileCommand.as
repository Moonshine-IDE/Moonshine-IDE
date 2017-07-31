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
	import flash.events.Event;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.EditorPluginEvent;
	import actionScripts.events.FileChangeEvent;
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicHTMLViewer;
	import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.VisualEditorCodeViewer;
    import actionScripts.ui.notifier.ActionNotifier;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.URLDescriptorVO;

	public class OpenFileCommand implements ICommand
	{
		protected var model:IDEModel;
		protected var file:FileLocation;
		protected var wrapper:FileWrapper;
		protected var atLine:int = -1;
		protected var atChar:int = -1;
		protected var openAsTourDe:Boolean;
		protected var tourDeSWFSource:String;
		protected var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		private var loader: DataAgent;

		public function execute(event:Event):void
		{
			ActionNotifier.getInstance().notify("Open file");
			model = IDEModel.getInstance();
			
			if (event is OpenFileEvent)
			{
				var e:OpenFileEvent = event as OpenFileEvent;
				if (e.file)
				{
					openAsTourDe = e.openAsTourDe;
					tourDeSWFSource = e.tourDeSWFSource;
					wrapper = e.wrapper;
					file = e.file;
					if (e.atLine > -1)
					{
						atLine = e.atLine;
						if (e.atChar > -1)
						{
							atChar = e.atChar;
						}
					}
					openFile(null, event.type);
					return;
				}
			}
			
			if (ConstantsCoreVO.IS_AIR)
			{
				file = new FileLocation();
				file.fileBridge.browseForOpen("Open File", openFile, cancelOpenFile, ["*.as;*.mxml;*.css;*.txt;*.js;*.xml"]);
			}
		}
		
		protected function cancelOpenFile():void
		{
			/*event.target.removeEventListener(Event.SELECT, openFile);
			event.target.removeEventListener(Event.CANCEL, cancelOpenFile);*/
		}

		protected function openFile(fileDir:Object=null, openType:String=null):void
		{
			if (fileDir) file = new FileLocation(fileDir.nativePath);
			// If file is open already, just focus that editor.
			for each (var contentWindow:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = contentWindow as BasicTextEditor;
				if (ed
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath)
				{
					model.activeEditor = ed;
					if (atLine > -1)
					{
						ed.getEditorComponent().scrollTo(atLine);
						if (!openType || openType == OpenFileEvent.OPEN_FILE) ed.getEditorComponent().selectLine(atLine);
						else if (openType == OpenFileEvent.TRACE_LINE) ed.getEditorComponent().selectTraceLine(atLine);
						if (atChar > -1)
						{
							ed.getEditorComponent().model.caretIndex = atChar;
						}
					}
					return;
				}
			}
			
			// Let plugins know that we're opening a file & abort it if they want to render it themselves
			var plugEvent:FilePluginEvent = new FilePluginEvent(FilePluginEvent.EVENT_FILE_OPEN, file);
			ged.dispatchEvent(plugEvent);
			if (plugEvent.isDefaultPrevented())
				return;
			
			// Load and see if it's a binary file
			if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.getFile.addEventListener(Event.COMPLETE, fileLoadedFromLocal);
				file.fileBridge.load();
				GlobalEventDispatcher.getInstance().dispatchEvent(new FileChangeEvent(FileChangeEvent.EVENT_FILECHANGE,file.fileBridge.nativePath,0,0,0));
			}
			else
			{
				if (wrapper) wrapper.isWorking = true;
				loader = new DataAgent(URLDescriptorVO.FILE_OPEN, fileLoadedFromServer, fileFault, {path:file.fileBridge.nativePath});
			}
		}
		
		private function fileLoadedFromServer(value:Object, message:String=null):void
		{
			// Test if file is binary
			var binary:Boolean = /[\x00-\x08\x0E-\x1F]/.test(value.toString());
			
			if (binary) openBinaryFile();
			else openTextFile(value);
			
			fileFault(null);
		}
		
		private function fileLoadedFromLocal(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, fileLoadedFromLocal);
			
			// Test if file is binary
			var binary:Boolean = /[\x00-\x08\x0E-\x1F]/.test(file.fileBridge.data.toString());
			
			if (binary)
			{
				openBinaryFile();
            }
			else if (openAsTourDe)
			{
				openTextFile(null, true);
            }
			else
			{
				openTextFile(null);
            }
		}
		
		private function fileFault(message:String):void
		{
			if (wrapper) wrapper.isWorking = false;
			loader = null;
			wrapper = null;
			file = null;
		}
		
		private function openBinaryFile():void
		{
			// Let WebKit try to display binary files (works for images)
			var htmlViewer:BasicHTMLViewer = new BasicHTMLViewer();
			htmlViewer.open(file);
			
			ged.dispatchEvent(
				new AddTabEvent(htmlViewer)
			);
		}
		
		private function openTextFile(value:Object, asTourDe:Boolean=false):void
		{
			// Open all text files with basic text editor
			var editor:BasicTextEditor = null;
			if(asTourDe)
			{
				editor = model.flexCore.getTourDeEditor(tourDeSWFSource);
			}
			else
			{
				var activeProject:AS3ProjectVO = model.activeProject as AS3ProjectVO;
				if (activeProject && activeProject.isVisualEditorProject)
				{
					 editor = new VisualEditorCodeViewer();
				}
				else
                {
                    var extension:String = file.fileBridge.extension;
                    if (extension === "as" || extension === "mxml")
                    {
                        editor = new ActionScriptTextEditor();
                    }
                    else
                    {
                        editor = new BasicTextEditor()
                    }
                }
			}

			// Let plugins hook in syntax highlighters & other functionality
			var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
			editorEvent.editor = editor.getEditorComponent();
			editorEvent.file = file;
			editorEvent.fileExtension = file.fileBridge.extension;
			ged.dispatchEvent(editorEvent);
			
			if (!ConstantsCoreVO.IS_AIR)
			{
				var rawData:String = String(value);
				var jsonObj:Object = JSON.parse(rawData);
				editor.open(file, jsonObj.text);
			}
			else
			{
				editor.open(file);
			}
			
			if (atLine > -1)
				editor.scrollTo(atLine);

			ged.dispatchEvent(
				new AddTabEvent(editor)
			);
		}

	}
}