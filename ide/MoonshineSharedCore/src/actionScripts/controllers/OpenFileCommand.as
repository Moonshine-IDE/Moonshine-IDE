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
    import actionScripts.events.FilePluginEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.OpenFileEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IFileContentWindow;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.notifier.ActionNotifier;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectVO;
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
		private var binaryFiles:Array;		
		private var countIndex:int;

		public function execute(event:Event):void
		{
			ActionNotifier.getInstance().notify("Open file");
			model = IDEModel.getInstance();

			if (event is OpenFileEvent)
			{
				binaryFiles = [];
				countIndex = 0;
				
				var openFileEvent:OpenFileEvent = event as OpenFileEvent;
				lastOpenEvent = openFileEvent;
				openAsTourDe = openFileEvent.openAsTourDe;
				tourDeSWFSource = openFileEvent.tourDeSWFSource;
				if (openFileEvent.atLine > -1)
				{
					atLine = openFileEvent.atLine;
					if (openFileEvent.atChar > -1)
					{
						atChar = openFileEvent.atChar;
					}
				}
				if (openFileEvent.wrappers && openFileEvent.wrappers.length > 0)
				{
					wrapper = openFileEvent.wrappers[0];
				}
				prepareBeforeOpen();
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				var tmpRedableFiles:Array = ConstantsCoreVO.READABLE_FILES.map(function(element:String, index:int, arr:Array):String {
					return "*."+ element;
				});
				model.fileCore.browseForOpen("Open File", openFile, cancelOpenFile, [tmpRedableFiles.join(";")]);
			}
		}
		
		protected function prepareBeforeOpen():void
		{
			var tmpFL:FileLocation;
			var tmpFW:FileWrapper;
			if (lastOpenEvent.files)
			{
				if (lastOpenEvent.files.length != 0)
				{
					tmpFL = lastOpenEvent.files[0];
					// in case of awd file proceed to different process
					if (tmpFL.fileBridge.extension == "awd")
					{
						GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.OPEN_PROJECT_AWAY3D, tmpFL));
						fileLoadCompletes(null);
					}
					else
					{
						tmpFL.fileBridge.getFile.addEventListener(Event.COMPLETE, fileLoadCompletes);
						tmpFL.fileBridge.load();
					}
				}
				else
				{
					if (binaryFiles.length > 0) openBinaryFiles(binaryFiles);
				}
			}
			else
			{
				openFile(null, lastOpenEvent.type);
			}
			
			/*
			* @local
			*/
			function fileLoadCompletes(event:Event):void
			{
				if (event)
				{
					event.target.removeEventListener(Event.COMPLETE, fileLoadCompletes);

					// IMPORTANT
					// ===============================
					// Following is a temporary solution to the problem
					// to determine between binary and text-file which
					// discussed here:
					// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/770#issuecomment-1020669043 .
					// This solution should removed once we address to:
					// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/966.
					//
					// Pass binary test for log-extension file:
					// tmpFL.fileBridge.extension.toLowerCase() != "log"
					// ===============================
					if ((tmpFL.fileBridge.extension && tmpFL.fileBridge.extension.toLowerCase() != "log") &&
							UtilsCore.isBinary(event.target.data.toString()))
					{
						binaryFiles.push(tmpFL);
					}
					else
					{
						openFile(tmpFL, lastOpenEvent.type, tmpFW, (event.target.data as String));
					}
				}
				
				lastOpenEvent.files.shift();
				countIndex++;
				prepareBeforeOpen();
			}
		}
		
		protected function cancelOpenFile():void
		{
			/*event.target.removeEventListener(Event.SELECT, openFile);
			event.target.removeEventListener(Event.CANCEL, cancelOpenFile);*/
		}

		protected function openFile(fileDir:Object=null, openType:String=null, fileWrapper:FileWrapper=null, fileData:String=null):void
		{
			if (fileDir) 
			{
				if (fileDir is FileLocation) file = fileDir as FileLocation;
				else file = new FileLocation(fileDir.nativePath);
			}

			var isFileOpen:Boolean = false;
			
			// If file is open already, just focus that editor.
			for each (var contentWindow:IContentWindow in model.editors)
			{
				if (contentWindow is IFileContentWindow)
				{
					var contentWindowFile:FileLocation = (contentWindow as IFileContentWindow).currentFile;
					if (contentWindowFile == null) {
						continue;
					}
					// on case-insensitive file systems, these may not match
					// unless we canonicalize, and then we'd get the same file
					// opened in multiple tabs
					contentWindowFile.fileBridge.canonicalize();
					file.fileBridge.canonicalize();
					if(contentWindowFile.fileBridge.nativePath == file.fileBridge.nativePath)
					{
						isFileOpen = true;
						model.activeEditor = contentWindow;
						
						if ((contentWindow is BasicTextEditor) && (atLine > -1))
						{
							var ed:BasicTextEditor = contentWindow as BasicTextEditor;

							atChar = atChar != -1 ? atChar: 0;
							ed.setSelection(atLine, atChar, atLine, atChar);
							ed.scrollToCaret();
							if (openType == OpenFileEvent.TRACE_LINE)
							{
								ed.editor.debuggerLineIndex = atLine;
							}
						}

						contentWindow.setFocus();
						return;
					}
				}
			}
			
			// @note
			// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/31
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
			// as this will add a link to RECENT items, add only for non 'Tour de Flex' items
			if (!openAsTourDe)
			{
				var plugEvent:FilePluginEvent = new FilePluginEvent(FilePluginEvent.EVENT_FILE_OPEN, file);
				ged.dispatchEvent(plugEvent);
				if (plugEvent.isDefaultPrevented())
					return;
			}
			
			// Load and see if it's a binary file
			if (ConstantsCoreVO.IS_AIR)
			{
				var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(wrapper);
				var extension:String = file.fileBridge.extension;

				// some file may not have an extension
				if (extension)
				{
					extension = extension.toLowerCase()
				}

				if (openAsTourDe) 
				{
					openTourDeFile(fileData);
				}
				else if ((project is OnDiskProjectVO) && (extension == "dfb")) 
				{
					openTabularInterfaceEditorFile(project);
				}
				else
				{
					//try to open dve with domino visual editor.
					 /*if ((project is OnDiskProjectVO) && (extension == "dve"))
					 {
						 (project as OnDiskProjectVO).isDominoVisualEditorProject=true;
					 }*/
					/*else if (file && file.fileBridge.nativePath.indexOf("Royale")>0){
						(project as AS3ProjectVO).isVisualEditorProject=false;
						//Alert.show("AS3ProjectVO 254"+(project as AS3ProjectVO).isVisualEditorProject);
					}*/
	
					openTextFile(project, fileData);
				}
			}
			else
			{
				if (wrapper) wrapper.isWorking = true;
				file = fileDir as FileLocation;
				loader = new DataAgent(URLDescriptorVO.FILE_OPEN, fileLoadedFromServer, fileFault, {path:fileDir.fileBridge.nativePath});
			}
		}
		
		private function fileLoadedFromServer(value:Object, message:String=null):void
		{
			if (UtilsCore.isBinary(value.toString())) openBinaryFiles([file]);
			else 
			{
				var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(wrapper);
				openTextFile(project, value);
			}
			
			fileFault(null);
		}
		
		private function fileFault(message:String):void
		{
			if (wrapper) wrapper.isWorking = false;
			loader = null;
			wrapper = null;
			file = null;
		}
		
		private function openBinaryFiles(files:Array):void
		{
			if (files.length == 0)
				return;

			var isUnknownBinaryAvailable:Boolean = files.some(function(element:FileLocation, index:int, arr:Array):Boolean
			{
				return (ConstantsCoreVO.KNOWN_BINARY_FILES.indexOf(element.fileBridge.extension) == -1);
			});

			if (isUnknownBinaryAvailable)
			{
				var alertMessage:String;
				if (files.length > 1)
				{
					Alert.buttonWidth = 90;
					Alert.yesLabel = "Open All";
					Alert.cancelLabel = "Cancel All";
					alertMessage = "One or more binary files unknown to Moonshine-IDE.\nDo you want to open the files with the default system applications?";
				}
				else
				{
					alertMessage = "Unable to open binary file "+ files[0].name +".\nDo you want to open the file with the default system application?"
				}

				Alert.show(alertMessage, "Confirm!", Alert.YES|Alert.CANCEL, null, function (event:CloseEvent):void
				{
					Alert.buttonWidth = 65;
					Alert.yesLabel = "Yes";
					Alert.cancelLabel = "Cancel";

					if (event.detail == Alert.YES)
					{
						runAllBinaryFiles();
					}
				});
			}
			else
			{
				runAllBinaryFiles();
			}

			/*
			 * @local
			 */
			function runAllBinaryFiles():void
			{
				files.forEach(function (element:FileLocation, index:int, arr:Array):void
				{
					element.fileBridge.openWithDefaultApplication();
				});
			}
		}
		
		private function openTourDeFile(value:Object):void
		{
			var editor:BasicTextEditor = null;
			editor = model.flexCore.getTourDeEditor(tourDeSWFSource);

			var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
			editorEvent.editor = editor.getEditorComponent();
			editorEvent.file = file;
			editorEvent.fileExtension = file.fileBridge.extension;
			GlobalEventDispatcher.getInstance().dispatchEvent(editorEvent);

			editor.open(file, value);
			
			ged.dispatchEvent(
				new AddTabEvent(editor)
			);
		}
		
		private function openTabularInterfaceEditorFile(project:ProjectVO):void
		{
			var editor:IContentWindow = model.ondiskCore.getTabularInterfaceEditor(file, project as OnDiskProjectVO);
			
			ged.dispatchEvent(
				new AddTabEvent(editor)
			);
		}
		
		private function openTextFile(project:ProjectVO, value:Object):void
		{
			// Open all text files with basic text editor
			var editor:BasicTextEditor = null;
			var extension:String = file.fileBridge.extension;
			if (!project)
			{
				project = model.activeProject;
			}


			if ((project is AS3ProjectVO &&
				(project as AS3ProjectVO).isVisualEditorProject &&
				(extension == "mxml" || extension == "xhtml" || extension == "form"|| extension == "page") && !lastOpenEvent.independentOpenFile) || 
				(project is OnDiskProjectVO) && (extension == "dve") )
			{
				editor = model.visualEditorCore.getVisualEditor(project);
			}
			else if((lastOpenEvent && !lastOpenEvent.independentOpenFile) && 
				model.languageServerCore.hasCustomTextEditorForUri(file.fileBridge.url, project))
			{
				editor = model.languageServerCore.getCustomTextEditorForUri(file.fileBridge.url, project);
			}
			else
			{
				editor = new BasicTextEditor();
			}
			
			// requires in case of project deletion and closing all the opened
			// file instances belongs to the project
			if (wrapper) editor.projectPath = wrapper.projectReference.path;

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
				editor.open(file, value);
			}
			
			if (atLine > -1)
			{
				editor.setSelection(atLine, 0, atLine, 0);
				editor.scrollToCaret();
			}

			ged.dispatchEvent(
				new AddTabEvent(editor)
			);
		}
	}
}