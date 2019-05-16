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
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.GroovyTextEditor;
    import actionScripts.utils.HtmlFormatter;
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
    import actionScripts.events.FilePluginEvent;
    import actionScripts.utils.getProjectSDKPath;
    import actionScripts.utils.GradleBuildUtil;
	import actionScripts.utils.EnvironmentSetupUtils;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.utils.UtilsCore;

	[Event(name="init",type="flash.events.Event")]
	[Event(name="close",type="flash.events.Event")]

	public class GroovyLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_CLASS_PATH:String = "elements/groovy-language-server";
		
		private static const LANGUAGE_ID_GROOVY:String = "groovy";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["groovy"];

		private var _project:GrailsProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _languageServerProcess:NativeProcess;
		private var _gradleProcess:NativeProcess;
		private var _waitingToRestart:Boolean = false;
		private var _previousJDKPath:String = null;

		public function GroovyLanguageServerManager(project:GrailsProjectVO)
		{
			_project = project;

			//when adding new listeners, don't forget to also remove them in
			//dispose()
			_dispatcher.addEventListener(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, jdkPathSaveHandler);

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

			var editor:GroovyTextEditor = new GroovyTextEditor(readOnly);
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
			_languageClient = null;
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

			var processArgs:Vector.<String> = new <String>[];
			var processInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var jarFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_CLASS_PATH);
			processArgs.push("-cp");
			processArgs.push(jarFile.nativePath + "/*");
			processArgs.push("moonshine.groovyls.Main");
			processInfo.arguments = processArgs;
			processInfo.executable = cmdFile;
			processInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);

			_languageServerProcess = new NativeProcess();
			_languageServerProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, languageServerProcess_standardErrorDataHandler);
			_languageServerProcess.addEventListener(NativeProcessExitEvent.EXIT, languageServerProcess_exitHandler);
			_languageServerProcess.start(processInfo);

			initializeLanguageServer(jdkPath);
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
				if(_languageServerProcess)
				{
					trace("Error: Groovy language server process already exists!");
					return true;
				}
				
				var compilerArg:String = UtilsCore.getGradleBinPath() + " eclipse";
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
			_languageClient = new LanguageClient(LANGUAGE_ID_GROOVY, _project, debugMode, {},
				_dispatcher, _languageServerProcess.standardOutput, _languageServerProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _languageServerProcess.standardInput);
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
				preTaskLanguageServer();
			}
		}

		private function languageServerProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
			var output:IDataInput = _languageServerProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleUtil.print("shellError " + data + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
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
					"Groovy language server exited unexpectedly. Close the " + project.name + " project and re-open it to enable code intelligence.",
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
			if(_gradleProcess)
			{
				var output:IDataInput = _gradleProcess.standardOutput;
				var data:String = output.readUTFBytes(output.bytesAvailable);
				ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
			}
		}
		
		private function gradleProcess_standardErrorDataHandler(e:ProgressEvent):void
		{
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
		}
		
		private function gradleProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_gradleProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, gradleProcess_standardOutputDataHandler);
			_gradleProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, gradleProcess_standardErrorDataHandler);
			_gradleProcess.addEventListener(NativeProcessExitEvent.EXIT, gradleProcess_exitHandler);
			_gradleProcess.exit();
			_gradleProcess = null;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new StatusBarEvent(
				StatusBarEvent.LANGUAGE_SERVER_STATUS
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
	}
}
