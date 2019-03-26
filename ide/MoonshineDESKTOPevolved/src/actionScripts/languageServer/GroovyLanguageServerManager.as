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
    import actionScripts.plugin.groovy.groovyproject.vo.GroovyProjectVO;
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

	[Event(name="close",type="flash.events.Event")]

	public class GroovyLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		//when updating the Groovy language server, the name of this JAR file
		//will change
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/groovy-language-server/groovy-language-server-all.jar";
		
		private static const LANGUAGE_ID_GROOVY:String = "groovy";
		
		private static const URI_SCHEME_FILE:String = "file";

		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["groovy"];

		private var _project:GroovyProjectVO;
		private var _languageClient:LanguageClient;
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;
		private var _languageStatusDone:Boolean = false;

		public function GroovyLanguageServerManager(project:GroovyProjectVO)
		{
			_javaPath = IDEModel.getInstance().javaPathForTypeAhead.fileBridge.getFile as File;

			var javaFileName:String = (Settings.os == "win") ? "java.exe" : "java";
			_cmdFile = _javaPath.resolvePath(javaFileName);
			if(!_cmdFile.exists)
			{
				_cmdFile = _javaPath.resolvePath("bin/" + javaFileName);
			}

			_project = project;

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
			if(_languageClient)
			{
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
			processArgs.push("-cp");
			processArgs.push(jarFile.nativePath);
			processArgs.push("net.prominic.groovyls.GroovyLanguageServer");
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

			_languageStatusDone = false;
			var debugMode:Boolean = true;//false;
			_languageClient = new LanguageClient(LANGUAGE_ID_GROOVY, _project, debugMode, {},
				_dispatcher, _nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
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
	}
}
