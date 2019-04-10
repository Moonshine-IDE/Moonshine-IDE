package actionScripts.languageServer
{
	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.CompletionItemsEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.events.HoverEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.ReferencesEvent;
	import actionScripts.events.SignatureHelpEvent;
	import actionScripts.events.SymbolsEvent;
	import actionScripts.events.LanguageServerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.CompletionItem;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Location;
	import actionScripts.valueObjects.ParameterInformation;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.SignatureHelp;
	import actionScripts.valueObjects.SignatureInformation;
	import actionScripts.valueObjects.SymbolInformation;
	import actionScripts.valueObjects.TextEdit;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.CodeActionsEvent;
	import actionScripts.valueObjects.CodeAction;
	import actionScripts.utils.LSPUtil;
	import actionScripts.valueObjects.DocumentSymbol;
	import actionScripts.valueObjects.WorkspaceEdit;
	import actionScripts.utils.applyWorkspaceEdit;
	import actionScripts.valueObjects.TextDocumentEdit;
	import actionScripts.valueObjects.TextDocumentIdentifier;
	import actionScripts.valueObjects.RenameFile;
	import actionScripts.valueObjects.DeleteFile;
	import actionScripts.valueObjects.CreateFile;
	import actionScripts.events.ResolveCompletionItemEvent;

	/**
	 * Dispatched when the language client has been initialized.
	 * 
	 * @see #initializing
	 * @see #initialized
	 */
	[Event(name="init")]

	/**
	 * Dispatched when the language client sends its exit request.
	 * 
	 * @see #stopping
	 * @see #stopped
	 */
	[Event(name="close")]

	/**
	 * An implementation of the language server protocol for Moonshine IDE.
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification Language Server Protocol Specification
	 */
	public class LanguageClient extends EventDispatcher
	{
		private static const HELPER_BYTES:ByteArray = new ByteArray();
		private static const PROTOCOL_HEADER_FIELD_CONTENT_LENGTH:String = "Content-Length: ";
		private static const PROTOCOL_HEADER_DELIMITER:String = "\r\n";
		private static const PROTOCOL_END_OF_HEADER:String = "\r\n\r\n";
		private static const FIELD_METHOD:String = "method";
		private static const FIELD_RESULT:String = "result";
		private static const FIELD_ERROR:String = "error";
		private static const FIELD_ID:String = "id";
		private static const FIELD_CHANGES:String = "changes";
		private static const FIELD_DOCUMENT_CHANGES:String = "documentChanges";
		private static const FIELD_CONTENTS:String = "contents";
		private static const FIELD_SIGNATURES:String = "signatures";
		private static const FIELD_ITEMS:String = "items";
		private static const FIELD_LOCATION:String = "location";
		private static const JSON_RPC_VERSION:String = "2.0";
		private static const METHOD_INITIALIZE:String = "initialize";
		private static const METHOD_INITIALIZED:String = "initialized";
		private static const METHOD_SHUTDOWN:String = "shutdown";
		private static const METHOD_EXIT:String = "exit";
		private static const METHOD_CANCEL_REQUEST:String = "$/cancelRequest";
		private static const METHOD_TEXT_DOCUMENT__DID_CHANGE:String = "textDocument/didChange";
		private static const METHOD_TEXT_DOCUMENT__DID_OPEN:String = "textDocument/didOpen";
		private static const METHOD_TEXT_DOCUMENT__DID_CLOSE:String = "textDocument/didClose";
		private static const METHOD_TEXT_DOCUMENT__WILL_SAVE:String = "textDocument/willSave";
		private static const METHOD_TEXT_DOCUMENT__DID_SAVE:String = "textDocument/didSave";
		private static const METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:String = "textDocument/publishDiagnostics";
		private static const METHOD_TEXT_DOCUMENT__COMPLETION:String = "textDocument/completion";
		private static const METHOD_TEXT_DOCUMENT__SIGNATURE_HELP:String = "textDocument/signatureHelp";
		private static const METHOD_TEXT_DOCUMENT__HOVER:String = "textDocument/hover";
		private static const METHOD_TEXT_DOCUMENT__DEFINITION:String = "textDocument/definition";
		private static const METHOD_TEXT_DOCUMENT__TYPE_DEFINITION:String = "textDocument/typeDefinition";
		private static const METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL:String = "textDocument/documentSymbol";
		private static const METHOD_TEXT_DOCUMENT__REFERENCES:String = "textDocument/references";
		private static const METHOD_TEXT_DOCUMENT__RENAME:String = "textDocument/rename";
		private static const METHOD_TEXT_DOCUMENT__CODE_ACTION:String = "textDocument/codeAction";
		private static const METHOD_WORKSPACE__APPLY_EDIT:String = "workspace/applyEdit";
		private static const METHOD_WORKSPACE__SYMBOL:String = "workspace/symbol";
		private static const METHOD_WORKSPACE__EXECUTE_COMMAND:String = "workspace/executeCommand";
		private static const METHOD_WORKSPACE__DID_CHANGE_CONFIGURATION:String = "workspace/didChangeConfiguration";
		private static const METHOD_WINDOW__LOG_MESSAGE:String = "window/logMessage";
		private static const METHOD_WINDOW__SHOW_MESSAGE:String = "window/showMessage";
		private static const METHOD_CLIENT__REGISTER_CAPABILITY:String = "client/registerCapability";
		private static const METHOD_TELEMETRY__EVENT:String = "telemetry/event";
		private static const METHOD_COMPLETION_ITEM__RESOLVE:String = "completionItem/resolve";

		public function LanguageClient(languageID:String, project:ProjectVO,
			debugMode:Boolean, initializationOptions:Object,
			globalDispatcher:IEventDispatcher, input:IDataInput, inputDispatcher:IEventDispatcher, inputEvent:String,
			output:IDataOutput, outputFlushCallback:Function = null)
		{
			_languageID = languageID;
			_project = project;
			this.debugMode = debugMode;
			_initializationOptions = initializationOptions;
			_globalDispatcher = globalDispatcher;
			_input = input;
			_inputDispatcher = inputDispatcher;
			_inputEvent = inputEvent;
			_output = output;
			_outputFlushCallback = outputFlushCallback;

			_inputDispatcher.addEventListener(_inputEvent, input_onData);
			
			_globalDispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_globalDispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_globalDispatcher.addEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DIDOPEN, didOpenCall);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DIDCHANGE, didChangeCall);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DIDCLOSE, didCloseCall);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_WILLSAVE, willSaveCall);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DIDSAVE, didSaveCall);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_COMPLETION, completionHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_HOVER, hoverHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DEFINITION_LINK, definitionLinkHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_CODE_ACTION, codeActionHandler);
			_globalDispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION, gotoDefinitionHandler);
			_globalDispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION, gotoTypeDefinitionHandler);
			_globalDispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
			_globalDispatcher.addEventListener(LanguageServerEvent.EVENT_RENAME, renameHandler);
			_globalDispatcher.addEventListener(ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM, resolveCompletionHandler);
			//when adding new listeners, don't forget to remove them in stop()

			sendInitialize();
		}

		private var _languageID:String;
		private var _project:ProjectVO;
		private var _initializationOptions:Object;
		private var _input:IDataInput;
		private var _output:IDataOutput;
		private var _inputDispatcher:IEventDispatcher;
		private var _inputEvent:String;
		private var _outputFlushCallback:Function;
		private var _globalDispatcher:IEventDispatcher;
		private var _model:IDEModel = IDEModel.getInstance();
		
		private var _initialized:Boolean = false;
		
		public function get initialized():Boolean
		{
			return this._initialized;
		}
		
		public function get initializing():Boolean
		{
			return this._initializeID != -1;
		}
		
		private var _stopped:Boolean = false;
		
		public function get stopped():Boolean
		{
			return this._stopped;
		}
		
		public function get stopping():Boolean
		{
			return this._shutdownID != -1;
		}

		public var debugMode:Boolean = false;

		private var _initializeID:int = -1;
		private var _shutdownID:int = -1;
		private var _requestID:int = 0;
		private var _documentVersion:int = 1;
		private var _contentLength:int = -1;
		private var _socketBuffer:String = "";
		private var _gotoDefinitionLookup:Dictionary = new Dictionary();
		private var _definitionLinkLookup:Dictionary = new Dictionary();
		private var _findReferencesLookup:Dictionary = new Dictionary();
		private var _gotoTypeDefinitionLookup:Dictionary = new Dictionary();
		private var _codeActionLookup:Dictionary = new Dictionary();
		private var _resolveCompletionLookup:Dictionary = new Dictionary();
		private var _completionLookup:Dictionary = new Dictionary();
		private var _previousActiveFilePath:String = null;
		private var _previousActiveResult:Boolean = false;
		private var _schemes:Vector.<String> = new <String>[]
		private var _savedDiagnostics:Object = {};

		protected var _notificationListeners:Object = {};

		private var _capabilities:Object = null;

		public function get capabilities():Object
		{
			return this._capabilities;
		}

		private var supportsCompletion:Boolean = false;
		private var resolveCompletion:Boolean = false;
		private var supportsHover:Boolean = false;
		private var supportsSignatureHelp:Boolean = false;
		private var supportsGotoDefinition:Boolean = false;
		private var supportsGotoTypeDefinition:Boolean = false;
		private var supportsReferences:Boolean = false;
		private var supportsDocumentSymbols:Boolean = false;
		private var supportsWorkspaceSymbols:Boolean = false;
		private var supportedCommands:Vector.<String> = new <String>[];
		private var supportsRename:Boolean = false;
		private var supportsCodeAction:Boolean = false;

		public function stop():void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}

			this.cleanup();
			_shutdownID = sendRequest(METHOD_SHUTDOWN, null);
		}

		public function registerScheme(scheme:String):void
		{
			this._schemes.push(scheme);
		}

		public function sendNotification(method:String, params:Object):void
		{
			if(!_initialized && method != METHOD_INITIALIZE && method != METHOD_EXIT)
			{
				throw new IllegalOperationError("Notification failed. Language server is not initialized. Unexpected method: " + method);
			}
			if(_stopped)
			{
				throw new IllegalOperationError("Notification failed. Language server is stopped. Unexpected method: " + method);
			}
			
			var contentPart:Object = new Object();
			contentPart.jsonrpc = JSON_RPC_VERSION;
			contentPart.method = method;
			contentPart.params = params;
			var contentJSON:String = JSON.stringify(contentPart);

			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(contentJSON);
			var contentLength:int = HELPER_BYTES.length;
			HELPER_BYTES.clear();

			var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
			var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;
			
			if(debugMode)
			{
				trace(">>> (NOTIFICATION)", contentJSON);
			}
			
			try
			{
				_output.writeUTFBytes(message);
			}
			catch(error:Error)
			{
				//if there's something wrong with the IDataOutput, we can't
				//send a final shutdown request
				stop();
				return;
			}
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}
		}

		private function cleanup():void
		{
			//clear any remaining diagnostics
			for(var uri:String in this._savedDiagnostics)
			{
				var path:String = (new File(uri)).nativePath;
				delete this._savedDiagnostics[uri];
				var diagnostics:Vector.<Diagnostic> = new <Diagnostic>[];
				_globalDispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
			}

			_globalDispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_globalDispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_globalDispatcher.removeEventListener(ProjectEvent.SAVE_PROJECT_SETTINGS, saveProjectSettingsHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_DIDOPEN, didOpenCall);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_DIDCHANGE, didChangeCall);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_COMPLETION, completionHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_HOVER, hoverHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_DEFINITION_LINK, definitionLinkHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_globalDispatcher.removeEventListener(LanguageServerEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_globalDispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
		}

		private function sendRequest(method:String, params:Object):int
		{
			if(!_initialized && method != METHOD_INITIALIZE)
			{
				throw new IllegalOperationError("Request failed. Language server is not initialized. Unexpected method: " + method);
			}
			
			var id:int = getNextRequestID();
			var contentPart:Object = new Object();
			contentPart.jsonrpc = JSON_RPC_VERSION;
			contentPart.id = id;
			contentPart.method = method;
			if(params !== null)
			{
				//omit it completely to avoid errors in servers that try to
				//parse an object
				contentPart.params = params;
			}
			var contentJSON:String = JSON.stringify(contentPart);

			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(contentJSON);
			var contentLength:int = HELPER_BYTES.length;
			HELPER_BYTES.clear();

			var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
			var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;
			
			if(debugMode)
			{
				trace(">>> (REQUEST)", contentJSON);
			}
			
			try
			{
				_output.writeUTFBytes(message);
			}
			catch(error:Error)
			{
				//if we're already trying to shut down, don't do it again
				if(method != METHOD_SHUTDOWN)
				{
					//if there's something wrong with the IDataOutput, we can't
					//send a final shutdown request
					stop();
				}
				else
				{
					//something went wrong while sending the shutdown request
					//there's nothing that we can do about that, so notify
					//any listeners that we've stopped
					_stopped = true;
					dispatchEvent(new Event(Event.CLOSE));
				}
				return id;
			}
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}

			return id;
		}

		public function addNotificationListener(method:String, listener:Function):void
		{
			if(!(method in this._notificationListeners))
			{
				this._notificationListeners[method] = new <Function>[];
			}
			var listeners:Vector.<Function> = this._notificationListeners[method] as Vector.<Function>;
			var index:int = listeners.indexOf(listener);
			if(index != -1)
			{
				//already added
				return;
			}
			listeners.push(listener);
		}

		public function removeNotificationListener(method:String, listener:Function):void
		{
			if(!(method in this._notificationListeners))
			{
				//nothing to remove
				return;
			}
			var listeners:Vector.<Function> = this._notificationListeners[method] as Vector.<Function>;
			var index:int = listeners.indexOf(listener);
			if(index == -1)
			{
				//nothing to remove
				return;
			}
			listeners.removeAt(index);
		}

		private function sendResponse(id:Object, result:Object = null, error:Object = null):void
		{
			if(!_initialized)
			{
				throw new IllegalOperationError("Response failed. Language server is not initialized.");
			}
			
			var contentPart:Object = new Object();
			contentPart.jsonrpc = JSON_RPC_VERSION;
			contentPart.id = id;
			if(result)
			{
				contentPart.result = result;
			}
			if(error)
			{
				contentPart.error = error;
			}
			var contentJSON:String = JSON.stringify(contentPart);

			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(contentJSON);
			var contentLength:int = HELPER_BYTES.length;
			HELPER_BYTES.clear();

			var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
			var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;
			
			if(debugMode)
			{
				trace(">>> (RESPONSE)", contentJSON);
			}
			
			try
			{
				_output.writeUTFBytes(message);
			}
			catch(error:Error)
			{
				//if there's something wrong with the IDataOutput, we can't
				//send a final shutdown request
				stop();
				return;
			}
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}
		}

		private function getNextRequestID():int
		{
			_requestID++;
			return _requestID;
		}

		private function sendInitialize():void
		{
			var params:Object = new Object();
			params.rootUri = _project.folderLocation.fileBridge.url;
			params.rootPath = _project.folderLocation.fileBridge.nativePath;
			params.capabilities =
			{
				workspace:
				{
					applyEdit: true,
					workspaceEdit:
					{
						documentChanges: false	
					},
					didChangeConfiguration:
					{
						dynamicRegistration: false
					},
					didChangeWatchedFiles:
					{
						dynamicRegistration: false
					},
					symbol:
					{
						dynamicRegistration: false
					},
					executeCommand:
					{
						dynamicRegistration: false
					},
					workspaceFolders: false,
					configuration: false
				},
				textDocument:
				{
					synchronization:
					{
						dynamicRegistration: false,
						willSave: true,
						willSaveWaitUntil: false,
						didSave: true
					},
					completion:
					{
						dynamicRegistration: false,
						completionItem:
						{
							snippetSupport: false,
							commitCharactersSupport: false,
							documentationFormat: ["plaintext"],
							deprecatedSupport: false
						},
						completionItemKind:
						{
							//valueSet: []
						},
						contextSupport: false
					},
					hover:
					{
						dynamicRegistration: false,
						contentFormat: ["plaintext"]
					},
					signatureHelp:
					{
						dynamicRegistration: false,
						signatureInformation:
						{
							documentationFormat: ["plaintext"]
						}
					},
					references:
					{
						dynamicRegistration: false
					},
					documentHighlight:
					{
						dynamicRegistration: false
					},
					documentSymbol:
					{
						dynamicRegistration: false,
						hierarchicalDocumentSymbolSupport: false,
						symbolKind:
						{
							//valueSet: []
						}
					},
					formatting:
					{
						dynamicRegistration: false
					},
					rangeFormatting:
					{
						dynamicRegistration: false
					},
					onTypeFormatting:
					{
						dynamicRegistration: false
					},
					definition:
					{
						dynamicRegistration: false
					},
					typeDefinition:
					{
						dynamicRegistration: false
					},
					implementation:
					{
						dynamicRegistration: false
					},
					codeAction:
					{
						dynamicRegistration: false,
						codeActionLiteralSupport:
						{
							codeActionKind:
							{
								//valueSet: []
							}
						}
					},
					codeLens:
					{
						dynamicRegistration: false
					},
					documentLink:
					{
						dynamicRegistration: false
					},
					colorProvider:
					{
						dynamicRegistration: false
					},
					rename:
					{
						dynamicRegistration: false
					},
					publishDiagnostics:
					{
						relatedInformation: false
					}
				}
			};
			params.workspaceFolders =
			[
				{ name: _project.name, uri: _project.folderLocation.fileBridge.url },
			];
			params.initializationOptions = _initializationOptions;
			_initializeID = sendRequest(METHOD_INITIALIZE, params);
		}

		private function sendInitialized():void
		{
			if(_initializeID != -1)
			{
				throw new IllegalOperationError("Cannot send initialized notification until initialize request completes.");
			}
			if(_initialized)
			{
				throw new IllegalOperationError("Cannot send initialized notification multiple times.");
			}
			_initialized = true;

			var params:Object = new Object();
			sendNotification(METHOD_INITIALIZED, params);

			this.dispatchEvent(new Event(Event.INIT));
			
			var editors:ArrayCollection = _model.editors;
			var count:int = editors.length;
			for(var i:int = 0; i < count; i++)
			{
				var editor:IContentWindow = IContentWindow(editors.getItemAt(i));
				if(editor is LanguageServerTextEditor)
				{
					var lspEditor:LanguageServerTextEditor = LanguageServerTextEditor(editor);
					if(isEditorInProject(lspEditor))
					{
						var uri:String = lspEditor.currentFile.fileBridge.url;
						sendDidOpenNotification(uri, lspEditor.text);
					}
				}
			}
		}

		private function sendExit():void
		{
			_inputDispatcher.removeEventListener(_inputEvent, input_onData);
			sendNotification(METHOD_EXIT, null);
			_stopped = true;
			dispatchEvent(new Event(Event.CLOSE));
		}

		private function sendDidOpenNotification(uri:String, text:String):void
		{
			if(!_initialized)
			{
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = uri;
			textDocument.languageId = _languageID;
			textDocument.version = _documentVersion;
			textDocument.text = text;
			_documentVersion++;

			var params:Object = new Object();
			params.textDocument = textDocument;

			sendNotification(METHOD_TEXT_DOCUMENT__DID_OPEN, params);
		}

		private function sendDidCloseNotification(uri:String):void
		{
			if(!_initialized)
			{
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var params:Object = new Object();
			params.textDocument = textDocument;

			sendNotification(METHOD_TEXT_DOCUMENT__DID_CLOSE, params);
		}

		private function parseMessageBuffer():void
		{
			var object:Object = null;
			try
			{
				var needsHeaderPart:Boolean = _contentLength == -1;
				if(needsHeaderPart && _socketBuffer.indexOf(PROTOCOL_END_OF_HEADER) == -1)
				{
					//not enough data for the header yet
					return;
				}
				while(needsHeaderPart)
				{
					var index:int = _socketBuffer.indexOf(PROTOCOL_HEADER_DELIMITER);
					var headerField:String = _socketBuffer.substr(0, index);
					_socketBuffer = _socketBuffer.substr(index + PROTOCOL_HEADER_DELIMITER.length);
					if(index == 0)
					{
						//this is the end of the header
						needsHeaderPart = false;
					}
					else if(headerField.indexOf(PROTOCOL_HEADER_FIELD_CONTENT_LENGTH) == 0)
					{
						var contentLengthAsString:String = headerField.substr(PROTOCOL_HEADER_FIELD_CONTENT_LENGTH.length);
						_contentLength = parseInt(contentLengthAsString, 10);
					}
				}
				if(_contentLength == -1)
				{
					trace("Language client failed to parse Content-Length header");
					return;
				}
				HELPER_BYTES.clear();
				HELPER_BYTES.writeUTFBytes(_socketBuffer);
				if(HELPER_BYTES.length < _contentLength)
				{
					HELPER_BYTES.clear();
					//we don't have the full content part of the message yet
					return;
				}
				HELPER_BYTES.position = 0;
				var message:String = HELPER_BYTES.readUTFBytes(_contentLength);
				HELPER_BYTES.clear();
				_contentLength = -1;
				_socketBuffer = _socketBuffer.substr(message.length);
				if(debugMode)
				{
					trace("<<<", message);
				}
				object = JSON.parse(message);
			}
			catch(error:Error)
			{
				trace("invalid JSON");
				return;
			}
			parseMessage(object);

			//check if there's another message in the buffer
			parseMessageBuffer();
		}

		private function getMessageID(message:Object):int
		{
			var id:int = -1;
			if(!(FIELD_ID in message))
			{
				return id;
			}
			var untypedID:Object = message.id;
			if(untypedID is String)
			{
				return parseInt(untypedID as String, 10);
			}
			else if(untypedID is Number)
			{
				return untypedID as Number
			}
			return id;
		}

		private function isActiveEditorInProject():Boolean
		{
			var editor:LanguageServerTextEditor = _model.activeEditor as LanguageServerTextEditor;
			if(!editor)
			{
				return false;
			}
			return isEditorInProject(editor);
		}

		private function isEditorInProject(editor:LanguageServerTextEditor):Boolean
		{
			if(!editor.currentFile)
			{
				return false;
			}
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
			if(_project is AS3ProjectVO)
			{
				var as3Project:AS3ProjectVO = AS3ProjectVO(_project);
				var sourcePaths:Vector.<FileLocation> = as3Project.classpaths;
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
			}
			return _previousActiveResult;
		}

		private function parseMessage(object:Object):void
		{
			if(FIELD_METHOD in object)
			{
				this.parseMethod(object);
			}
			else if(FIELD_ID in object)
			{
				var result:Object = object.result;
				var requestID:int = getMessageID(object);
				if(_initializeID != -1 && _initializeID == requestID)
				{
					_initializeID = -1;
					if(FIELD_ERROR in object)
					{
						trace("Error in language server. Initialize failed. Code: " + object.error.code + ", Message: " + object.error.message);
						cleanup();
						sendExit();
						return;
					}
					handleInitializeResponse(result);
					sendInitialized();
				}
				else if(_shutdownID != -1 && _shutdownID == requestID)
				{
					_shutdownID = -1;
					sendExit();
				}
				else if(FIELD_ERROR in object)
				{
					trace("Error in language server. Code: " + object.error.code + ", Message: " + object.error.message);
				}
				else if(requestID in _resolveCompletionLookup) //resolve completion
				{
					var original:CompletionItem = CompletionItem(_resolveCompletionLookup[requestID]);
					delete _resolveCompletionLookup[requestID];
					handleCompletionResolveResponse(original, result);
				}
				else if(result && FIELD_ITEMS in result) //completion (CompletionList)
				{
					delete _completionLookup[requestID];
					handleCompletionResponse(result);
				}
				else if(result && FIELD_SIGNATURES in result) //signature help
				{
					handleSignatureHelpResponse(result);
				}
				else if(result && FIELD_CONTENTS in result) //hover
				{
					handleHoverResponse(result);
				}
				else if(result && FIELD_DOCUMENT_CHANGES in result) //rename
				{
					handleRenameResponse(result);
				}
				else if(result && FIELD_CHANGES in result) //rename
				{
					handleRenameResponse(result);
				}
				else if(result && result is Array)
				{
					if(requestID in _completionLookup) //completion (CompletionItem[])
					{
						delete _completionLookup[requestID];
						handleCompletionResponse(result);
					}
					else if(requestID in _definitionLinkLookup)
					{
						var position:Position = _definitionLinkLookup[requestID] as Position;
						delete _definitionLinkLookup[requestID];
						handleDefinitionLinkResponse(result, position);
					}
					else if(requestID in _gotoDefinitionLookup)
					{
						position = _gotoDefinitionLookup[requestID] as Position;
						delete _gotoDefinitionLookup[requestID];
						handleGotoDefinitionResponse(result, position);
					}
					else if(requestID in _gotoTypeDefinitionLookup)
					{
						position = _gotoTypeDefinitionLookup[requestID] as Position;
						delete _gotoTypeDefinitionLookup[requestID];
						handleGotoTypeDefinitionResponse(result, position);
					}
					else if(requestID in _findReferencesLookup)
					{
						delete _findReferencesLookup[requestID];
						handleReferencesResponse(result);
					}
					else if(requestID in _codeActionLookup)
					{
						delete _codeActionLookup[requestID];
						handleCodeActionResponse(result);
					}
					else //document or workspace symbols
					{
						handleSymbolsResponse(result);
					}
				}
			}
		}

		private function parseMethod(object:Object):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			var found:Boolean = true;
			var method:String = object.method;
			switch(method)
			{
				case METHOD_TEXT_DOCUMENT__PUBLISH_DIAGNOSTICS:
				{
					textDocument__publishDiagnostics(object);
					//this is a notification and does not require a response
					break;
				}
				case METHOD_WORKSPACE__APPLY_EDIT:
				{
					workspace__applyEdit(object);
					sendResponse(object.id, { applied: true });
					break;
				}
				case METHOD_WINDOW__LOG_MESSAGE:
				{
					window__logMessage(object);
					break;
				}
				case METHOD_WINDOW__SHOW_MESSAGE:
				{
					window__showMessage(object);
					break;
				}
				case METHOD_CLIENT__REGISTER_CAPABILITY:
				{
					//TODO: implement this
					sendResponse(object.id, {});
					break;
				}
				case METHOD_TELEMETRY__EVENT:
				{
					//just ignore this one
					break;
				}
				default:
				{
					found = false;
					break;
				}
			}
			if(!found)
			{
				found = this.handleNotification(object);
			}
			if(!found)
			{
				trace("Unknown language server method:", method);
			}
		}

		private function handleInitializeResponse(result:Object):void
		{
			var capabilities:Object = result.capabilities;
			this.supportsCompletion = capabilities && (capabilities.completionProvider !== undefined);
			this.resolveCompletion = this.supportsCompletion &&
				capabilities.completionProvider.hasOwnProperty("resolveProvider") &&
				capabilities.completionProvider.resolveProvider;
			this.supportsHover = capabilities && (capabilities.hoverProvider as Boolean);
			this.supportsSignatureHelp = capabilities && (capabilities.signatureHelpProvider !== undefined);
			this.supportsGotoDefinition = capabilities && (capabilities.definitionProvider as Boolean);
			this.supportsGotoTypeDefinition = capabilities && capabilities.typeDefinitionProvider !== false && capabilities.typeDefinitionProvider !== undefined;
			this.supportsReferences = capabilities && (capabilities.referencesProvider as Boolean);
			this.supportsDocumentSymbols = capabilities && (capabilities.documentSymbolProvider as Boolean);
			this.supportsWorkspaceSymbols = capabilities && (capabilities.workspaceSymbolProvider as Boolean);
			this.supportsRename = capabilities && capabilities.renameProvider !== false && capabilities.renameProvider !== undefined;
			this.supportsCodeAction = capabilities && capabilities.codeActionProvider !== false && capabilities.codeActionProvider !== undefined;
			if(capabilities && capabilities.executeCommandProvider !== undefined)
			{
				this.supportedCommands = Vector.<String>(capabilities.executeCommandProvider.commands);
			}
		}

		private function handleCompletionResponse(result:Object):void
		{
			var resultCompletionItems:Array = null;
			if(result is Array)
			{
				resultCompletionItems = result as Array;
			}
			else
			{
				resultCompletionItems = result.items as Array;
			}
			if(!resultCompletionItems)
			{
				return;
			}
			var eventCompletionItems:Array = new Array();
			var completionItemCount:int = resultCompletionItems.length;
			for(var i:int = 0; i < completionItemCount; i++)
			{
				var resultItem:Object = resultCompletionItems[i];
				eventCompletionItems[i] = CompletionItem.parse(resultItem);
			}
			_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST,eventCompletionItems));
		}

		private function handleCompletionResolveResponse(original:CompletionItem, result:Object):void
		{
			CompletionItem.resolve(original, result);
			_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, [original]));
		}

		private function handleSignatureHelpResponse(result:Object):void
		{
			var resultSignatures:Array = result.signatures as Array;
			if(resultSignatures && resultSignatures.length > 0)
			{
				var eventSignatures:Vector.<SignatureInformation> = new <SignatureInformation>[];
				var resultSignaturesCount:int = resultSignatures.length;
				for(var i:int = 0; i < resultSignaturesCount; i++)
				{
					var resultSignature:Object = resultSignatures[i];
					eventSignatures[i] = SignatureInformation.parse(resultSignature);
				}
				var signatureHelp:SignatureHelp = new SignatureHelp();
				signatureHelp.signatures = eventSignatures;
				signatureHelp.activeSignature = result.activeSignature;
				signatureHelp.activeParameter = result.activeParameter;
				_globalDispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
			}
		}

		private function handleHoverResponse(result:Object):void
		{
			var resultContents:Object = result.contents;
			var eventContents:Vector.<String> = new <String>[];
			if(resultContents is Array)
			{
				var resultContentsArray:Array = resultContents as Array;
				var resultContentsCount:int = resultContentsArray.length;
				for(var i:int = 0; i < resultContentsCount; i++)
				{
					var resultContentItem:Object = resultContentsArray[i];
					eventContents[i] = parseHover(resultContentItem);
				}
			}
			else
			{
				eventContents[0] = parseHover(resultContents);
			}
			_globalDispatcher.dispatchEvent(new HoverEvent(HoverEvent.EVENT_SHOW_HOVER, eventContents));
		}

		private function handleRenameResponse(result:Object):void
		{
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(result);
			applyWorkspaceEdit(workspaceEdit);
		}

		private function handleLocationsResponse(result:Array):Vector.<Location>
		{
			var eventLocations:Vector.<Location> = new <Location>[];
			var resultLocationsCount:int = result.length;
			for(var i:int = 0; i < resultLocationsCount; i++)
			{
				var resultLocation:Object = result[i];
				var eventLocation:Location = Location.parse(resultLocation);
				var uri:String = eventLocation.uri;
				var schemeEndIndex:int = uri.indexOf(":");
				var scheme:String = null;
				if(schemeEndIndex != -1)
				{
					scheme = uri.substr(0, schemeEndIndex);
				}
				if(scheme != "file" && this._schemes.indexOf(scheme) == -1)
				{
					//we don't know how to handle this URI scheme
					continue;
				}
				eventLocations.push(eventLocation);
			}
			return eventLocations;
		}

		private function handleDefinitionLinkResponse(result:Object, position:Position):void
		{
			var eventLocations:Vector.<Location> = handleLocationsResponse(result as Array);
			_globalDispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, eventLocations, position));
		}

		private function handleGotoDefinitionResponse(result:Object, position:Position):void
		{
			var eventLocations:Vector.<Location> = handleLocationsResponse(result as Array);
			if(eventLocations.length > 0)
			{
				var location:Location = eventLocations[0];
				_globalDispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location));
			}
		}

		private function handleGotoTypeDefinitionResponse(result:Object, position:Position):void
		{
			var eventLocations:Vector.<Location> = handleLocationsResponse(result as Array);
			if(eventLocations.length > 0)
			{
				var location:Location = eventLocations[0];
				_globalDispatcher.dispatchEvent(
					new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, location));
			}
		}

		private function handleReferencesResponse(result:Object):void
		{
			var resultReferences:Array = result as Array;
			var eventReferences:Vector.<Location> = new <Location>[];
			var resultReferencesCount:int = resultReferences.length;
			for(var i:int = 0; i < resultReferencesCount; i++)
			{
				var resultReference:Object = resultReferences[i];
				eventReferences[i] = Location.parse(resultReference);
			}
			_globalDispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, eventReferences));
		}

		private function handleCodeActionResponse(result:Object):void
		{	
			var resultCodeActions:Array = result as Array;
			var eventCodeActions:Vector.<CodeAction> = new <CodeAction>[];
			var resultCodeActionsCount:int = resultCodeActions.length;
			for(var i:int = 0; i < resultCodeActionsCount; i++)
			{
				var resultCodeAction:Object = resultCodeActions[i];
				if(resultCodeAction.command is String)
				{
					//this is a Command instead of a CodeAction
					var command:Command = Command.parse(resultCodeAction);
					var codeAction:CodeAction = new CodeAction();
					codeAction.title = command.title;
					codeAction.command = command;
					eventCodeActions[i] = codeAction;
				}
				else
				{
					codeAction = CodeAction.parse(resultCodeAction);
					eventCodeActions[i] = codeAction;
				}
			}
			var editor:LanguageServerTextEditor = _model.activeEditor as LanguageServerTextEditor;
			if(!editor)
			{
				return;
			}
			var path:String = editor.currentFile.fileBridge.nativePath;
			_globalDispatcher.dispatchEvent(new CodeActionsEvent(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, path, eventCodeActions));
		}

		private function handleSymbolsResponse(result:Object):void
		{
			var resultSymbolInfos:Array = result as Array;
			var eventSymbolInfos:Array = [];
			var resultSymbolInfosCount:int = resultSymbolInfos.length;
			for(var i:int = 0; i < resultSymbolInfosCount; i++)
			{
				var resultSymbolInfo:Object = resultSymbolInfos[i];
				if(FIELD_LOCATION in resultSymbolInfo)
				{
					//if location is defined, it's a flat SymbolInformation
					eventSymbolInfos[i] = SymbolInformation.parse(resultSymbolInfo);
				}
				else
				{
					//otherwise, it's a hierarchical DocumentSymbol
					eventSymbolInfos[i] = DocumentSymbol.parse(resultSymbolInfo);
				}
			}
			_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, eventSymbolInfos));
		}

		private function handleNotification(object:Object):Boolean
		{
			var method:String = object.method;
			if(!(method in this._notificationListeners))
			{
				return false;
			}
			var listeners:Vector.<Function> = this._notificationListeners[method] as Vector.<Function>;
			var listenerCount:int = listeners.length;
			if(listenerCount == 0)
			{
				return false;
			}
			for(var i:int = 0; i < listenerCount; i++)
			{
				var listener:Function = listeners[i];
				listener(object);
			}
			return true;
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
		
		private function textDocument__publishDiagnostics(jsonObject:Object):void
		{
			var diagnosticsParams:Object = jsonObject.params;
			var uri:String = diagnosticsParams.uri;
			var path:String = (new File(uri)).nativePath;
			var resultDiagnostics:Array = diagnosticsParams.diagnostics;
			this._savedDiagnostics[uri] = resultDiagnostics;
			var diagnostics:Vector.<Diagnostic> = new <Diagnostic>[];
			var diagnosticsCount:int = resultDiagnostics.length;
			for(var i:int = 0; i < diagnosticsCount; i++)
			{
				var resultDiagnostic:Object = resultDiagnostics[i];
				diagnostics[i] = Diagnostic.parseWithPath(path, resultDiagnostic);
			}
			_globalDispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
		}
		
		private function workspace__applyEdit(jsonObject:Object):void
		{
			var applyEditParams:Object = jsonObject.params;
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit.parse(applyEditParams.edit);
			applyWorkspaceEdit(workspaceEdit)
		}

		private function window__logMessage(jsonObject:Object):void
		{
			var logMessageParams:Object = jsonObject.params;
			var message:String = logMessageParams.message;
			var type:int = logMessageParams.type;
			var eventType:String = null;
			switch(jsonObject.type)
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
			_globalDispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, message, false, false, eventType)
			);
			trace(message);
		}

		private function window__showMessage(jsonObject:Object):void
		{
			var showMessageParams:Object = jsonObject.params;
			var message:String = showMessageParams.message;
			var type:int = showMessageParams.type;
			var eventType:String = null;
			switch(jsonObject.type)
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

		private function removeProjectHandler(event:ProjectEvent):void
		{
			if(event.project != _project)
			{
				return;
			}
			this.stop();
		}

		private function applicationExitHandler(event:ApplicationEvent):void
		{
			this.stop();
		}

		private function saveProjectSettingsHandler(event:ProjectEvent):void
		{
			//this result may no longer be valid after project settings changes
			_previousActiveFilePath = null;
			_previousActiveResult = false;
		}

		private function didOpenCall(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			sendDidOpenNotification(event.uri, event.newText);
		}

		private function didCloseCall(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			sendDidCloseNotification(event.uri);
		}

		private function didChangeCall(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.version = _documentVersion;
			textDocument.uri = event.uri;
			_documentVersion++;

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

			sendNotification(METHOD_TEXT_DOCUMENT__DID_CHANGE, params);
		}

		private function willSaveCall(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var uri:String = event.uri;

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.reason = 1;

			sendNotification(METHOD_TEXT_DOCUMENT__WILL_SAVE, params);
		}

		private function didSaveCall(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var uri:String = event.uri;

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var params:Object = new Object();
			params.textDocument = textDocument;
			//TODO: include text, if registered for that

			sendNotification(METHOD_TEXT_DOCUMENT__DID_SAVE, params);
		}

		private function input_onData(event:Event):void
		{
			this._socketBuffer += _input.readUTFBytes(_input.bytesAvailable);
			this.parseMessageBuffer();
		}

		private function completionHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsCompletion)
			{
				_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, []));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__COMPLETION, params);
			_completionLookup[id] = true;
		}

		private function resolveCompletionHandler(event:ResolveCompletionItemEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!resolveCompletion)
			{
				return;
			}
			
			var id:int = this.sendRequest(METHOD_COMPLETION_ITEM__RESOLVE, event.item);
			_resolveCompletionLookup[id] = event.item;
		}

		private function signatureHelpHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsSignatureHelp)
			{
				var signatureHelp:SignatureHelp = new SignatureHelp();
				signatureHelp.signatures = new <SignatureInformation>[];
				_globalDispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__SIGNATURE_HELP, params);
		}

		private function hoverHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsHover)
			{
				_globalDispatcher.dispatchEvent(new HoverEvent(HoverEvent.EVENT_SHOW_HOVER, new <String>[]));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__HOVER, params);
		}

		private function definitionLinkHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			var positionVO:Position = new Position(event.endLineNumber, event.endLinePos);
			if(!supportsGotoDefinition)
			{
				_globalDispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, new <Location>[], positionVO));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var position:Object = new Object();
			position.line = event.endLineNumber;
			position.character = event.endLinePos;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__DEFINITION, params);
			_definitionLinkLookup[id] = positionVO;
		}

		private function gotoDefinitionHandler(event:MenuEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			if(!_model.activeEditor || !_model.activeEditor is LanguageServerTextEditor)
			{
				//no valid editor is open
				return;
			}
			event.preventDefault();
			if(!supportsGotoDefinition)
			{
				//nothing that we can do
				return;
			}

			var activeEditor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor)
			var uri:String = activeEditor.currentFile.fileBridge.url;
			var line:int = activeEditor.editor.model.selectedLineIndex;
			var char:int = activeEditor.editor.model.caretIndex;

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var position:Object = new Object();
			position.line = line;
			position.character = char;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__DEFINITION, params);
			_gotoDefinitionLookup[id] = new Position(line, char);
		}

		private function gotoTypeDefinitionHandler(event:MenuEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			if(!_model.activeEditor || !_model.activeEditor is LanguageServerTextEditor)
			{
				//no valid editor is open
				return;
			}
			event.preventDefault();
			if(!supportsGotoTypeDefinition)
			{
				//nothing that we can do
				return;
			}

			var activeEditor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor)
			var uri:String = activeEditor.currentFile.fileBridge.url;
			var line:int = activeEditor.editor.model.selectedLineIndex;
			var char:int = activeEditor.editor.model.caretIndex;

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var position:Object = new Object();
			position.line = line;
			position.character = char;

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.position = position;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__TYPE_DEFINITION, params);
			_gotoTypeDefinitionLookup[id] = new Position(line, char);
		}

		private function workspaceSymbolsHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented())
			{
				return;
			}
			//TODO: fix this to properly merge symbols from all projects
			if(!isActiveEditorInProject() && _model.projects.length != 1)
			{
				return;
			}
			event.preventDefault();
			if(!supportsWorkspaceSymbols)
			{
				_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, []));
				return;
			}

			var query:String = event.newText;

			var params:Object = new Object();
			params.query = query;
			
			this.sendRequest(METHOD_WORKSPACE__SYMBOL, params);
		}

		private function documentSymbolsHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsDocumentSymbols)
			{
				_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, []));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var params:Object = new Object();
			params.textDocument = textDocument;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL, params);
		}

		private function findReferencesHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsReferences)
			{
				_globalDispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, new <Location>[]));
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

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

		private function codeActionHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			var editor:LanguageServerTextEditor = LanguageServerTextEditor(_model.activeEditor);
			if(!supportsCodeAction)
			{
				var path:String = editor.currentFile.fileBridge.nativePath;
				_globalDispatcher.dispatchEvent(new CodeActionsEvent(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, path, new <CodeAction>[]));
				return;
			}

			var uri:String = editor.currentFile.fileBridge.url;

			var textDocument:Object = new Object();
			textDocument.uri = uri;

			var range:Object = new Object();
			var startposition:Object = new Object();
			startposition.line = event.startLineNumber;
			startposition.character = event.startLinePos;
			range.start = startposition;

			var endposition:Object = new Object();
			endposition.line = event.endLineNumber;
			endposition.character = event.endLinePos;
			range.end = endposition;

			var context:Object = new Object();
			if(uri in this._savedDiagnostics)
			{
				//we need to filter out diagnostics that don't apply to the
				//current selection range
				var eventRange:Range = new Range(
					new Position(event.startLineNumber, event.startLinePos),
					new Position(event.endLineNumber, event.endLinePos));
				var diagnostics:Array = this._savedDiagnostics[uri] as Array;
				context.diagnostics = diagnostics.filter(function(diagnostic:Object, index:int, original:Array):Boolean
				{
					var diagnosticRange:Range = new Range(
						new Position(diagnostic.range.start.line, diagnostic.range.start.character),
						new Position(diagnostic.range.end.line, diagnostic.range.end.character));
					return LSPUtil.rangesIntersect(eventRange, diagnosticRange);
				});
			}
			else
			{
				context.diagnostics = [];
			}

			var params:Object = new Object();
			params.textDocument = textDocument;
			params.range = range;
			params.context = context;
			
			var id:int = this.sendRequest(METHOD_TEXT_DOCUMENT__CODE_ACTION, params);
			_codeActionLookup[id] = true;
		}

		private function renameHandler(event:LanguageServerEvent):void
		{
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
			if(!supportsRename)
			{
				return;
			}

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

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
			if(!_initialized || _stopped || _shutdownID != -1)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			var command:String = event.command;
			if(supportedCommands.indexOf(command) == -1)
			{
				return;
			}
			event.preventDefault();

			var params:Object = new Object();
			params.command = command;
			params.arguments = event.arguments;
			
			this.sendRequest(METHOD_WORKSPACE__EXECUTE_COMMAND, params);
		}
	}
}