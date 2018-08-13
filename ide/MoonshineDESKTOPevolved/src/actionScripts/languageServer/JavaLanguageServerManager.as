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
    import actionScripts.languageServer.LanguageClient;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.console.ConsoleOutputter;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.utils.HtmlFormatter;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.utils.IDataInput;

    import no.doomsday.console.ConsoleUtil;
    import flash.events.EventDispatcher;

	[Event(name="close",type="flash.events.Event")]

	public class JavaLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.5.100.v20180611-1436.jar";
		private static const LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = "elements/jdt-language-server/config_win";
		private static const LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = "elements/jdt-language-server/config_mac";
		private static const LANGUAGE_ID_JAVA:String = "java";

		private static const METHOD_LANGUAGE__STATUS:String = "language/status";
		private static const METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = "language/actionableNotification";

		private var _project:JavaProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;

		public function JavaLanguageServerManager(project:JavaProjectVO)
		{
			_javaPath = IDEModel.getInstance().javaPathForTypeAhead.fileBridge.getFile as File;

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			_cmdFile = _javaPath.resolvePath(javaFileName);
			if(!_cmdFile.exists)
			{
				_cmdFile = _javaPath.resolvePath("bin/" + javaFileName);
			}

			_project = project;

			//when adding new listeners, don't forget to also remove them in
			//dispose()

			startNativeProcess();
		}

		public function get project():ProjectVO
		{
			return _project;
		}

		protected function dispose():void
		{
			if(_languageClient)
			{
				_languageClient.removeEventListener(METHOD_LANGUAGE__STATUS, language__status);
				_languageClient.removeEventListener(Event.INIT, languageClient_initHandler);
				_languageClient.removeEventListener(Event.CLOSE, languageClient_closeHandler);
				_languageClient = null;
			}
		}

		private function startNativeProcess():void
		{
			var processArgs:Vector.<String> = new <String>[];
			_shellInfo = new NativeProcessStartupInfo();
			var jarFile:File = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_JAR_PATH);
			processArgs.push("-Declipse.application=org.eclipse.jdt.ls.core.id1");
			processArgs.push("-Dosgi.bundles.defaultStartLevel=4");
			processArgs.push("-Declipse.product=org.eclipse.jdt.ls.core.product"); 
			processArgs.push("-jar");
			processArgs.push(jarFile.nativePath);
			processArgs.push("-configuration");
			var configFile:File = null;
			if(ConstantsCoreVO.IS_MACOS)
			{
				configFile = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
			}
			else
			{
				configFile = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
			}
			processArgs.push(configFile.nativePath);
			processArgs.push("-data");
			processArgs.push(_project.folderLocation.fileBridge.nativePath);
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

			trace("Language server workspace root: " + project.folderPath);

			_languageClient = new LanguageClient(LANGUAGE_ID_JAVA, _project, _dispatcher,
				_nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			//_languageClient.debugMode = true;
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
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
		}

		private function languageClient_closeHandler(event:Event):void
		{
			this.dispose();
			
			this.dispatchEvent(new Event(Event.CLOSE));
		}

		private function language__status(message:Object):void
		{
			trace(message.params.type + ":", message.params.message);
		}
	}
}
