////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.languageServer
{
	import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;
    
	import actionScripts.events.SdkEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.ProjectEvent;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.valueObjects.Settings;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.editor.ActionScriptTextEditor;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.events.EditorPluginEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.events.FilePluginEvent;
    import actionScripts.events.SettingsEvent;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]
	public class ActionScriptLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_BIN_PATH:String = "elements/as3mxml-language-server/bin/";
		private static const BUNDLED_COMPILER_PATH:String = "elements/as3mxml-language-server/bundled-compiler/";
		private static const LANGUAGE_ID_ACTIONSCRIPT:String = "nextgenas";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";
		private static const METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION:String = "moonshine/didChangeProjectConfiguration";

		private static const URI_SCHEME_FILE:String = "file";
		private static const URI_SCHEME_SWC:String = "swc";

		private static const URI_SCHEMES:Vector.<String> = new <String>[URI_SCHEME_SWC];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["as", "mxml"];

		private var _project:AS3ProjectVO;
		private var _port:int;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _previousJavaPath:String = null;
		private var _previousSDKPath:String = null;

		public function ActionScriptLanguageServerManager(project:AS3ProjectVO)
		{
			_project = project;

			_project.addEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler, false, 0, true);
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler, false, 0, true);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			startNativeProcess();
		}

		public function get project():ProjectVO
		{
			return _project;
		}

		public function get uriSchemes():Vector.<String>
		{
			return URI_SCHEMES;
		}

		public function get fileExtensions():Vector.<String>
		{
			return FILE_EXTENSIONS;
		}

		public function get active():Boolean
		{
			return _languageClient && _languageClient.initialized;
		}

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:ActionScriptTextEditor = new ActionScriptTextEditor(readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				case URI_SCHEME_SWC:
				{
					var label:String = uri;
					var args:String = null;
					var argsIndex:int = uri.indexOf("?");
					if(argsIndex != -1)
					{
						label = uri.substr(0, argsIndex);
						args = uri.substr(argsIndex + 1);
					}
					var lastSlashIndex:int = label.lastIndexOf("/");
					if(lastSlashIndex != -1)
					{
						label = label.substr(lastSlashIndex + 1);
					}
					args = decodeURIComponent(args);

					var extension:String = "";
					var dotIndex:int = label.lastIndexOf(".");
					if(dotIndex != -1)
					{
						extension = label.substr(dotIndex + 1);
					}
					editor.defaultLabel = label;

					var editorEvent:EditorPluginEvent = new EditorPluginEvent(EditorPluginEvent.EVENT_EDITOR_OPEN);
					editorEvent.editor = editor.getEditorComponent();
					editorEvent.fileExtension = extension;
					GlobalEventDispatcher.getInstance().dispatchEvent(editorEvent);

					//editor.open() must be called after EditorPluginEvent.EVENT_EDITOR_OPEN
					//is dispatched or the syntax highlighting will not work
					editor.open(null, args);
					break;
				}
				default:
				{
					throw new URIError("Unknown URI scheme for ActionScript and MXML: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			cleanupLanguageClient();
			
			_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(SdkEvent.CHANGE_SDK, changeMenuSDKStateHandler);
			_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, javaPathSaveHandler);
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient = null;
		}

		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				trace("Error: AS3 & MXML language server process already exists!");
				return;
			}
			var jdkFolder:File = null;
			if(_model.javaPathForTypeAhead)
			{
				jdkFolder = _model.javaPathForTypeAhead.fileBridge.getFile as File;
			}
			var sdkPath:String = getProjectSDKPath(_project, _model);
			if(!jdkFolder || !sdkPath)
			{
				//we'll need to try again later if the settings change
				_previousJavaPath = null;
				_previousSDKPath = null;
				return;
			}
			_previousJavaPath = jdkFolder.nativePath;
			_previousSDKPath = sdkPath;

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			var cmdFile:File = jdkFolder.resolvePath(javaFileName);
			if(!cmdFile.exists)
			{
				cmdFile = jdkFolder.resolvePath("bin/" + javaFileName);
			}
			if(!cmdFile.exists)
			{
				error("Invalid path to Java Development Kit: " + cmdFile.nativePath);
                _dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
				return;
			}

			var frameworksPath:String = (new File(sdkPath)).resolvePath("frameworks").nativePath;

			var processArgs:Vector.<String> = new <String>[];
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var cp:String = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_BIN_PATH).nativePath + File.separator + "*";
			if (Settings.os == "win")
			{
				cp += ";"
			}
			else
			{
				cp += ":";
			}
			cp += File.applicationDirectory.resolvePath(BUNDLED_COMPILER_PATH).nativePath + File.separator + "*";
			processArgs.push("-Dfile.encoding=UTF8");
			processArgs.push("-Droyalelib=" + frameworksPath);
			processArgs.push("-cp");
			processArgs.push(cp);
			processArgs.push("moonshine.Main");
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
			processInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);

			_languageServerProcess = new NativeProcess();
			_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.start(processInfo);

			initializeLanguageServer(sdkPath);
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name, "Starting ActionScript & MXML code intelligence..."
			));
		}
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: AS3 & MXML language client already exists!");
				return;
			}

			trace("AS3 & MXML language server workspace root: " + project.folderPath);
			trace("AS3 & MXML language server SDK: " + sdkPath);

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT, _project, debugMode, {},
				_dispatcher, _languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _languageServerProcess.standardInput);
			_languageClient.registerScheme("swc");
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
		}

		private function restartLanguageServer():void
		{
			if(_waitingToRestart)
			{
				//we'll just continue waiting
				return;
			}
			_waitingToRestart = false;
			if(_languageClient)
			{
				_waitingToRestart = true;
				_languageClient.stop();
			}
			else if(_languageServerProcess)
			{
				_waitingToRestart = true;
				_languageServerProcess.exit();
			}

			if(!_waitingToRestart)
			{
				startNativeProcess();
			}
		}

		private function sendWorkspaceSettings():void
		{
			if(!_languageClient || !_languageClient.initialized)
			{
				return;
			}
			var frameworkSDK:String = getProjectSDKPath(_project, _model);
			var settings:Object = { as3mxml: { sdk: { framework: frameworkSDK } } };
			
			var params:Object = new Object();
			params.settings = settings;
			_languageClient.sendNotification(METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION, params);
		}

		private function sendProjectConfiguration():void
		{
			if(!_languageClient || !_languageClient.initialized)
			{
				return;
			}
			var type:String = "app";
			if(_project.isLibraryProject)
			{
				type = "lib";
			}
			var config:String = "flex";
			if(_project.air)
			{
				if(_project.isMobile)
				{
					config = "airmobile";
				}
				else
				{
					config = "air";
				}
			}
			else if (_project.isRoyale)
			{
				config = "royale";
			}

			//the config file may not exist, or it may be out of date, so
			//we're going to tell the project to update it immediately
			_project.updateConfig();
			var buildOptions:BuildOptions = _project.buildOptions;
			if(_project.config.file)
			{
				var projectPath:File = new File(project.folderLocation.fileBridge.nativePath);
				var configPath:File = new File(_project.config.file.fileBridge.nativePath);
				var buildArgs:String = "-load-config+=" +
					projectPath.getRelativePath(configPath, true) +
					" " +
					buildOptions.getArguments();
			}
			else
			{
				buildArgs = buildOptions.getArguments();
			}
				
			var files:Array = [];
			var filesCount:int = _project.targets.length;
			for(var i:int = 0; i < filesCount; i++)
			{
				var file:String = _project.targets[i].fileBridge.nativePath;
				files[i] = file;
			}

			//all of the compiler options are actually included in buildArgs,
			//but the language server needs to be able to read some of them more
			//easily, so we pass them in manually
			var compilerOptions:Object = {};
			var sourcePathCount:int = _project.classpaths.length;
			if(sourcePathCount > 0)
			{
				var sourcePaths:Array = [];
				for(i = 0; i < sourcePathCount; i++)
				{
					var sourcePath:String = _project.classpaths[i].fileBridge.nativePath;
					sourcePaths[i] = sourcePath;
				}
				compilerOptions["source-path"] = sourcePaths;
			}

			//this object is designed to be similar to the asconfig.json
			//format used by vscode-as3mxml
			//https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json
			//https://github.com/BowlerHatLLC/vscode-as3mxml/blob/master/distribution/src/assembly/schemas/asconfig.schema.json
			var params:Object = new Object();
			params.type = type;
			params.config = config;
			params.files = files;
			params.compilerOptions = compilerOptions;
			params.additionalOptions = buildArgs;
			_languageClient.sendNotification(METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION, params);
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			error(data);
			trace(data);
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.stop();
				
				warning("ActionScript & MXML language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				startNativeProcess();
			}
		}

		private function languageClient_initHandler(event:Event):void
		{
			sendProjectConfiguration();
			
			this.dispatchEvent(new Event(Event.INIT));
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
		}

		private function languageClient_closeHandler(event:Event):void
		{
			if(_waitingToRestart)
			{
				cleanupLanguageClient();
				//the native process will automatically exit, so we continue
				//waiting for that to complete
			}
			else
			{
				this.dispose();
			}
			this.dispatchEvent(new Event(Event.CLOSE));
		}

		private function projectChangeCustomSDKHandler(event:Event):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousSDKPath)
			{
				restartLanguageServer();
			}
		}

		private function changeMenuSDKStateHandler(event:Event):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousSDKPath)
			{
				restartLanguageServer();
			}
		}

		private function javaPathSaveHandler(event:FilePluginEvent):void
		{
			var javaPath:String = null;
			if(_model.javaPathForTypeAhead)
			{
				var javaFile:File = _model.javaPathForTypeAhead.fileBridge.getFile as File;
				javaPath = javaFile.nativePath;
			}
			//restart only when the path has changed
			if(javaPath != _previousJavaPath)
			{
				restartLanguageServer();
			}
		}
		
		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			if(event.project !== _project)
			{
				return;
			}
			sendProjectConfiguration();
		}
	}
}
