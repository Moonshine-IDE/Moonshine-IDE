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
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;
    
    import mx.core.FlexGlobals;
    import mx.managers.PopUpManager;
    import mx.utils.SHA256;
    
    import spark.components.Button;
    
    import actionScripts.events.ExecuteLanguageServerCommandEvent;
    import actionScripts.events.FilePluginEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.JavaTextEditor;
    import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.utils.GradleBuildUtil;
    import actionScripts.utils.HtmlFormatter;
    import actionScripts.utils.applyWorkspaceEdit;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;
    import actionScripts.valueObjects.WorkspaceEdit;
    
    import components.popup.StandardPopup;
    
    import no.doomsday.console.ConsoleUtil;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class JavaLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		//when updating the JDT language server, the name of this JAR file will
		//change, and Moonshine will automatically update the version that is
		//copied to File.applicationStorageDirectory
		private static const LANGUAGE_SERVER_JAR_PATH:String = "plugins/org.eclipse.equinox.launcher_1.5.200.v20180922-1751.jar";
		private static const LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = "config_win";
		private static const LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = "config_mac";
		private static const PATH_WORKSPACE_STORAGE:String = "java/workspaces";
		private static const PATH_JDT_LANGUAGE_SERVER_APP:String = "elements/jdt-language-server";
		private static const PATH_JDT_LANGUAGE_SERVER_STORAGE:String = "java/jdt-language-server";
		
		private static const LANGUAGE_ID_JAVA:String = "java";

		private static const METHOD_LANGUAGE__STATUS:String = "language/status";
		private static const METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = "language/actionableNotification";

		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:String = "java.ignoreIncompleteClasspath.help";
		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:String = "java.ignoreIncompleteClasspath";
		private static const COMMAND_JAVA_APPLY_WORKSPACE_EDIT:String = "java.apply.workspaceEdit";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["java"];

		private var _project:JavaProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _gradleProcess:NativeProcess;
		private var _languageStatusDone:Boolean = false;
		private var _waitingToRestart:Boolean = false;
		private var _previousJDKPath:String = null;

		public function JavaLanguageServerManager(project:JavaProjectVO)
		{
			_project = project;

			//when adding new listeners, don't forget to also remove them in
			//dispose()
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			_dispatcher.addEventListener(GradleBuildEvent.REFRESH_GRADLE_CLASSPATH, onGradleClassPathRefresh, false, 0, true);

			prepareApplicationStorage();
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

		public function createTextEditorForUri(uri:String, readOnly:Boolean = false):BasicTextEditor
		{
			var colonIndex:int = uri.indexOf(":");
			if(colonIndex == -1)
			{
				throw new URIError("Invalid URI: " + uri);
			}
			var scheme:String = uri.substr(0, colonIndex);

			var editor:JavaTextEditor = new JavaTextEditor(readOnly);
			if(scheme == URI_SCHEME_FILE)
			{
				//the regular OpenFileEvent should be used to open this one
				return editor;
			}
			switch(scheme)
			{
				default:
				{
					throw new URIError("Unknown URI scheme for Java: " + scheme);
				}
			}
			return editor;
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			cleanupLanguageClient();
		}

		protected function cleanupLanguageClient():void
		{
			if(!_languageClient)
			{
				return;
			}
			_languageStatusDone = false;
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.removeNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
			_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient = null;
		}
		
		private function preTaskLanguageServer():void
		{
			if (!requireUpdateGradleClasspath()) 
			{
				startNativeProcess();
			}
		}

		private function prepareApplicationStorage():void
		{
			var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
			var jarFile:File = storageFolder.resolvePath(LANGUAGE_SERVER_JAR_PATH);
			if(jarFile.exists)
			{
				//we've already copied the files to application storage, so
				//we're good to go!
				return;
			}
			var appFolder:File = File.applicationDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_APP);
			//this directory may already exist, if an older version of Moonshine
			//with an older version of the JDT language server was installed
			//we don't want conflicts between JDT language server versions, so
			//delete the entire directory and start fresh
			var showStorageError:Boolean = false;
			try
			{
				if(storageFolder.exists)
				{
					storageFolder.deleteDirectory(true);
				}
				appFolder.copyTo(storageFolder);
			}
			catch(error:Error)
			{
				showStorageError = true;
			}
			if(showStorageError || !storageFolder.exists || !jarFile.exists)
			{
				//something went wrong!
				var message:String = "Error initializing Java language server. Please delete the following folder, if it exists, and restart Moonshine: " + storageFolder.nativePath;
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, ConsoleOutputEvent.TYPE_ERROR)
				);
			}
		}
		
		private function onGradleClassPathRefresh(event:Event):void
		{
			if (_model.activeProject == _project)
			{
				restartLanguageServer();
			}
		}
		
		private function requireUpdateGradleClasspath():Boolean
		{
			// in case of Gradle project we need to
			// update its eclipse plugin
			if (IDEModel.getInstance().gradlePath && _project.hasGradleBuild())
			{
				if(_languageServerProcess)
				{
					trace("Error: Java language server process already exists!");
					return true;
				}
				
				var compilerArg:String = EnvironmentSetupUtils.GRADLE_ENVIRON_EXEC_PATH +" eclipse";
				EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(onEnvironmentPrepared, null, [compilerArg]);
				GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
					StatusBarEvent.LANGUAGE_SERVER_STATUS,
					null, "Updating Gradle classpath", false
				));
				return true;
			}
			
			return false;
			
			/*
			* @local
			*/
			function onEnvironmentPrepared(value:String):void
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
			}
		}

		private function startNativeProcess():void
		{
			if(_languageServerProcess)
			{
				trace("Error: Java language server process already exists!");
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

			var storageFolder:File = File.applicationStorageDirectory.resolvePath(PATH_JDT_LANGUAGE_SERVER_STORAGE);
			var processArgs:Vector.<String> = new <String>[];
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var jarFile:File = storageFolder.resolvePath(LANGUAGE_SERVER_JAR_PATH);
			processArgs.push("-Declipse.application=org.eclipse.jdt.ls.core.id1");
			processArgs.push("-Dosgi.bundles.defaultStartLevel=4");
			processArgs.push("-Declipse.product=org.eclipse.jdt.ls.core.product");
			processArgs.push("-noverify");
			processArgs.push("-Xmx1G");
			processArgs.push("-XX:+UseG1GC");
			processArgs.push("-XX:+UseStringDeduplication");
			processArgs.push("-jar");
			processArgs.push(jarFile.nativePath);
			processArgs.push("-configuration");
			var configFile:File = null;
			if(ConstantsCoreVO.IS_MACOS)
			{
				configFile = storageFolder.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
			}
			else
			{
				configFile = storageFolder.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
			}
			processArgs.push(configFile.nativePath);
			processArgs.push("-data");
			//this is a file outside of the project folder due to limitations
			//of the language server, which is based on Eclipse
			processArgs.push(getWorkspaceNativePath());
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
			processInfo.workingDirectory = _project.folderLocation.fileBridge.getFile as File;

			_languageServerProcess = new NativeProcess();
			_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.start(processInfo);

			initializeLanguageServer(jdkPath);
		}

		private function getWorkspaceNativePath():String
		{
			//we need to store the language server's data files somewhere, but
			//it CANNOT be inside the project directory. let's put them in the
			//app storage directory instead.
			var projectPath:String = _project.folderLocation.fileBridge.nativePath;
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(projectPath);
			//we need to differentiate between different projects that have
			//the same name, so let's use a hash of the full path
			var digest:String = SHA256.computeDigest(bytes);
			bytes.clear();
			var workspaceLocation:File = File.applicationStorageDirectory.resolvePath(PATH_WORKSPACE_STORAGE).resolvePath(digest);
			return workspaceLocation.nativePath;
		}
		
		private function initializeLanguageServer(sdkPath:String):void
		{
			if(_languageClient)
			{
				//we're already initializing or initialized...
				trace("Error: Java language client already exists!");
				return;
			}

			trace("Java language server workspace root: " + project.folderPath);
			trace("Java language Server JDK: " + sdkPath);

			var initOptions:Object = 
			{
				bundles: [],
				workspaceFolders: [_project.projectFolder.file.fileBridge.url],
				settings: { /*java: getJavaConfiguration()*/ },
				extendedClientCapabilities:
				{
					progressReportProvider: false,//getJavaConfiguration().get('progressReports.enabled'),
					classFileContentsSupport: false
				}
			};

			_languageStatusDone = false;
			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_JAVA, _project, debugMode, initOptions,
				_dispatcher, _languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _languageServerProcess.standardInput);
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
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
				preTaskLanguageServer();
			}
		}

		private function createCommandListener(command:String, args:Array, popup:StandardPopup):Function
		{
			return function(event:Event):void
			{
				_dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
					ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
					command, args ? args : []));
				if(popup)
				{
					PopUpManager.removePopUp(popup);
					popup.data = null;
				}
			};
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleUtil.print("shellError " + data + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
		}

		private function languageServerProcess_exitHandler(e:NativeProcessExitEvent):void
		{
			if(_languageClient)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have
				_languageClient.stop();
				
				ConsoleOutputter.formatOutput(
					"Java language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.",
					"warning");
			}
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
			if(!_gradleProcess)
			{
				return;
			}
			var output:IDataInput = _gradleProcess.standardOutput;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
		}
		
		private function gradleProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			if(!_gradleProcess)
			{
				return;
			}
			var output:IDataInput = _gradleProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			if (data.match(/'eclipse' not found in root project/))
			{
				data = _project.name +": Unable to regenerate classpath for Gradle project. Please check that you have included the 'eclipse' plugin, and verify that your dependencies are correct."; 
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(
					ConsoleOutputEvent.CONSOLE_OUTPUT, 
					data, 
					false, false, 
					ConsoleOutputEvent.TYPE_ERROR));
			}
			else
			{
				data = "shellError while updating Gradle classpath" + data + ".";
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(
					ConsoleOutputEvent.CONSOLE_OUTPUT, 
					HtmlFormatter.sprintfa(data, null), false, false, 
					ConsoleOutputEvent.TYPE_ERROR));
			}
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS
			));
		}
		
		private function gradleProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_gradleProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, gradleProcess_standardErrorDataHandler);
			_gradleProcess.removeEventListener(NativeProcessExitEvent.EXIT, gradleProcess_exitHandler);
			_gradleProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, gradleProcess_standardOutputDataHandler);
			_gradleProcess.exit();
			_gradleProcess = null;
			
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

		private function executeLanguageServerCommandHandler(event:ExecuteLanguageServerCommandEvent):void
		{
			if(event.isDefaultPrevented())
			{
				//already handled somewhere else
				return;
			}
			switch(event.command)
			{
				case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:
				{
					event.preventDefault();
					trace("TODO: update the java.errors.incompleteClasspath.severity setting");
					break;
				}
				case COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:
				{
					event.preventDefault();
					navigateToURL(new URLRequest("https://github.com/redhat-developer/vscode-java/wiki/%22Classpath-is-incomplete%22-warning"), "_blank");
					break;
				}
				case COMMAND_JAVA_APPLY_WORKSPACE_EDIT:
				{
					event.preventDefault();
					var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(event.arguments[0]);
					applyWorkspaceEdit(workspaceEdit);
					break;
				}
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

		private function language__status(message:Object):void
		{
			if(_languageStatusDone)
			{
				return;
			}
			switch(message.params.type)
			{
				case "Starting":
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						"Java", message.params.message, false
					));
					break;
				}
				case "Message":
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS,
						"Java", message.params.message, false
					));
				}
				case "Started":
				{
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS
					));
					break;
				}
				case "Error":
				{
					_languageStatusDone = true;
					GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
						StatusBarEvent.LANGUAGE_SERVER_STATUS
					));
					break;
				}
				default:
				{
					trace("Unknown " + METHOD_LANGUAGE__STATUS + " message type:", message.params.type);
					break;
				}
			}
		}

		private function language__actionableNotification(notification:Object):void
		{
			var params:Object = notification.params;
			var severity:int = notification.severity as int;
			var message:String = params.message;
			var commands:Array = params.commands as Array;

			if(severity == 4) //log
			{
				_dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, ConsoleOutputEvent.TYPE_INFO)
				);
				trace(message);
				return;
			}

			var popup:StandardPopup = new StandardPopup();
			popup.data = this; // Keep the command from getting GC'd
			popup.text = message;

			var buttons:Array = [];
			var commandCount:int = commands.length;
			for(var i:int = 0; i < commandCount; i++)
			{
				var command:Object = commands[i];
				var title:String = command.title as String;
				var commandName:String = command.command;
				var args:Array = command.arguments as Array;

				var button:Button = new Button();
				button.styleName = "lightButton";
				button.label = title;
				button.addEventListener(MouseEvent.CLICK, createCommandListener(commandName, args, popup), false, 0, false);
				buttons.push(button);
			}
			
			popup.buttons = buttons;
			
			PopUpManager.addPopUp(popup, FlexGlobals.topLevelApplication as DisplayObject, true);
			popup.y = (ConstantsCoreVO.IS_MACOS) ? 25 : 45;
			popup.x = (FlexGlobals.topLevelApplication.width-popup.width)/2;
		}
	}
}
