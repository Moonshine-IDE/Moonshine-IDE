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
    
    import mx.controls.Alert;
    import mx.events.CloseEvent;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.EditorPluginEvent;
    import actionScripts.events.FileChangeEvent;
    import actionScripts.events.FilePluginEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.OpenFileEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.editor.ActionScriptTextEditor;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.notifier.ActionNotifier;
    import actionScripts.utils.UtilsCore;
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
		private var lastOpenEvent:OpenFileEvent;

		public function execute(event:Event):void
		{
			ActionNotifier.getInstance().notify("Open file");
			model = IDEModel.getInstance();
			
			if (event is OpenFileEvent)
			{
				var e:OpenFileEvent = event as OpenFileEvent;
				lastOpenEvent = e;
				if (e.file)
				{
					// in case of awd file proceed to different process
					if (e.file.fileBridge.extension == "awd")
					{
						GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.OPEN_PROJECT_AWAY3D, e.file));
						return;
					}
					
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

			var isFileOpen:Boolean = false;
			
			// If file is open already, just focus that editor.
			for each (var contentWindow:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = contentWindow as BasicTextEditor;
				if (ed
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == file.fileBridge.nativePath)
				{
					isFileOpen = true;
					model.activeEditor = ed;
					if (atLine > -1)
					{
						ed.getEditorComponent().scrollTo(atLine, openType);
						if (!openType || openType == OpenFileEvent.OPEN_FILE || openType == OpenFileEvent.JUMP_TO_SEARCH_LINE)
						{
							ed.getEditorComponent().selectLine(atLine);
                        }
						else if (openType == OpenFileEvent.TRACE_LINE)
						{
							ed.getEditorComponent().selectTraceLine(atLine);
                        }

						if (atChar > -1)
						{
							ed.getEditorComponent().model.caretIndex = atChar;
						}
					}
					return;
				}
			}
			
			// @note
			// https://github.com/prominic/Moonshine-IDE/issues/31
			// when file is not open and a debug-trace call happens
			// it never goes through the selectTraceLine(..) command for the
			// particular file, because its yet to be open. 
			// thus we need some way to determine if a file needs to focus
			// to its breakpoint once it opens.
			if (!isFileOpen && openType == OpenFileEvent.TRACE_LINE)
			{
				DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH = file.fileBridge.nativePath;
				DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE = atLine;
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
			if (UtilsCore.isBinary(value.toString())) openBinaryFile();
			else openTextFile(value);
			
			fileFault(null);
		}
		
		private function fileLoadedFromLocal(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, fileLoadedFromLocal);
			
			if (UtilsCore.isBinary(file.fileBridge.data.toString()))
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
			Alert.show("Unable to open binary file "+ file.name +".\nDo you want to open the file by operating system?", "Error!", Alert.YES|Alert.NO, null, function (event:CloseEvent):void
			{
				if (event.detail == Alert.YES)
				{
					file.fileBridge.openWithDefaultApplication();
				}
			});
			// Let WebKit try to display binary files (works for images)
			/*var htmlViewer:BasicHTMLViewer = new BasicHTMLViewer();
			htmlViewer.open(file);
			
			ged.dispatchEvent(
				new AddTabEvent(htmlViewer)
			);*/
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
				var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(wrapper) as AS3ProjectVO;
                var extension:String = file.fileBridge.extension;

				if (!project)
				{
					project = model.activeProject as AS3ProjectVO;
                }

				if (project && project.isVisualEditorProject && (extension == "mxml" || extension == "xhtml"))
				{
					 editor = model.visualEditorCore.getVisualEditor(project);
				}
				else
                {
                    if (extension === "as" || extension === "mxml")
                    {
                        editor = new ActionScriptTextEditor();
                    }
                    else
                    {
                        editor = new BasicTextEditor();
                    }
                }

                // requires in case of project deletion and closing all the opened
                // file instances belongs to the project
                if (wrapper) editor.projectPath = wrapper.projectReference.path;
			}

			// Let plugins hook in syntax highlighters & other functionality
			var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
			editorEvent.editor = editor.getEditorComponent();
			editorEvent.file = file;
			editorEvent.fileExtension = file.fileBridge.extension;
			ged.dispatchEvent(editorEvent);
			
			editor.lastOpenType = lastOpenEvent ? lastOpenEvent.type : null;
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
			{
				editor.scrollTo(atLine, lastOpenEvent.type);
			}

			ged.dispatchEvent(
				new AddTabEvent(editor)
			);
		}
	}
}