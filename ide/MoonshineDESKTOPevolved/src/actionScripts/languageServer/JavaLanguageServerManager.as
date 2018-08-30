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
    import mx.utils.SHA256;
    import flash.utils.ByteArray;
    import components.popup.StandardPopup;
    import spark.components.Button;
    import flash.events.MouseEvent;
    import mx.managers.PopUpManager;
    import mx.core.FlexGlobals;
    import flash.display.DisplayObject;
    import actionScripts.events.ExecuteLanguageServerCommandEvent;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.ui.editor.JavaTextEditor;
    import actionScripts.ui.editor.BasicTextEditor;

	[Event(name="close",type="flash.events.Event")]

	public class JavaLanguageServerManager extends EventDispatcher implements ILanguageServerManager
	{
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.5.100.v20180611-1436.jar";
		private static const LANGUAGE_SERVER_WINDOWS_CONFIG_PATH:String = "elements/jdt-language-server/config_win";
		private static const LANGUAGE_SERVER_MACOS_CONFIG_PATH:String = "elements/jdt-language-server/config_mac";
		private static const LANGUAGE_ID_JAVA:String = "java";
		private static const PATH_WORKSPACE_STORAGE:String = "java/workspaces";

		private static const METHOD_LANGUAGE__STATUS:String = "language/status";
		private static const METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION:String = "language/actionableNotification";

		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH_HELP:String = "java.ignoreIncompleteClasspath.help";
		private static const COMMAND_JAVA_IGNORE_INCOMPLETE_CLASSPATH:String = "java.ignoreIncompleteClasspath";
		
		private static const URI_SCHEMES:Vector.<String> = new <String>[];
		private static const FILE_EXTENSIONS:Vector.<String> = new <String>["java"];

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
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);

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

		public function createTextEditor(readOnly:Boolean = false):BasicTextEditor
		{
			return new JavaTextEditor(readOnly);
		}

		protected function dispose():void
		{
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeLanguageServerCommandHandler);
			if(_languageClient)
			{
				_languageClient.removeNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
				_languageClient.removeNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
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
				configFile = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_MACOS_CONFIG_PATH);
			}
			else
			{
				configFile = File.applicationDirectory.resolvePath(LANGUAGE_SERVER_WINDOWS_CONFIG_PATH);
			}
			processArgs.push(configFile.nativePath);
			processArgs.push("-data");
			//this is a file outside of the project folder due to limitations
			//of the language server, which is based on Eclipse
			processArgs.push(getWorkspaceNativePath());
			_shellInfo.arguments = processArgs;
			_shellInfo.executable = _cmdFile;
			_shellInfo.workingDirectory = new File(_project.folderLocation.fileBridge.nativePath);
			initShell();
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

			var debugMode:Boolean = false;
			_languageClient = new LanguageClient(LANGUAGE_ID_JAVA, _project, debugMode, initOptions,
				_dispatcher, _nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_languageClient.addEventListener(Event.INIT, languageClient_initHandler);
			_languageClient.addEventListener(Event.CLOSE, languageClient_closeHandler);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__STATUS, language__status);
			_languageClient.addNotificationListener(METHOD_LANGUAGE__ACTIONABLE_NOTIFICATION, language__actionableNotification);
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
			}
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
