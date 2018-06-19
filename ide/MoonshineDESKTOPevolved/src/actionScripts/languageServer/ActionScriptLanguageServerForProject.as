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

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;

    import no.doomsday.console.ConsoleUtil;

	public class ActionScriptLanguageServerForProject
	{
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/codecompletion.jar";
		private static const LANGUAGE_ID_ACTIONSCRIPT:String = "nextgenas";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";
		private static const METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION:String = "moonshine/didChangeProjectConfiguration";

		private var _project:AS3ProjectVO;
		private var _port:int;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;

		public function ActionScriptLanguageServerForProject(project:AS3ProjectVO, javaPath:String)
		{
			_javaPath = new File(javaPath);

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			_cmdFile = _javaPath.resolvePath(javaFileName);
			if(!_cmdFile.exists)
			{
				_cmdFile = _javaPath.resolvePath("bin/" + javaFileName);
			}

			_project = project;
			_project.addEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.addEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
			//when adding new listeners, don't forget to also remove them in
			//removeProjectHandler()

			startNativeProcess();
		}

		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
		}

		public function get project():AS3ProjectVO
		{
			return _project;
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

			_languageClient = new LanguageClient(LANGUAGE_ID_ACTIONSCRIPT, _project, _dispatcher,
				_nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
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

			if(_project.config.file)
			{
				//the config file may not exist, or it may be out of date, so
				//we're going to tell the project to update it immediately
				_project.updateConfig();
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
				shutdownHandler(null);
			}
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			_nativeProcess.exit();
			_nativeProcess = null;
		}

		public function shutdownHandler(event:Event):void{
			if(!_languageClient)
			{
				return;
			}
			_languageClient.stop();
		}

		private function languageClient_initHandler(event:Event):void
		{
			sendProjectConfiguration();
		}

		private function languageClient_closeHandler(event:Event):void
		{
			_languageClient = null;
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
