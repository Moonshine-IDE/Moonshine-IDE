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
package actionScripts.utils
{
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.CompletionItemsEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.events.HoverEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.ReferencesEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.SignatureHelpEvent;
	import actionScripts.events.SymbolsEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.ActionScriptTextEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.CompletionItem;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Location;
	import actionScripts.valueObjects.ParameterInformation;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.Settings;
	import actionScripts.valueObjects.SignatureHelp;
	import actionScripts.valueObjects.SignatureInformation;
	import actionScripts.valueObjects.SymbolInformation;
	import actionScripts.valueObjects.TextEdit;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.XMLSocket;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;

	import mx.collections.ArrayCollection;

	import no.doomsday.console.ConsoleUtil;
	import flash.errors.IllegalOperationError;

	/**
	 * An implementation of the language server protocol for Moonshine IDE.
	 * 
	 * NOT currently implemented to spec -JT
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification Language Server Protocol Specification
	 */
	public class LanguageServerForProject
	{
		private static const SOCKET_ADDRESS:String = "127.0.0.1";
		private static const LANGUAGE_SERVER_JAR_PATH:String = "elements/codecompletion.jar";
		private static const LANGUAGE_ID_ACTIONSCRIPT:String = "nextgenas";
		private static const FIELD_METHOD:String = "method";
		private static const FIELD_RESULT:String = "result";
		private static const FIELD_ERROR:String = "error";
		private static const FIELD_ID:String = "id";
		private static const FIELD_COMMAND:String = "command";
		private static const FIELD_CHANGES:String = "changes";
		private static const FIELD_CONTENTS:String = "contents";
		private static const FIELD_SIGNATURES:String = "signatures";
		private static const FIELD_ITEMS:String = "items";
		private static const JSON_RPC_VERSION:String = "2.0";
		private static const METHOD_INITIALIZE:String = "initialize";
		private static const METHOD_INITIALIZED:String = "initialized";
		private static const METHOD_SHUTDOWN:String = "shutdown";
		private static const METHOD_EXIT:String = "exit";
		private static const METHOD_CANCEL_REQUEST:String = "$/cancelRequest";
		private static const METHOD_TEXT_DOCUMENT__DID_CHANGE:String = "textDocument/didChange";
		private static const METHOD_TEXT_DOCUMENT__DID_OPEN:String = "textDocument/didOpen";
		private static const METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:String = "textDocument/publishDiagnostics";
		private static const METHOD_TEXT_DOCUMENT__COMPLETION:String = "textDocument/completion";
		private static const METHOD_TEXT_DOCUMENT__SIGNATURE_HELP:String = "textDocument/signatureHelp";
		private static const METHOD_TEXT_DOCUMENT__HOVER:String = "textDocument/hover";
		private static const METHOD_TEXT_DOCUMENT__DEFINITION:String = "textDocument/definition";
		private static const METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL:String = "textDocument/documentSymbol";
		private static const METHOD_TEXT_DOCUMENT__REFERENCES:String = "textDocument/references";
		private static const METHOD_TEXT_DOCUMENT__RENAME:String = "textDocument/rename";
		private static const METHOD_WORKSPACE__APPLY_EDIT:String = "workspace/applyEdit";
		private static const METHOD_WORKSPACE__SYMBOL:String = "workspace/symbol";
		private static const METHOD_WORKSPACE__EXECUTE_COMMAND:String = "workspace/executeCommand";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";
		private static const METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION:String = "moonshine/didChangeProjectConfiguration";

		private var _project:AS3ProjectVO;
		private var _requestID:int = 0;
		private var _port:int;
		private var _gotoDefinitionLookup:Dictionary = new Dictionary();
		private var _findReferencesLookup:Dictionary = new Dictionary();
		private var _model:IDEModel = IDEModel.getInstance();
		private var _dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _xmlSocket:XMLSocket;
		private var _shellInfo:NativeProcessStartupInfo;
		private var _nativeProcess:NativeProcess;
		private var _cmdFile:File;
		private var _javaPath:File;
		private var _connected:Boolean = false;
		private var _connecting:Boolean = false;
		private var _initialized:Boolean = false;
		private var _initializeID:int = -1;
		private var _shutdownID:int = -1;
		private var _previousActiveFilePath:String = null;
		private var _previousActiveResult:Boolean = false;

		public function LanguageServerForProject(project:AS3ProjectVO, javaPath:String)
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
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_DIDOPEN, didOpenCall);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_DIDCHANGE, didChangeCall);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_TYPEAHEAD, completionHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_HOVER, hoverHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_GOTO_DEFINITION, gotoDefinitionHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_dispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
			_dispatcher.addEventListener(TypeAheadEvent.EVENT_RENAME, renameHandler);
			_dispatcher.addEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
			_dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, shutdownHandler);
			//when adding new listeners, don't forget to also remove them in
			//removeProjectHandler()

			_port = findOpenPort();
			startNativeProcess();
		}

		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project !== _project)
			{
				return;
			}
			_project.removeEventListener(AS3ProjectVO.CHANGE_CUSTOM_SDK, projectChangeCustomSDKHandler);
			_dispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_dispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_DIDOPEN, didOpenCall);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_DIDCHANGE, didChangeCall);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_TYPEAHEAD, completionHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_HOVER, hoverHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_GOTO_DEFINITION, gotoDefinitionHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_dispatcher.removeEventListener(TypeAheadEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_dispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
			_dispatcher.removeEventListener(MenuPlugin.CHANGE_MENU_SDK_STATE, changeMenuSDKStateHandler);
			_dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, shutdownHandler);
			shutdownHandler(null);
		}

		public function get project():AS3ProjectVO
		{
			return _project;
		}

		private function getNextRequestID():int
		{
			_requestID++;
			return _requestID;
		}

		private function isActiveEditorInProject():Boolean
		{
			var editor:BasicTextEditor = _model.activeEditor as BasicTextEditor;
			if(!editor)
			{
				return false;
			}
			return isEditorInProject(editor);
		}

		private function isEditorInProject(editor:BasicTextEditor):Boolean
		{
			var nativePath:String = editor.currentFile.fileBridge.nativePath;
			if(_previousActiveFilePath === nativePath)
			{
				//optimization: don't check this path multiple times when we
				//probably already know the result from last time.
				return _previousActiveResult;
			}
			_previousActiveFilePath = nativePath;
			_previousActiveResult = false;
			var activeFile:File = new File(nativePath);
			var projectFile:File = new File(_project.folderPath);
			//getRelativePath() will return null if activeFile is not in the
			//projectFile directory
			if(projectFile.getRelativePath(activeFile, false) !== null)
			{
				_previousActiveResult = true;
				return _previousActiveResult;
			}
			var sourcePaths:Vector.<FileLocation> = _project.classpaths;
			var sourcePathCount:int = sourcePaths.length;
			for(var i:int = 0; i < sourcePathCount; i++)
			{
				var sourcePath:FileLocation = sourcePaths[i];
				var sourcePathFile:File = new File(sourcePath.fileBridge.nativePath);
				if(sourcePathFile.getRelativePath(activeFile, false) !== null)
				{
					_previousActiveResult = true;
					return _previousActiveResult;
				}
			}
			return _previousActiveResult;
		}

		private function parseSymbolInformation(original:Object):SymbolInformation
		{
			var vo:SymbolInformation = new SymbolInformation();
			vo.name = original.name;
			vo.kind = original.kind;
			vo.containerName = original.containerName;
			vo.location = parseLocation(original.location);
			return vo;
		}

		private function parseDiagnostic(path:String, original:Object):Diagnostic
		{
			var vo:Diagnostic = new Diagnostic();
			vo.path = path;
			vo.message = original.message;
			vo.code = original.code;
			vo.range = parseRange(original.range);
			vo.severity = original.severity;
			return vo;
		}

		private function parseLocation(original:Object):Location
		{
			var vo:Location = new Location();
			vo.uri = original.uri;
			vo.range = parseRange(original.range);
			return vo;
		}

		private function parseRange(original:Object):Range
		{
			var vo:Range = new Range();
			vo.start = parsePosition(original.start);
			vo.end = parsePosition(original.end);
			return vo;
		}

		private function parsePosition(original:Object):Position
		{
			var vo:Position = new Position();
			vo.line = original.line;
			vo.character = original.character;
			return vo;
		}

		private function parseCompletionItem(original:Object):CompletionItem
		{
			var command:Command = null;
            if(FIELD_COMMAND in original)
            {
                command = parseCommand(original.command);
            }

			return new CompletionItem(original.label, original.insertText,
                    original.kind, original.detail,
					original.documentation, command);
		}

		private function parseCommand(original:Object):Command
		{
			var vo:Command = new Command();
			vo.title = original.title;
			vo.command = original.command;
			vo.arguments = original.arguments;
			return vo;
		}

		private function parseSignatureInformation(original:Object):SignatureInformation
		{
			var vo:SignatureInformation = new SignatureInformation();
			vo.label = original.label;
			var originalParameters:Array = original.parameters;
			var parameters:Vector.<ParameterInformation> = new <ParameterInformation>[];
			var originalParametersCount:int = originalParameters.length;
			for(var i:int = 0; i < originalParametersCount; i++)
			{
				var resultParameter:Object = originalParameters;
				var parameter:ParameterInformation = new ParameterInformation();
				parameter.label = resultParameter[parameter];
				parameters[i] = parameter;
			}
			vo.parameters = parameters;
			return vo;
		}

		private function parseHover(original:Object):String
		{
			if(original === null)
			{
				return null;
			}
			if(original is String)
			{
				return original as String;
			}
			return original.value;
		}

		private function parseTextEdit(original:Object):TextEdit
		{
			var vo:TextEdit = new TextEdit();
			vo.range = this.parseRange(original.range);
			vo.newText = original.newText;
			return vo;
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
			processArgs.push("-Dmoonshine.port=" + _port);
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
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			_nativeProcess.start(_shellInfo);
		}

		private function parseData(data:String):void
		{
			if(!_connected && !_connecting)
			{
				connectToJava();
			}
		}

		protected function connectToJava():void
		{
			if(!_xmlSocket)
			{
				//Alert.show("XML Socket Start");
				_xmlSocket = new XMLSocket();
				_xmlSocket.addEventListener(Event.CONNECT, onSocketConnect);
				_xmlSocket.addEventListener(DataEvent.DATA, onIncomingData);
				_xmlSocket.addEventListener(IOErrorEvent.IO_ERROR,onSocketIOError);
				_xmlSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketSecurityErr);
				_xmlSocket.addEventListener(Event.CLOSE,closeHandler);
				_connecting = true;
				_xmlSocket.connect(SOCKET_ADDRESS, _port);
			}
		}
		
		private function initializeLanguageServer():void
		{
			if(_connecting)
			{
				//we haven't yet connected to the process
				return;
			}
			if(_initializeID != -1)
			{
				//we're already initializing...
				return;
			}
			if(_initialized)
			{
				//we're already initialized...
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

			var params:Object = new Object();
			params.rootUri = _project.folderLocation.fileBridge.url;
			params.rootPath = _project.folderLocation.fileBridge.nativePath;
			params.capabilities = {};
			params.workspaceFolders =
			[
				{ name: _project.name, uri: _project.folderLocation.fileBridge.url },
			];
			this._initializeID = this.sendRequest(METHOD_INITIALIZE, params);
		}

		private function sendRequest(method:String, params:Object):int
		{
			if(!_xmlSocket)
			{
				throw new IllegalOperationError("Request failed. Socket is not connected to language server.");
			}
			if(!_initialized && method != METHOD_INITIALIZE)
			{
				throw new IllegalOperationError("Request failed. Language server is not initialized. Unexpected method: " + method);
			}
			var id:int = getNextRequestID();
			var obj:Object = new Object();
			obj.jsonrpc = JSON_RPC_VERSION;
			obj.id = id;
			obj.method = method;
			obj.params = params;
			var jsonstr:String = JSON.stringify(obj);
			//trace(">>>", jsonstr);
			_xmlSocket.send(jsonstr);
			return id;
		}

		private function sendInitialized():void
		{
			if(this._initializeID != -1)
			{
				throw new IllegalOperationError("Cannot send initialized notification until initialize request completes.");
			}
			if(this._initialized)
			{
				throw new IllegalOperationError("Cannot send initialized notification multiple times.");
			}
			this._initialized = true;

			var params:Object = new Object();
			this.sendRequest(METHOD_INITIALIZED, params);
			
			sendProjectConfiguration();
			var editors:ArrayCollection = _model.editors;
			var count:int = editors.length;
			for(var i:int = 0; i < count; i++)
			{
				var editor:IContentWindow = IContentWindow(editors.getItemAt(i));
				if(editor is ActionScriptTextEditor)
				{
					var asEditor:ActionScriptTextEditor = ActionScriptTextEditor(editor);
					if(isEditorInProject(asEditor))
					{
						var uri:String = asEditor.currentFile.fileBridge.url;
						sendDidOpenRequest(uri, asEditor.text);
					}
				}
			}
		}

		private function sendDidOpenRequest(uri:String, text:String):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = uri;
			textDocument.languageId = LANGUAGE_ID_ACTIONSCRIPT;
			textDocument.version = 1;
			textDocument.text = text;

			var params:Object = new Object();
			params.textDocument = textDocument;

			this.sendRequest(METHOD_TEXT_DOCUMENT__DID_OPEN, params);
		}

		private function sendWorkspaceSettings():void
		{
			var frameworkSDK:String = getProjectSDKPath(_project, _model);
			var settings:Object = { nextgenas: { sdk: { framework: frameworkSDK } } };
			
			var params:Object = new Object();
			params.settings = settings;
			this.sendRequest(METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION, params);
		}

		private function sendProjectConfiguration():void
		{
			if(!_xmlSocket || !_initialized)
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
			this.sendRequest(METHOD_MOONSHINE__DID_CHANGE_PROJECT_CONFIGURATION, params);
		}
		
		private function textDocument__publishDiagnostics(jsonObject:Object):void
		{
			var diagnosticsParams:Object = jsonObject.params;
			var uri:String = diagnosticsParams.uri;
			var path:String = (new File(uri)).nativePath;
			var resultDiagnostics:Array = diagnosticsParams.diagnostics;
			var diagnostics:Vector.<Diagnostic> = new <Diagnostic>[];
			var diagnosticsCount:int = resultDiagnostics.length;
			for(var i:int = 0; i < diagnosticsCount; i++)
			{
				var resultDiagnostic:Object = resultDiagnostics[i];
				diagnostics[i] = parseDiagnostic(path, resultDiagnostic);
			}
			GlobalEventDispatcher.getInstance().dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
		}
		
		private function workspace__applyEdit(jsonObject:Object):void
		{
			var applyEditParams:Object = jsonObject.params;
			var edit:Object = applyEditParams.edit;
			var changes:Object = edit.changes;
			for(var uri:String in changes)
			{
				//the key is the file path, the value is a list of TextEdits
				var file:FileLocation = new FileLocation(uri, true);
				var resultChanges:Array = changes[uri];
				var resultChangesCount:int = resultChanges.length;
				var textEdits:Vector.<TextEdit> = new <TextEdit>[];
				for(var i:int = 0; i < resultChangesCount; i++)
				{
					var resultChange:Object = resultChanges[i];
					var textEdit:TextEdit = this.parseTextEdit(resultChange);
					textEdits[i] = textEdit;
				}
				applyTextEditsToFile(file, textEdits);
			}
		}

		private function shellData(e:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardOutput;
			parseData(output.readUTFBytes(output.bytesAvailable));
		}

		private function shellError(e:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			ConsoleUtil.print("shellError " + data + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa(data, null), 'weak');
			var match:Array;
			//A new filter added here which will detect command for FDB exit
			match = data.match(/.*\ onConnected */);
			if(match)
			{
				trace(data);
				parseData(data);
			}
			else
			{
				trace(data);
				//Alert.show("jar connection "+data);
			}

		}

		private function shellExit(e:NativeProcessExitEvent):void
		{
			if(_xmlSocket)
			{
				shutdownHandler(null);
			}
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			_nativeProcess.exit();
			_nativeProcess = null;
		}

		private function closeHandler(evt:Event):void{
			if(_xmlSocket){
				_connected = false;
				_connecting = false;
				_xmlSocket.close();
                cleanUpXmlSocket();
			}
		}

		private function onSocketConnect(event:Event):void
		{
			_connecting = false;
			_connected = true;
			initializeLanguageServer();
		}

		private function onSocketIOError(event:IOErrorEvent):void {
			ConsoleUtil.print("ioError " + event.text + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa("ioError "+event, null), 'weak');
		}

		private function onSocketSecurityErr(event:SecurityErrorEvent):void {
			ConsoleUtil.print("securityError " + event.text + ".");
			ConsoleOutputter.formatOutput(HtmlFormatter.sprintfa("securityError "+event, null), 'weak');
		}

		//Read Incoming data
		private function onIncomingData(event:DataEvent):void
		{
			var data:String = event.data;
			var object:Object = null;
			//trace("<<<", data);
			try
			{
				object = JSON.parse(data);
			}
			catch(error:Error)
			{
				trace("invalid JSON");
				return;
			}
			if(FIELD_METHOD in object)
			{
				var method:String = object.method;
				switch(method)
				{
					case METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:
					{
						this.textDocument__publishDiagnostics(object);
						break;
					}
					case METHOD_WORKSPACE__APPLY_EDIT:
					{
						this.workspace__applyEdit(object);
						break;
					}
					default:
					{
						trace("Unknown language server method:", method);
						break;
					}
				}
			}
			else if(FIELD_ID in object)
			{
				var result:Object = object.result;
				var requestID:int = object.id as int;
				if(this._initializeID != -1 && this._initializeID == requestID)
				{
					this._initializeID = -1;
					if(FIELD_ERROR in object)
					{
						trace("Error in language server. Initialize failed.");
					}
					this.sendInitialized();
				}
				else if(this._shutdownID != -1 && this._shutdownID == requestID)
				{
					this._shutdownID = -1;
					this.sendExit();
				}
				else if(FIELD_ERROR in object)
				{
					trace("Error in language server. Code: " + object.error.code + ", Message: " + object.error.message);
				}
				else if(result && FIELD_ITEMS in result) //completion
				{
					var resultCompletionItems:Array = result.items as Array;
					if(resultCompletionItems)
					{
						var eventCompletionItems:Array = new Array();
						var completionItemCount:int = resultCompletionItems.length;
						for(var i:int = 0; i < completionItemCount; i++)
						{
							var resultItem:Object = resultCompletionItems[i];
							eventCompletionItems[i] = parseCompletionItem(resultItem);
						}
						_dispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST,eventCompletionItems));
					}
				}
				else if(result && FIELD_SIGNATURES in result) //signature help
				{
					var resultSignatures:Array = result.signatures as Array;
					if(resultSignatures && resultSignatures.length > 0)
					{
						var eventSignatures:Vector.<SignatureInformation> = new <SignatureInformation>[];
						var resultSignaturesCount:int = resultSignatures.length;
						for(i = 0; i < resultSignaturesCount; i++)
						{
							var resultSignature:Object = resultSignatures[i];
							eventSignatures[i] = parseSignatureInformation(resultSignature);
						}
						var signatureHelp:SignatureHelp = new SignatureHelp();
						signatureHelp.signatures = eventSignatures;
						signatureHelp.activeSignature = result.activeSignature;
						signatureHelp.activeParameter = result.activeParameter;
						_dispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
					}
				}
				else if(result && FIELD_CONTENTS in result) //hover
				{
					var resultContents:Array = result.contents as Array;
					if(resultContents)
					{
						var eventContents:Vector.<String> = new <String>[];
						var resultContentsCount:int = resultContents.length;
						for(i = 0; i < resultContentsCount; i++)
						{
							var resultContent:Object = resultContents[i];
							eventContents[i] = parseHover(resultContent);
						}
						_dispatcher.dispatchEvent(new HoverEvent(HoverEvent.EVENT_SHOW_HOVER, eventContents));
					}
				}
				else if(result && FIELD_CHANGES in result) //rename
				{
					var resultChanges:Object = result.changes;
					var eventChanges:Object = {};
					for(var key:String in resultChanges)
					{
						var resultChangesList:Array = resultChanges[key] as Array;
						var eventChangesList:Vector.<TextEdit> = new <TextEdit>[];
						var resultChangesCount:int = resultChangesList.length;
						for(i = 0; i < resultChangesCount; i++)
						{
							var resultChange:Object = resultChangesList[i];
							eventChangesList[i] = this.parseTextEdit(resultChange);
						}
						eventChanges[key] = eventChangesList;
					}
					_dispatcher.dispatchEvent(new RenameEvent(RenameEvent.EVENT_APPLY_RENAME, eventChanges));
				}
				else if(result && result is Array) //definitions
				{
					if(requestID in _gotoDefinitionLookup)
					{
						var position:Position = _gotoDefinitionLookup[requestID] as Position;
						delete _gotoDefinitionLookup[requestID];
						var resultLocations:Array = result as Array;
						var eventLocations:Vector.<Location> = new <Location>[];
						var resultLocationsCount:int = resultLocations.length;
						for(i = 0; i < resultLocationsCount; i++)
						{
							var resultLocation:Object = resultLocations[i];
							eventLocations[i] = parseLocation(resultLocation);
						}
						_dispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, eventLocations, position));
					}
					else if(requestID in _findReferencesLookup)
					{
						delete _findReferencesLookup[requestID];
						var resultReferences:Array = result as Array;
						var eventReferences:Vector.<Location> = new <Location>[];
						var resultReferencesCount:int = resultReferences.length;
						for(i = 0; i < resultReferencesCount; i++)
						{
							var resultReference:Object = resultReferences[i];
							eventReferences[i] = parseLocation(resultReference);
						}
						_dispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, eventReferences));
					}
					else //document or workspace symbols
					{
						var resultSymbolInfos:Array = result as Array;
						var eventSymbolInfos:Vector.<SymbolInformation> = new <SymbolInformation>[];
						var resultSymbolInfosCount:int = resultSymbolInfos.length;
						for(i = 0; i < resultSymbolInfosCount; i++)
						{
							var resultSymbolInfo:Object = resultSymbolInfos[i];
							eventSymbolInfos[i] = parseSymbolInformation(resultSymbolInfo);
						}
						_dispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, eventSymbolInfos));
					}
				}
			}
		}

		public function shutdownHandler(event:Event):void{
			if(!_xmlSocket)
			{
				return;
			}
			this._shutdownID = this.sendRequest(METHOD_SHUTDOWN, null);
		}

		private function sendExit():void
		{
			if(!_xmlSocket)
			{
				return;
			}

			this.sendRequest(METHOD_EXIT, null);

			_connected = false;
			_connecting = false;
			_initialized = false;
			_initializeID = -1;
			_shutdownID = -1;
		}

		private function projectChangeCustomSDKHandler(event:Event):void
		{
			trace("Change custom SDK Path:", _project.customSDKPath);
			trace("Language Server framework SDK: " + getProjectSDKPath(_project, _model));
			if(_initialized)
			{
				//we've already initialized the server
				sendWorkspaceSettings();
			}
			else
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
			if(_initialized)
			{
				//we've already initialized the server
				sendWorkspaceSettings();
			}
			else
			{
				//we haven't started the native process yet
				//it's possible that we couldn't find any SDK at all
				startNativeProcess();
			}
		}

		private function didOpenCall(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			sendDidOpenRequest(event.uri, event.newText);
		}

		private function didChangeCall(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.version = 1;
			textDocument.uri = event.uri;

			var range:Object = new Object();
			var startposition:Object = new Object();
			startposition.line = event.startLineNumber;
			startposition.character = event.startLinePos;
			range.start = startposition;

			var endposition:Object = new Object();
			endposition.line = event.endLineNumber;
			endposition.character = event.endLinePos;
			range.end = endposition;

			var contentChangesArr:Array = new Array();
			var contentChanges:Object = new Object();
			contentChanges.range = null;//range;
			contentChanges.rangeLength = 0;//evt.textlen;
			contentChanges.text = event.newText;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.contentChanges = contentChanges;

			this.sendRequest(METHOD_TEXT_DOCUMENT__DID_CHANGE, params);
		}

		private function completionHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__COMPLETION, params);
		}

		private function signatureHelpHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__SIGNATURE_HELP, params);
		}

		private function hoverHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__HOVER, params);
		}

		private function gotoDefinitionHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__DEFINITION, params);
			_gotoDefinitionLookup[id] = new Position(event.endLineNumber, event.endLinePos);
		}

		private function workspaceSymbolsHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var query:String = event.newText;

			var params:Object = new Object();
			params.query = query;
			
			this.sendRequest(METHOD_WORKSPACE__SYMBOL, params);
		}

		private function documentSymbolsHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var params:Object = new Object();
			params.textDocument = textDocument;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL, params);
		}

		private function findReferencesHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var context:Object = new Object();
			context.includeDeclaration = true;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			params.context = context;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__REFERENCES, params);
			_findReferencesLookup[id] = true;
		}

		private function renameHandler(event:TypeAheadEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as BasicTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			params.newName = event.newText;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__RENAME, params);
		}
		
		private function executeCommandHandler(event:ExecuteLanguageServerCommandEvent):void
		{
			if(!_xmlSocket || !_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var params:Object = new Object();
			params.command = event.command;
			params.arguments = event.arguments;
			
			this.sendRequest(METHOD_WORKSPACE__EXECUTE_COMMAND, params);
		}

		private function cleanUpXmlSocket():void
		{
			if (!_xmlSocket)
			{
				return;
			}
			
            _xmlSocket.removeEventListener(Event.CONNECT, onSocketConnect);
            _xmlSocket.removeEventListener(DataEvent.DATA, onIncomingData);
            _xmlSocket.removeEventListener(IOErrorEvent.IO_ERROR,onSocketIOError);
            _xmlSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSocketSecurityErr);
            _xmlSocket.removeEventListener(Event.CLOSE,closeHandler);
            _xmlSocket = null;
		}
	}
}
