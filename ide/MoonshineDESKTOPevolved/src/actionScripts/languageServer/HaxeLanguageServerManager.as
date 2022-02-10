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

	import mx.controls.Alert;

	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.events.SdkEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugins.haxelib.events.HaxelibEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.HaxeTextEditor;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.utils.getProjectSDKPath;
	import actionScripts.utils.isUriInProject;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;

	import com.adobe.utils.StringUtil;

	import moonshine.lsp.LanguageClient;
	import moonshine.lsp.LogMessageParams;
	import moonshine.lsp.PublishDiagnosticsParams;
	import moonshine.lsp.Registration;
	import moonshine.lsp.RegistrationParams;
	import moonshine.lsp.ShowMessageParams;
	import moonshine.lsp.Unregistration;
	import moonshine.lsp.UnregistrationParams;
	import moonshine.lsp.WorkspaceEdit;
	import moonshine.lsp.events.LspNotificationEvent;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class HaxeLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_ROOT_PATH:String = "elements/haxe-language-server";
		private static const LANGUAGE_SERVER_SCRIPT_PATH:String = LANGUAGE_SERVER_ROOT_PATH + "/server.js";
		
		private static const LANGUAGE_ID_HAXE:String = "haxe";

		private static const METHOD_HAXE__PROGRESS_START:String = "haxe/progressStart";
		private static const METHOD_HAXE__PROGRESS_STOP:String = "haxe/progressStop";
		private static const METHOD_HAXE__CACHE_BUILD_FAILED:String = "haxe/cacheBuildFailed";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["hx"];

		private var _project:HaxeProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _limeDisplayProcess:NativeProcess;
		private var _haxeVersionProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _waitingToDispose:Boolean = false;
		private var _waitingForHaxelibInstall:Boolean = false;
		private var _previousHaxePath:String = null;
		private var _previousNodePath:String = null;
		private var _previousTargetPlatform:String = null;
		private var _displayArguments:String = null;
		private var _haxeVersion:String = null;
		private var _languageServerProgressStarted:Boolean = false;
		private var _activeProgressTokens:Array = [];
		private var _watchedFiles:Object = {};

		public function HaxeLanguageServerManager(project:HaxeProjectVO)
		{
			_project = project;

			_dispatcher.addEventListener(SdkEvent.CHANGE_HAXE_SDK, changeHaxeSDKHandler, false, 0, true);
			_dispatcher.addEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler, false, 0, true);
			_dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler, false, 0, true);
			_dispatcher.addEventListener(HaxelibEvent.HAXELIB_INSTALL_COMPLETE, haxelibInstallCompleteHandler, false, 0, true);
			_dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			bootstrapThenStartNativeProcess();
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

			var editor:HaxeTextEditor = new HaxeTextEditor(_project, readOnly);
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
			_dispatcher.removeEventListener(SdkEvent.CHANGE_HAXE_SDK, changeHaxeSDKHandler);
			_dispatcher.removeEventListener(SdkEvent.CHANGE_NODE_SDK, changeNodeSDKHandler);
			_dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(HaxelibEvent.HAXELIB_INSTALL_COMPLETE, haxelibInstallCompleteHandler);
			_dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);

			cleanupLanguageClient();

			if(_haxeVersionProcess)
			{
				_waitingToDispose = true;
				_haxeVersionProcess.exit(true);
			}
			if(_limeDisplayProcess)
			{
				_waitingToDispose = true;
				_limeDisplayProcess.exit(true);
			}
			else if(_waitingForHaxelibInstall)
			{
				_waitingToDispose = true;
			}
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			if(_languageServerProgressStarted)
			{
				//if we had a progress message, clean it up
				_dispatcher.dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					project.name
				));
			}
			_languageServerProgressStarted = false;
			_languageClient.removeNotificationListener(METHOD_HAXE__PROGRESS_START, haxe__progressStart);
			_languageClient.removeNotificationListener(METHOD_HAXE__PROGRESS_STOP, haxe__progressStop);
			_languageClient.addNotificationListener(METHOD_HAXE__CACHE_BUILD_FAILED, haxe__cacheBuildFailed);
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.removeEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.removeEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			_languageClient = null;
		}

		private function isHaxeVersionSupported(version:String):Boolean
		{
			var parts:Array = version.split("-");
			var versionNumber:String = parts[0];
			var versionNumberParts:Array = versionNumber.split(".");
			if(versionNumberParts.length != 3)
			{
				return false;
			}
			var major:Number = parseInt(versionNumberParts[0], 10);
			var minor:Number = parseInt(versionNumberParts[1], 10);
			var revision:Number = parseInt(versionNumberParts[2], 10);
			if(isNaN(major) || isNaN(minor) || isNaN(revision))
			{
				return false;
			}
			if(major < 4)
			{
				return false;
			}
			if(major == 4 && minor == 0 && revision == 0 && parts.length > 1
				&& (parts[1].indexOf("-rc.") == 0 || parts[1].indexOf("-preview.")))
			{
				return false;
			}
			return true;
		}
		
		private function bootstrapThenStartNativeProcess():void
		{
			if(!UtilsCore.isHaxeAvailable())
			{
				_previousHaxePath = null;
				warning("Haxe language code intelligence disabled. To enable, update Haxe location in application settings.");
				return;
			}
			if(!UtilsCore.isNekoAvailable())
			{
				warning("Haxe language code intelligence disabled. To enable, update Neko location in application settings.");
				return;
			}
			if(!UtilsCore.isNodeAvailable())
			{
				_previousNodePath = null;
				warning("Haxe language code intelligence disabled. To enable, update Node.js location in application settings.");
				return;
			}
			_waitingForHaxelibInstall = false;
			installDependencies();
		}

		private function installDependencies():void
		{
			_waitingForHaxelibInstall = true;
			_dispatcher.dispatchEvent(new HaxelibEvent(HaxelibEvent.HAXELIB_INSTALL, _project));
		}
		
		private function checkHaxeVersion():void
		{
			if(!UtilsCore.isHaxeAvailable() || !UtilsCore.isNekoAvailable())
			{
				_previousHaxePath = null;
				return;
			}

			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name, "Checking Haxe version...", false
			));

			this._haxeVersion = "";
			var haxeVersionCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.HAXE_ENVIRON_EXEC_PATH,
				"--version"
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
				
				_haxeVersionProcess = new NativeProcess();
				_haxeVersionProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, haxeVersionProcess_standardOutputDataHandler);
				_haxeVersionProcess.addEventListener(NativeProcessExitEvent.EXIT, haxeVersionProcess_exitHandler);
				_haxeVersionProcess.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(haxeVersionCommand)]);
		}
		
		private function getProjectSettings():void
		{
			if(!_project.isLime)
			{
				startNativeProcess(_project.getHXML().split("\n"));
				return;
			}

			if(!UtilsCore.isHaxeAvailable() || !UtilsCore.isNekoAvailable())
			{
				return;
			}

			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name, "Loading Haxe project...", false
			));

			this._displayArguments = "";
			var limeDisplayCommand:Vector.<String> = new <String>[
				EnvironmentExecPaths.HAXELIB_ENVIRON_EXEC_PATH,
				"run",
				"lime",
				"display",
				_project.limeTargetPlatform,
				"-Ddisable-version-check"
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
				
				_limeDisplayProcess = new NativeProcess();
				_limeDisplayProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeDisplayProcess_standardOutputDataHandler);
				_limeDisplayProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, limeDisplayProcess_standardErrorDataHandler);
				_limeDisplayProcess.addEventListener(NativeProcessExitEvent.EXIT, limeDisplayProcess_exitHandler);
				_limeDisplayProcess.start(processInfo);
			}, null, [CommandLineUtil.joinOptions(limeDisplayCommand)]);
		}

		private function startNativeProcess(displayArguments:Array):void
		{
			if(_languageServerProcess)
			{
				trace("Error: Haxe language server process already exists!");
				return;
			}
			if(!UtilsCore.isHaxeAvailable() || !UtilsCore.isNekoAvailable() || !UtilsCore.isNodeAvailable())
			{
				return;
			}

			var haxePath:String = getProjectSDKPath(_project, _model);
			_previousHaxePath = haxePath;
			var nodePath:String = UtilsCore.getNodeBinPath();
			_previousNodePath = nodePath;
			if(_project.isLime)
			{
				_previousTargetPlatform = _project.limeTargetPlatform;
			}
			else
			{
				_previousTargetPlatform = _project.haxeOutput.platform;
			}

			var scriptFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_SCRIPT_PATH);
			var languageServerCommand:Vector.<String> = new <String>[
				nodePath,
				// uncomment --inspect to allow devtools debugging of the Node.js script
				// "--inspect",
				scriptFile.nativePath
			];
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function(value:String):void
			{
				var cmdFile:File = null;
				var processArgs:Vector.<String> = new <String>[];
				
				if (Settings.os == "win")
				{
					cmdFile = new File("c:\\Windows\\System32\\cmd.exe");
					processArgs.push("/c");
					processArgs.push(value);
				}
				else
				{
					cmdFile = new File("/bin/bash");
					processArgs.push("-c");
					processArgs.push(value);
				}

				var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processInfo.arguments = processArgs;
				processInfo.executable = cmdFile;
				processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;
				
				_languageServerProcess = new NativeProcess();
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
				_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
				_languageServerProcess.start(processInfo);
				initializeLanguageServer(haxePath, displayArguments);
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
		}
		
		private function initializeLanguageServer(sdkPath:String, displayArguments:Array):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Haxe language client already exists!");
				return;
			}
			var haxeFileName:String = (Settings.os == "win") ? "haxe.exe" : "haxe";
			var haxelibFileName:String = (Settings.os == "win") ? "haxelib.exe" : "haxelib";

			trace("Haxe language server workspace root: " + project.folderPath);
			trace("Haxe language server SDK: " + sdkPath);

			var sendMethodResults:Boolean = false;
			var initOptions:Object = 
			{
				displayArguments: displayArguments,
				displayServerConfig: {
					path: new File(sdkPath).resolvePath(haxeFileName).nativePath,
					arguments: [/*"-v"*/],
					env: {},
					print: {completion: false, reusing: false},
					useSocket: false
				},
				haxelibConfig: {
					executable: new File(sdkPath).resolvePath(haxelibFileName).nativePath
				},
				sendMethodResults: sendMethodResults
			};

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_HAXE,
				_languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA,
				_languageServerProcess.standardInput);
			_languageClient.debugMode = debugMode;
			_languageClient.addWorkspaceFolder({
				name: project.name,
				uri: project.folderLocation.fileBridge.url
			});
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.addEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.addEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.addEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.addEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.addEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			if(sendMethodResults)
			{
				_languageClient.addNotificationListener("haxe/didRunHaxeMethod", function(message:Object):void
				{
					trace("}}} ", JSON.stringify(message));
				});
			}
			_languageServerProgressStarted = false;
			_languageClient.addNotificationListener(METHOD_HAXE__PROGRESS_START, haxe__progressStart);
			_languageClient.addNotificationListener(METHOD_HAXE__PROGRESS_STOP, haxe__progressStop);
			_languageClient.addNotificationListener(METHOD_HAXE__CACHE_BUILD_FAILED, haxe__cacheBuildFailed);
			_languageClient.addNotificationListener("$/progress", dollar__progress);
			_languageClient.addNotificationListener("window/workDoneProgress/create", window__workDoneProgress__create);
			_project.languageClient = _languageClient;

			var initParams:Object = LanguageClientUtil.getSharedInitializeParams();
			initParams.initializationOptions = initOptions;
			_languageClient.initialize(initParams);
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
				_languageClient.shutdown();
			}
			else if(_languageServerProcess)
			{
				_waitingToRestart = true;
				_languageServerProcess.exit();
			}
			else if(_haxeVersionProcess)
			{
				_waitingToRestart = true;
				_haxeVersionProcess.exit();
			}
			else if(_limeDisplayProcess)
			{
				_waitingToRestart = true;
				_limeDisplayProcess.exit();
			}
			else if(_waitingForHaxelibInstall)
			{
				_waitingToRestart = true;
			}

			if(!_waitingToRestart)
			{
				bootstrapThenStartNativeProcess();
			}
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			trace(data);
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.shutdown();
				
				warning("Haxe language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
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
			trace(data);
		}
		
		private function limeDisplayProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));

			_limeDisplayProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, limeDisplayProcess_standardOutputDataHandler);
			_limeDisplayProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, limeDisplayProcess_standardErrorDataHandler);
			_limeDisplayProcess.removeEventListener(NativeProcessExitEvent.EXIT, limeDisplayProcess_exitHandler);
			_limeDisplayProcess.exit();
			_limeDisplayProcess = null;

			if(_waitingToDispose)
			{
				//don't continue if we've disposed during the bootstrap process
				return;
			}
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
			}

			if(event.exitCode == 0)
			{
				startNativeProcess(this._displayArguments.split("\n"));
			}
			else
			{
				error("Failed to load Lime project settings. Haxe code intelligence disabled for project: " + project.name + ".");
			}
		}
		
		private function haxeVersionProcess_standardOutputDataHandler(event:ProgressEvent):void 
		{
			if(_haxeVersionProcess)
			{
				var output:IDataInput = _haxeVersionProcess.standardOutput;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				this._haxeVersion += data;
			}
		}
		
		private function haxeVersionProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));

			_haxeVersionProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, haxeVersionProcess_standardOutputDataHandler);
			_haxeVersionProcess.removeEventListener(NativeProcessExitEvent.EXIT, haxeVersionProcess_exitHandler);
			_haxeVersionProcess.exit();
			_haxeVersionProcess = null;

			if(_waitingToDispose)
			{
				//don't continue if we've disposed during the bootstrap process
				return;
			}
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				bootstrapThenStartNativeProcess();
				return;
			}

			if(event.exitCode == 0)
			{
				this._haxeVersion = StringUtil.trim(this._haxeVersion);
				trace("Haxe version: " + this._haxeVersion);
				if(!isHaxeVersionSupported(this._haxeVersion))
				{
					error("Haxe version 4.0.0 or newer is required. Version not supported: " + this._haxeVersion + ". Haxe code intelligence disabled for project: " + project.name + ".");
					return;
				}
				getProjectSettings();
			}
			else
			{
				error("Failed to load Haxe version. Haxe code intelligence disabled for project: " + project.name + ".");
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

		private function changeNodeSDKHandler(event:SdkEvent):void
		{
			if(UtilsCore.getNodeBinPath() != _previousNodePath)
			{
				restartLanguageServer();
			}
		}

		private function tabSelectHandler(event:TabEvent):void
		{
			var textEditor:BasicTextEditor = event.child as BasicTextEditor;
			if(!textEditor)
			{
				return;
			}
			if(!_languageClient || !_languageClient.initialized)
			{
				return;
			}
			_languageClient.sendNotification("haxe/didChangeActiveTextEditor", {uri: textEditor.currentFile.fileBridge.url});
		}

		private function haxelibInstallCompleteHandler(event:HaxelibEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			_waitingForHaxelibInstall = false;
			if(_waitingToDispose)
			{
				//don't continue if we've disposed during the bootstrap process
				return;
			}
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				restartLanguageServer();
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
				checkHaxeVersion();
			}
		}

		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			var needsRestart:Boolean = false;

			if(!needsRestart && getProjectSDKPath(_project, _model) != _previousHaxePath)
			{
				needsRestart = true;
			}

			if(!needsRestart && _project.isLime && _project.limeTargetPlatform != _previousTargetPlatform)
			{
				needsRestart = true;
			}

			if(!needsRestart && !_project.isLime)
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

		private function languageClient_publishDiagnosticsHandler(event:LspNotificationEvent):void
		{
			var params:PublishDiagnosticsParams = PublishDiagnosticsParams(event.params);
			var uri:String = params.uri;
			var diagnostics:Array = params.diagnostics;
			_dispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, uri, project, diagnostics));
		}

		private function languageClient_registerCapabilityHandler(event:LspNotificationEvent):void
		{
			var params:RegistrationParams = RegistrationParams(event.params);
			var registrations:Array = params.registrations;
			for each(var registration:Registration in registrations)
			{
				var method:String = registration.method;
				switch(method)
				{
					case LanguageClient.METHOD_WORKSPACE__DID_CHANGE_WATCHED_FILES:
						var registerOptions:Object = registration.registerOptions;
						_watchedFiles[registration.id] = registerOptions.watchers.map(function(watcher:Object, index:int, source:Array):Object {
							return GlobPatterns.toRegExp(watcher.globPattern);
						});
						break;
				}
				_dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_REGISTER_CAPABILITY, _project, method));
			}
		}

		private function languageClient_unregisterCapabilityHandler(event:LspNotificationEvent):void
		{
			var params:UnregistrationParams = UnregistrationParams(event.params);
			var unregistrations:Array = params.unregistrations;
			for each(var unregistration:Unregistration in unregistrations)
			{
				var method:String = unregistration.method;
				switch(method)
				{
					case LanguageClient.METHOD_WORKSPACE__DID_CHANGE_WATCHED_FILES:
						delete _watchedFiles[unregistration.id];
						break;
				}
				_dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.LANGUAGE_SERVER_UNREGISTER_CAPABILITY, _project, method));
			}
		}

		private function languageClient_logMessageHandler(event:LspNotificationEvent):void
		{
			var params:LogMessageParams = LogMessageParams(event.params);
			var message:String = params.message;
			var type:int = params.type;
			var eventType:String = null;
			switch(type)
			{
				case 1: //error
				{
					eventType = ConsoleOutputEvent.TYPE_ERROR;
					break;
				}
				default:
				{
					eventType = ConsoleOutputEvent.TYPE_INFO;
				}
			}
			_dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, eventType)
			);
			trace(message);
		}

		private function languageClient_showMessageHandler(event:LspNotificationEvent):void
		{
			var params:ShowMessageParams = ShowMessageParams(event.params);
			var message:String = params.message;
			var type:int = params.type;
			var eventType:String = null;
			switch(type)
			{
				case 1: //error
				{
					eventType = ConsoleOutputEvent.TYPE_ERROR;
					break;
				}
				default:
				{
					eventType = ConsoleOutputEvent.TYPE_INFO;
				}
			}
			
			Alert.show(message);
		}

		private function languageClient_applyEditHandler(event:LspNotificationEvent):void
		{
			var params:Object = event.params;
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit(params.edit);
			applyWorkspaceEdit(workspaceEdit)
		}

		private function haxe__cacheBuildFailed(message:Object):void
		{
			error("Unable to build cache - completion features may be slower than expected. Try fixing the error(s) and restarting the language server.");
		}

		private function haxe__progressStart(message:Object):void
		{
			_languageServerProgressStarted = true;
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name, message.params.title, false
			));
		}

		private function haxe__progressStop(message:Object):void
		{
			_languageServerProgressStarted = false;
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
		}

		private function window__workDoneProgress__create(message:Object):void
		{
			var token:Object = message.params.token;
			this._activeProgressTokens.push(token);
		}

		private function dollar__progress(message:Object):void
		{
			var token:Object = message.params.token;
			var value:Object = message.params.value;
			var tokenIndex:int = this._activeProgressTokens.indexOf(token);
			if(tokenIndex == -1)
			{
				return;
			}

			switch(value.kind)
			{
				case "end":
				{
					this._activeProgressTokens.splice(tokenIndex, 1);
					_dispatcher.dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name
					));
					break;
				}
				case "begin":
				{
					_dispatcher.dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						project.name, value.title, false
					));
					break;
				}
				default:
					trace("Unknown progress message: " + JSON.stringify(message));
				
			}
		}

		private function executeLanguageServerCommandHandler(event:ExecuteLanguageServerCommandEvent):void
		{
			if(event.project != _project)
			{
				//it's for a different project
				return;
			}
			if(event.isDefaultPrevented())
			{
				//it's already handled somewhere else
				return;
			}
			if(!_languageClient)
			{
				//not ready yet
				return;
			}

			_languageClient.executeCommand({
				command: event.command,
				arguments: event.arguments
			}, function(result:Object):void {
				event.result = result;
			});
		}

		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project != _project || !_languageClient)
			{
				return;
			}
			_languageClient.shutdown();
		}

		private function applicationExitHandler(event:ApplicationEvent):void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageClient.shutdown();
		}

		private function isWatchingFile(file:FileLocation):Boolean
		{
			var relativePath:String = project.folderLocation.fileBridge.getRelativePath(file);
			var matchesPattern:Boolean = false;
			for(var id:String in _watchedFiles)
			{
				var watchers:Array = _watchedFiles[id];
				for each(var pattern:RegExp in watchers)
				{
					if(pattern.test(relativePath)) {
						return true;
					}
				}
			}
			return false;
		}

		private function fileCreatedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 1
					}
				]
			});
		}

		private function fileDeletedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 3
					}
				]
			});
		}

		private function fileModifiedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			_languageClient.didChangeWatchedFiles({
				changes: [
					{
						uri: event.file.fileBridge.url,
						type: 2
					}
				]
			});
		}
	}
}
