////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.haxe
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
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.LanguageClientUtil;
	import actionScripts.languageServer.LanguageServerGlobals;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugins.haxelib.events.HaxelibEvent;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.UtilsCore;
	import actionScripts.utils.applyWorkspaceEdit;
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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class HaxeLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_ROOT_PATH:String = "elements/haxe-language-server";
		private static const LANGUAGE_SERVER_SCRIPT_PATH:String = LANGUAGE_SERVER_ROOT_PATH + "/moonshine-haxe.js";
		
		private static const LANGUAGE_ID_HAXE:String = "haxe";

		private static const METHOD_HAXE__PROGRESS_START:String = "haxe/progressStart";
		private static const METHOD_HAXE__PROGRESS_STOP:String = "haxe/progressStop";
		private static const METHOD_HAXE__CACHE_BUILD_FAILED:String = "haxe/cacheBuildFailed";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["hx"];

		private static const LANGUAGE_SERVER_SHUTDOWN_TIMEOUT:Number = 8000;

		private static const LANGUAGE_SERVER_PROCESS_FORMATTED_PID:RegExp = new RegExp( /(%%%[0-9]+%%%)/ );

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
		private var _shutdownTimeoutID:uint = uint.MAX_VALUE;
		private var _pid:int = -1;
		private var _watchedFilesDebounceTimeoutID:uint = uint.MAX_VALUE;
		private var _watchedFilesPendingChanges:Array = [];

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

		public function get pid():int
		{
			return _pid;
		}

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:LanguageServerTextEditor = new LanguageServerTextEditor(LANGUAGE_ID_HAXE, _project, readOnly);
			editor.editor.allowToggleBreakpoints = true;
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
				// the process for the language server wasn't cleaned up
				// properly before trying to start a new one...
				trace("Error: Haxe language server process already exists for project: " + project.name);
				return;
			}
			if(!UtilsCore.isHaxeAvailable() || !UtilsCore.isNekoAvailable() || !UtilsCore.isNodeAvailable())
			{
				return;
			}

			var haxePath:String = _model.haxePath;
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
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
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
				// the language server is already initializing or initialized...
				trace("Error: Haxe language client already exists for project: " + project.name);
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
			if(_languageClient || _languageServerProcess)
			{
				_waitingToRestart = true;
				shutdown();
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

		private function shutdown():void
		{
			if(!_languageClient || !_languageClient.initialized)
			{
				if (_languageClient)
				{
					cleanupLanguageClient();
				}
				if (_languageServerProcess)
				{
					_languageServerProcess.exit(true);
				}
				return;
			}
			_shutdownTimeoutID = setTimeout(shutdownTimeout, LANGUAGE_SERVER_SHUTDOWN_TIMEOUT);
			_languageClient.shutdown();
		}

		private function shutdownTimeout():void
		{
			_shutdownTimeoutID = uint.MAX_VALUE;
			if (!_languageServerProcess) {
				return;
			}
			var message:String = "Timed out while shutting down Haxe language server for project " + _project.name + ". Forcing process to exit.";
			warning(message);
			trace(message);
			_languageClient = null;
			_languageServerProcess.exit(true);
		}

		private function languageServerProcess_standardOutputDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			if ( data.search(LANGUAGE_SERVER_PROCESS_FORMATTED_PID) > -1 ) {
				// Formatted PID found
				var a:Array = data.match(LANGUAGE_SERVER_PROCESS_FORMATTED_PID);
				var spid:String = a[ 0 ].split("%%%")[ 1 ];
				_pid = parseInt(spid);
				if ( _pid > 0 ) {
					// PID is set, we don't need the stdout handler anymore
					_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
					LanguageServerGlobals.getInstance().addLanguageServerManager(this);
				}
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
			if (_shutdownTimeoutID != uint.MAX_VALUE) {
				clearTimeout(_shutdownTimeoutID);
				_shutdownTimeoutID = uint.MAX_VALUE;
			}
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.shutdown();
				
				warning("Haxe language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			// if the language server didn't start correctly,
			// clear the active status bar animation
			_dispatcher.dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
			LanguageServerGlobals.getInstance().removeLanguageServerManager(this);
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
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
			if(_model.haxePath != _previousHaxePath)
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
			if(!textEditor || !textEditor.currentFile)
			{
				return;
			}
			if(!_languageClient || !_languageClient.initialized || _languageClient.stopping || _languageClient.stopped)
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

			if(!needsRestart && _model.haxePath != _previousHaxePath)
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
			if(event.project != _project)
			{
				return;
			}
			shutdown();
		}

		private function applicationExitHandler(event:ApplicationEvent):void
		{
			shutdown();
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

		private function handleWatchedFilesPendingChanges():void
		{
			_watchedFilesDebounceTimeoutID = uint.MAX_VALUE;
			if (_watchedFilesPendingChanges.length == 0)
			{
				return;
			}
			if (!_languageClient || !_languageClient.initialized || _languageClient.stopping || _languageClient.stopped)
			{
				return;
			}
			_languageClient.didChangeWatchedFiles(
			{
				changes: _watchedFilesPendingChanges
			});
			_watchedFilesPendingChanges = [];
		}

		private function queueWatchedFileChange(change:Object):void
		{
			_watchedFilesPendingChanges.push(change);
			if (_watchedFilesDebounceTimeoutID != uint.MAX_VALUE)
			{
				clearTimeout(_watchedFilesDebounceTimeoutID);
				_watchedFilesDebounceTimeoutID = uint.MAX_VALUE;
			}
			_watchedFilesDebounceTimeoutID = setTimeout(handleWatchedFilesPendingChanges, 500);
		}

		private function fileCreatedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 1
			});
		}

		private function fileDeletedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 3
			});
		}

		private function fileModifiedHandler(event:WatchedFileChangeEvent):void
		{
			if(!_languageClient || !isUriInProject(event.file.fileBridge.url, project) || !isWatchingFile(event.file))
			{
				return;
			}
			queueWatchedFileChange(
			{
				uri: event.file.fileBridge.url,
				type: 2
			});
		}
	}
}
