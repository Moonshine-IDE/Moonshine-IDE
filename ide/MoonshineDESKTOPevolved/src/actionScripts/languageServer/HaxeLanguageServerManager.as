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
    import actionScripts.events.SaveFileEvent;
    import actionScripts.events.SdkEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugins.haxelib.events.HaxelibEvent;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.HaxeTextEditor;
    import actionScripts.utils.HtmlFormatter;
    import actionScripts.utils.UtilsCore;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;

    import no.doomsday.console.ConsoleUtil;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class HaxeLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_ROOT_PATH:String = "elements/haxe-language-server";
		private static const LANGUAGE_SERVER_SCRIPT_PATH:String = LANGUAGE_SERVER_ROOT_PATH + "/server.js";
		
		private static const LANGUAGE_ID_HAXE:String = "haxe";

		private static const METHOD_HAXE__PROGRESS_START:String = "haxe/progressStart";
		private static const METHOD_HAXE__PROGRESS_STOP:String = "haxe/progressStop";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["hx"];

		private var _project:HaxeProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _limeDisplayProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _previousHaxePath:String = null;
		private var _previousTargetPlatform:String = null;
		private var _displayArguments:String = null;

		public function HaxeLanguageServerManager(project:HaxeProjectVO)
		{
			_project = project;

			//when adding new listeners, don't forget to also remove them in
			//dispose()
			_dispatcher.addEventListener(SdkEvent.CHANGE_HAXE_SDK, changeHaxeSDKHandler);
			_dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.addEventListener(HaxelibEvent.HAXELIB_INSTALL_COMPLETE, haxelibInstallCompleteHandler);

			boostrapThenStartNativeProcess();
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

			var editor:HaxeTextEditor = new HaxeTextEditor(readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for Haxe: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			cleanupLanguageClient();
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageClient.removeNotificationListener(METHOD_HAXE__PROGRESS_START, haxe__progressStart);
			_languageClient.removeNotificationListener(METHOD_HAXE__PROGRESS_STOP, haxe__progressStop);
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient = null;
		}
		
		private function boostrapThenStartNativeProcess():void
		{
			if(_project.isLime)
			{
				installDependencies();
			}
			else
			{
				startNativeProcess(["build.hxml"]);
			}
		}

		private function installDependencies():void
		{
			_dispatcher.dispatchEvent(new HaxelibEvent(HaxelibEvent.HAXELIB_INSTALL, _project));
		}
		
		private function getProjectSettings():void
		{
			this._displayArguments = "";

			var sdkPath:String = getProjectSDKPath(_project, _model);
			if(!sdkPath)
			{
				return;
			}
			var haxelibFileName:String = (Settings.os == "win") ? "haxelib.exe" : "haxelib";
			var cmdFile:File = new File(sdkPath).resolvePath(haxelibFileName);
			if(!cmdFile.exists)
			{
				return;
			}
			var processArgs:Vector.<String> = new <String>[
				"run",
				"lime",
				"display",
				_project.targetPlatform
			];

			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
			processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
			
			_limeDisplayProcess = new NativeProcess();
			_limeDisplayProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeDisplayProcess_standardOutputDataHandler);
			_limeDisplayProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, limeDisplayProcess_standardErrorDataHandler);
			_limeDisplayProcess.addEventListener(NativeProcessExitEvent.EXIT, limeDisplayProcess_exitHandler);
			_limeDisplayProcess.start(processInfo);
		}

		private function startNativeProcess(displayArguments:Array):void
		{
			if(_languageServerProcess)
			{
				trace("Error: Haxe language server process already exists!");
				return;
			}
			var haxePath:String = getProjectSDKPath(_project, _model);
			_previousHaxePath = haxePath;
			_previousTargetPlatform = _project.targetPlatform;
			if(!_model.nodePath)
			{
				return;
			}

			var processArgs:Vector.<String> = new <String>[];
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var scriptFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_SCRIPT_PATH);
			//uncomment to allow devtools debugging of the Node.js script
			//processArgs.push("--inspect");
			processArgs.push(scriptFile.nativePath);
			processInfo.arguments = processArgs;
			processInfo.executable = new File(UtilsCore.getNodeBinPath());
			processInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);

			_languageServerProcess = new NativeProcess();
			_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.start(processInfo);

			initializeLanguageServer(haxePath, displayArguments);
		}
		
		private function initializeLanguageServer(sdkPath:String, displayArguments:Array):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Haxe language client already exists!");
				return;
			}

			trace("Haxe language server workspace root: " + project.folderPath);
			trace("Haxe language server SDK: " + sdkPath);

			var sendMethodResults:Boolean = false;
			var options:Object = 
			{
				displayServerConfig: {
					path: "c:\\HaxeToolkit\\haxe\\haxe.exe",
					arguments: [/*"-v"*/],
					env: {}
				},
				displayArguments: displayArguments,
				haxelibConfig: {},
				sendMethodResults: sendMethodResults
			};

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_HAXE, _project, debugMode, options,
				_dispatcher, _languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _languageServerProcess.standardInput);
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			if(sendMethodResults)
			{
				_languageClient.addNotificationListener("haxe/didRunHaxeMethod", function(message:Object):void
				{
					trace("}}} ", JSON.stringify(message));
				});
			}
			_languageClient.addNotificationListener(METHOD_HAXE__PROGRESS_START, haxe__progressStart);
			_languageClient.addNotificationListener(METHOD_HAXE__PROGRESS_STOP, haxe__progressStop);
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
				boostrapThenStartNativeProcess();
			}
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleUtil.print("shellError " + data + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), "weak");
			trace(data);
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.stop();
				
				ConsoleOutputter.formatOutput(
					"Haxe language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.",
					"warning");
			}
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				boostrapThenStartNativeProcess();
			}
		}
		
		private function limeDisplayProcess_standardOutputDataHandler(event:ProgressEvent):void 
		{
			if(_limeDisplayProcess)
			{
				var output:IDataInput = _limeDisplayProcess.standardOutput;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				this._displayArguments += data;
			}
		}
		
		private function limeDisplayProcess_standardErrorDataHandler(event:ProgressEvent):void 
		{
			var output:IDataInput = _limeDisplayProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleOutputter.formatOutput(data, "error");
			trace(data);
		}
		
		private function limeDisplayProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_limeDisplayProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeDisplayProcess_standardOutputDataHandler);
			_limeDisplayProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, limeDisplayProcess_standardOutputDataHandler);
			_limeDisplayProcess.removeEventListener(NativeProcessExitEvent.EXIT, limeDisplayProcess_exitHandler);
			_limeDisplayProcess.exit();
			_limeDisplayProcess = null;

			if(event.exitCode == 0)
			{
				startNativeProcess(this._displayArguments.split("\n"));
			}
			else
			{
				ConsoleOutputter.formatOutput(
					"Failed to load Lime project settings. Haxe code intelligence disabled.",
					"error");
			}
		}

		private function fileSavedHandler(event:SaveFileEvent):void
		{
			var savedFile:FileLocation = event.file;
			if(savedFile.name != "project.xml")
			{
				return;
			}

			var savedFileFolder:FileLocation = savedFile.fileBridge.parent;
			if(savedFileFolder.fileBridge.nativePath != _project.folderLocation.fileBridge.nativePath)
			{
				return;
			}

			restartLanguageServer();
		}

		private function changeHaxeSDKHandler(event:SdkEvent):void
		{
			if(getProjectSDKPath(_project, _model) != _previousHaxePath)
			{
				restartLanguageServer();
			}
		}

		private function haxelibInstallCompleteHandler(event:HaxelibEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			if(_languageServerProcess)
			{
				//if this happened while the language server was running, then
				//start from scratch
				restartLanguageServer();
			}
			else
			{
				//if no language server is running, we can continue with the
				//next step of the process
				getProjectSettings();
			}
		}

		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			var needsRestart:Boolean = false;

			if(!needsRestart && getProjectSDKPath(_project, _model) != _previousHaxePath)
			{
				needsRestart = true;
			}

			if(!needsRestart && _project.targetPlatform != _previousTargetPlatform)
			{
				needsRestart = true;
			}

			if(needsRestart)
			{
				restartLanguageServer();
			}
		}

		private function languageClient_initHandler(event:Event):void
		{
			this.dispatchEvent(new Event(Event.INIT));
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
				dispose();
			}
			
			this.dispatchEvent(new Event(Event.CLOSE));
		}

		private function haxe__progressStart(message:Object):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				"Haxe", message.params.message, false
			));
		}

		private function haxe__progressStop(message:Object):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS
			));
		}
	}
}
