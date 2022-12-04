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
package actionScripts.plugins.groovylsp
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.GradleBuildEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WatchedFileChangeEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.languageServer.ILanguageServerManager;
	import actionScripts.languageServer.LanguageClientUtil;
	import actionScripts.languageServer.LanguageServerGlobals;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.utils.CommandLineUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.GlobPatterns;
	import actionScripts.utils.GradleBuildUtil;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.utils.getProjectSDKPath;
	import actionScripts.utils.isUriInProject;
	import actionScripts.valueObjects.EnvironmentExecPaths;
	import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Settings;
	
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

	public class GroovyLanguageServerManager extends ConsoleOutputter implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_CLASS_PATH:String = "elements/groovy-language-server";
		
		private static const LANGUAGE_ID_GROOVY:String = "groovy";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["groovy", "java"];

		private var _project:GrailsProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _gradleProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _previousJDKPath:String = null;
		private var _watchedFiles:Object = {};
		private var _shutdownTimeoutID:uint = uint.MAX_VALUE;
		private var _pid:int = -1;
		private var _watchedFilesDebounceTimeoutID:uint = uint.MAX_VALUE;
		private var _watchedFilesPendingChanges:Array = [];

		private static const LANGUAGE_SERVER_SHUTDOWN_TIMEOUT:Number = 8000;

		private static const LANGUAGE_SERVER_PROCESS_FORMATTED_PID:RegExp = new RegExp( /(%%%[0-9]+%%%)/ );

		public function GroovyLanguageServerManager(project:GrailsProjectVO)
		{
			_project = project;

			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler, false, 0, true);
			_dispatcher.addEventListener(GradleBuildEvent.REFRESH_GRADLE_CLASSPATH, onGradleClassPathRefresh, false, 0, true);
			_dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler, false, 0, true);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler, false, 0, true);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler, false, 0, true);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.addEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			//when adding new listeners, don't forget to also remove them in
			//dispose()

			LanguageServerGlobals.addLanguageServerManager( this );
			LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.REMOVED ) );

			preTaskLanguageServer();
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

			var editor:LanguageServerTextEditor = new LanguageServerTextEditor(LANGUAGE_ID_GROOVY, _project, readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for Groovy: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
			_dispatcher.removeEventListener(GradleBuildEvent.REFRESH_GRADLE_CLASSPATH, onGradleClassPathRefresh);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_CREATED, fileCreatedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_DELETED, fileDeletedHandler);
			_dispatcher.removeEventListener(WatchedFileChangeEvent.FILE_MODIFIED, fileModifiedHandler);
			cleanupLanguageClient();
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.removeEventListener(LspNotificationEvent.PUBLISH_DIAGNOSTICS, languageClient_publishDiagnosticsHandler);
			_languageClient.removeEventListener(LspNotificationEvent.REGISTER_CAPABILITY, languageClient_registerCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.UNREGISTER_CAPABILITY, languageClient_unregisterCapabilityHandler);
			_languageClient.removeEventListener(LspNotificationEvent.LOG_MESSAGE, languageClient_logMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.SHOW_MESSAGE, languageClient_showMessageHandler);
			_languageClient.removeEventListener(LspNotificationEvent.APPLY_EDIT, languageClient_applyEditHandler);
			_languageClient = null;
			
			LanguageServerGlobals.removeLanguageServerManager( this );
			LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.REMOVED ) );

		}
		
		private function onGradleClassPathRefresh(event:Event):void
		{
			if (_model.activeProject == _project)
			{
				restartLanguageServer();
			}
		}

		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				trace("Error: Groovy language server process already exists!");
				return;
			}
			var jdkPath:String = getProjectSDKPath(_project, _model);
			_previousJDKPath = jdkPath;
			if(!jdkPath)
			{
				return;
			}

			var jdkFolder:File = new File(jdkPath);

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

			var classPath:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_CLASS_PATH);

			var cp:String = classPath.nativePath + File.separator + "*";
			if (Settings.os == "win")
			{
				cp += ";"
			}
			else
			{
				cp += ":";
			}
			
			var languageServerCommand:Vector.<String> = new <String>[
				cmdFile.nativePath,
				"-cp",
				cp,
				"moonshine.groovyls.Main"
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
				_languageServerProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
				_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
				_languageServerProcess.start(processInfo);

				initializeLanguageServer(jdkPath);
			}, null, [CommandLineUtil.joinOptions(languageServerCommand)]);
		}
		
		private function preTaskLanguageServer():void
		{
			if (!requireUpdateGradleClasspath()) 
			{
				startNativeProcess();
			}
		}
		
		private function requireUpdateGradleClasspath():Boolean
		{
			// in case of Gradle project we need to
			// update its eclipse plugin
			if (IDEModel.getInstance().gradlePath)
			{
				if (!ConsoleBuildPluginBase.checkRequireJava(project))
				{
					clearOutput();
					error("Error: Updating Gradle classpath for "+ project.name +" with JDK version is not present.");
					return false;
				}

				if(_languageServerProcess)
				{
					trace("Error: Groovy language server process already exists!");
					return true;
				}
				
				var envCustomJava:EnvironmentUtilsCusomSDKsVO;
				if (project is IJavaProject)
				{
					envCustomJava = new EnvironmentUtilsCusomSDKsVO();
					envCustomJava.jdkPath = ((project as IJavaProject).jdkType == JavaTypes.JAVA_8) ?
							IDEModel.getInstance().java8Path.fileBridge.nativePath : IDEModel.getInstance().javaPathForTypeAhead.fileBridge.nativePath;
				}

				var eclipseCommand:Vector.<String> = new <String>[
					EnvironmentExecPaths.GRADLE_ENVIRON_EXEC_PATH,
					"eclipse"
				];
				EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(function onEnvironmentPrepared(value:String):void
				{
					var cmdFile:File;
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
					
					_gradleProcess = new NativeProcess();
					_gradleProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, gradleProcess_standardOutputDataHandler);
					_gradleProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, gradleProcess_standardErrorDataHandler);
					_gradleProcess.addEventListener(NativeProcessExitEvent.EXIT, gradleProcess_exitHandler);
					_gradleProcess.start(processInfo);
				}, envCustomJava, [CommandLineUtil.joinOptions(eclipseCommand)]);
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					project.name, "Updating Gradle classpath...", false
				));
				return true;
			}
			
			return false;
		}
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Groovy language client already exists!");
				return;
			}

			trace("Groovy language server workspace root: " + project.folderPath);
			trace("Groovy language Server JDK: " + sdkPath);

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_GROOVY,
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
			_project.languageClient = _languageClient;

			var initParams:Object = LanguageClientUtil.getSharedInitializeParams();
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

			if(!_waitingToRestart)
			{
				preTaskLanguageServer();
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
			var message:String = "Timed out while shutting down Groovy language server for project " + _project.name + ". Forcing process to exit.";
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
					LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.ADDED ) );
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
				
				warning("Groovy language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.");
			}
			LanguageServerGlobals.getEventDispatcher().dispatchEvent( new Event( Event.REMOVED ) );
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, languageServerProcess_standardOutputDataHandler);
			_languageServerProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.removeEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.exit();
			_languageServerProcess = null;
			if(_waitingToRestart)
			{
				_waitingToRestart = false;
				preTaskLanguageServer();
			}
		}
		
		private function gradleProcess_standardOutputDataHandler(e:ProgressEvent):void 
		{
			if(_gradleProcess)
			{
				var output:IDataInput = _gradleProcess.standardOutput;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				print(data);
			}
		}
		
		private function gradleProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _gradleProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			if (data.match(/'eclipse' not found in root project/))
			{
				error(_project.name + ": Unable to regenerate classpath for Gradle project. Please check that you have included the 'eclipse' plugin, and verify that your dependencies are correct."); 
			}
			else
			{
				error("shellError while updating Gradle classpath: " + data);
			}
		}
		
		private function gradleProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_gradleProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, gradleProcess_standardOutputDataHandler);
			_gradleProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, gradleProcess_standardErrorDataHandler);
			_gradleProcess.addEventListener(NativeProcessExitEvent.EXIT, gradleProcess_exitHandler);
			_gradleProcess.exit();
			_gradleProcess = null;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS,
				project.name
			));
			
			if (event.exitCode == 0)
			{
				GradleBuildUtil.IS_GRADLE_STARTED = true;
				startNativeProcess();
			}
		}

		private function jdkPathSaveHandler(event:FilePluginEvent):void
		{
			//restart only when the path has changed
			if(getProjectSDKPath(_project, _model) != _previousJDKPath)
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
