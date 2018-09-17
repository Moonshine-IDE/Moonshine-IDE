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
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.utils.HtmlFormatter;
    import actionScripts.utils.findOpenPort;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.valueObjects.Settings;
    
    import no.doomsday.console.ConsoleUtil;
    import actionScripts.valueObjects.ProjectVO;
    import flash.events.EventDispatcher;
    import actionScripts.ui.editor.ActionScriptTextEditor;
    import actionScripts.ui.editor.LanguageServerTextEditor;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.events.EditorPluginEvent;

	[Event(name="close",type="flash.events.Event")]

	public class ActionScriptLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/codecompletion.jar";
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
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;

		public function ActionScriptLanguageServerManager(project:AS3ProjectVO)
		{
			_javaPath = IDEModel.getInstance().javaPathForTypeAhead.fileBridge.getFile as File;

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			_cmdFile = _javaPath.resolvePath(javaFileName);
			if(!_cmdFile.exists)
			{
				_cmdFile = _javaPath.resolvePath("bin/" + javaFileName);
			}

			_project = project;

			_project.addEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.addEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
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
			if(_languageClient)
			{
				_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
				_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
				_languageClient = null;
			}
			
			_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
		}

		private function startNativeProcess():void
		{
			var sdkPath:String = getProjectSDKPath(_project, _model);
			if(!sdkPath)
			{
				//we can't start the process yet because we don't have an SDK
				//for this project
				return;
			}

			var frameworksPath:String = (new File(sdkPath)).resolvePath("frameworks").nativePath;

			var processArgs:Vector.<String> = new <String>[];
			_shellInfo = new NativeProcessStartupInfo();
			var jarFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_JAR_PATH);
			processArgs.push("-Dfile.encoding=UTF8");
			processArgs.push("-Droyalelib=" + frameworksPath);
			processArgs.push("-jar");
			processArgs.push(jarFile.nativePath);
			_shellInfo.arguments = processArgs;
			_shellInfo.executable = _cmdFile;
			_shellInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);
			initShell();
		}

		private function initShell():void
		{
			if (_nativeProcess)
			{
				_nativeProcess.exit();
			}
			else
			{
				startShell();
			}
		}

		private function startShell():void
		{
			_nativeProcess = new NativeProcess();
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			_nativeProcess.start(_shellInfo);

			initializeLanguageServer();
		}
		
		private function initializeLanguageServer():void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				return;
			}
			var sdkPath:String = getProjectSDKPath(_project, _model);
			if(!sdkPath)
			{
				//we'll need to try again later if the SDK changes
				return;
			}

			trace("Language server workspace root: " + project.folderPath);
			trace("Language Server framework SDK: " + sdkPath);

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT, _project, debugMode, {},
				_dispatcher, _nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_languageClient.registerScheme("swc");
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
		}

		private function sendWorkspaceSettings():void
		{
			if(!_languageClient || !_languageClient.initialized)
			{
				return;
			}
			var frameworkSDK:String = getProjectSDKPath(_project, _model);
			var settings:Object = { nextgenas: { sdk: { framework: frameworkSDK } } };
			
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
			var buildOptions:BuildOptions = _project.buildOptions;
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
			if(_project.config.file)
			{
				var projectPath:File = new File(project.folderLocation.fileBridge.nativePath);
				var configPath:File = new File(_project.config.file.fileBridge.nativePath);
				var buildArgs:String = "-load-config+=" +
					projectPath.getRelativePath(configPath, true)
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
			//format used by vscode-nextgenas
			//https://github.com/BowlerHatLLC/vscode-nextgenas/wiki/asconfig.json
			//https://github.com/BowlerHatLLC/vscode-nextgenas/blob/master/distribution/src/assembly/schemas/asconfig.schema.json
			var params:Object = new Object();
			params.type = type;
			params.config = config;
			params.files = files;
			params.compilerOptions = compilerOptions;
			params.additionalOptions = buildArgs;
			_languageClient.sendNotification(METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION, params);
		}

		private function shellError(e:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleUtil.print("shellError " + data + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
			trace(data);
		}

		private function shellExit(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				_languageClient.stop();
			}
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			_nativeProcess.exit();
			_nativeProcess = null;
		}

		private function languageClient_initHandler(event:Event):void
		{
			sendProjectConfiguration();
		}

		private function languageClient_closeHandler(event:Event):void
		{
			this.dispose();

			this.dispatchEvent(new Event(Event.CLOSE));
		}

		private function projectChangeCustomSDKHandler(event:Event):void
		{
			trace("Change custom SDK Path:", _project.customSDKPath);
			trace("Language Server framework SDK: " + getProjectSDKPath(_project, _model));
			if(_languageClient && _languageClient.initialized)
			{
				//we've already initialized the server
				sendWorkspaceSettings();
			}
			else if(!_nativeProcess)
			{
				//we haven't started the native process yet
				//it's possible that we couldn't find any SDK at all
				startNativeProcess();
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

		private function changeMenuSDKStateHandler(event:Event):void
		{
			var defaultSDKPath:String = "None";
			var defaultSDK:FileLocation = _model.defaultSDK;
			if(defaultSDK)
			{
				defaultSDKPath = _model.defaultSDK.fileBridge.nativePath;
			}
			trace("change global SDK:", defaultSDKPath);
			trace("Language Server framework SDK: " + getProjectSDKPath(_project, _model));
			if(_languageClient && _languageClient.initialized)
			{
				//we've already initialized the server
				sendWorkspaceSettings();
			}
			else if(!_nativeProcess)
			{
				//we haven't started the native process yet
				//it's possible that we couldn't find any SDK at all
				startNativeProcess();
			}
		}
	}
}
