package actionScripts.languageServer
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import actionScripts.factory.FileLocation;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.valueObjects.Diagnostic;
	import flash.filesystem.File;
	import actionScripts.events.HoverEvent;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput2;
	import flash.utils.IDataInput2;
	import flash.errors.IllegalOperationError;
	import flash.events.IEventDispatcher;
	import actionScripts.valueObjects.SignatureHelp;
	import actionScripts.valueObjects.SignatureInformation;
	import actionScripts.events.CompletionItemsEvent;
	import actionScripts.valueObjects.TextEdit;
	import actionScripts.valueObjects.ParameterInformation;
	import actionScripts.valueObjects.CompletionItem;
	import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;
	import actionScripts.valueObjects.Location;
	import actionScripts.valueObjects.SymbolInformation;
	import actionScripts.events.SymbolsEvent;
	import actionScripts.events.ReferencesEvent;
	import flash.utils.Dictionary;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.utils.applyTextEditsToFile;
	import actionScripts.events.SignatureHelpEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.ApplicationEvent;
	import actionScripts.events.ProjectEvent;
	import mx.collections.ArrayCollection;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.LanguageServerTextEditor;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

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
		private static const METHOD_CLIENT__REGISTER_CAPABILITY:String = "client/registerCapability";

		public function LanguageClient(languageID:String, project: ProjectVO, globalDispatcher:IEventDispatcher,
			input:IDataInput, inputDispatcher:IEventDispatcher, inputEvent:String, output:IDataOutput, outputFlushCallback:Function = null)
		{
			_languageID = languageID;
			_project = project;
			_globalDispatcher = globalDispatcher;
			_input = input;
			_inputDispatcher = inputDispatcher;
			_inputEvent = inputEvent;
			_output = output;
			_outputFlushCallback = outputFlushCallback;

			_inputDispatcher.addEventListener(_inputEvent, input_onData);
			
			_globalDispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_globalDispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_DIDOPEN, didOpenCall);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_DIDCHANGE, didChangeCall);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_TYPEAHEAD, completionHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_HOVER, hoverHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_GOTO_DEFINITION, gotoDefinitionHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_globalDispatcher.addEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
			_globalDispatcher.addEventListener(TypeAheadEvent.EVENT_RENAME, renameHandler);
			//when adding new listeners, don't forget to remove them in stop()

			sendInitialize();
		}

		private var _languageID:String;
		private var _project:ProjectVO;
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

		private var _initializeID:int = -1;
		private var _shutdownID:int = -1;
		private var _requestID:int = 0;
		private var _documentVersion:int = 1;
		private var _contentLength:int = -1;
		private var _socketBuffer:String = "";
		private var _gotoDefinitionLookup:Dictionary = new Dictionary();
		private var _findReferencesLookup:Dictionary = new Dictionary();
		private var _previousActiveFilePath:String = null;
		private var _previousActiveResult:Boolean = false;

		public function stop():void
		{
			if(!_initialized)
			{
				return;
			}
			_globalDispatcher.removeEventListener(ProjectEvent.REMOVE_PROJECT, removeProjectHandler);
			_globalDispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, applicationExitHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_DIDOPEN, didOpenCall);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_DIDCHANGE, didChangeCall);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_TYPEAHEAD, completionHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_SIGNATURE_HELP, signatureHelpHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_HOVER, hoverHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_GOTO_DEFINITION, gotoDefinitionHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_WORKSPACE_SYMBOLS, workspaceSymbolsHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_DOCUMENT_SYMBOLS, documentSymbolsHandler);
			_globalDispatcher.removeEventListener(TypeAheadEvent.EVENT_FIND_REFERENCES, findReferencesHandler);
			_globalDispatcher.removeEventListener(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND, executeCommandHandler);
			_shutdownID = sendRequest(METHOD_SHUTDOWN, null);
		}

		private function getNextRequestID():int
		{
			_requestID++;
			return _requestID;
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
			
			//trace(">>> (RESPONSE)", contentJSON);
			
			_output.writeUTFBytes(message);
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}
		}

		public function sendNotification(method:String, params:Object):void
		{
			if(!_initialized && method != METHOD_INITIALIZE)
			{
				throw new IllegalOperationError("Notification failed. Language server is not initialized. Unexpected method: " + method);
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
			
			//trace(">>> (NOTIFICATION)", contentJSON);
			
			_output.writeUTFBytes(message);
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}
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
			contentPart.params = params;
			var contentJSON:String = JSON.stringify(contentPart);

			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(contentJSON);
			var contentLength:int = HELPER_BYTES.length;
			HELPER_BYTES.clear();

			var headerPart:String = PROTOCOL_HEADER_FIELD_CONTENT_LENGTH + contentLength + PROTOCOL_HEADER_DELIMITER;
			var message:String = headerPart + PROTOCOL_HEADER_DELIMITER + contentJSON;
			
			//trace(">>> (REQUEST)", contentJSON);
			
			_output.writeUTFBytes(message);
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}

			return id;
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
						willSave: false,
						willSaveWaitUntil: false,
						didSave: false
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
						sendDidOpenRequest(uri, lspEditor.text);
					}
				}
			}
		}

		private function sendExit():void
		{
			_inputDispatcher.removeEventListener(_inputEvent, input_onData);
			sendNotification(METHOD_EXIT, null);
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function sendDidOpenRequest(uri:String, text:String):void
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
				//trace("<<<", message);
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
			var sourcePaths:Vector.<FileLocation> = (_project as AS3ProjectVO).classpaths;
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

		private function parseMessage(object:Object):void
		{
			if(FIELD_METHOD in object)
			{
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
					case METHOD_CLIENT__REGISTER_CAPABILITY:
					{
						//TODO: implement this
						sendResponse(object.id, {});
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
				if(_initializeID != -1 && _initializeID == requestID)
				{
					_initializeID = -1;
					if(FIELD_ERROR in object)
					{
						trace("Error in language server. Initialize failed.");
					}
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
						_globalDispatcher.dispatchEvent(new CompletionItemsEvent(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST,eventCompletionItems));
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
						_globalDispatcher.dispatchEvent(new SignatureHelpEvent(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, signatureHelp));
					}
				}
				else if(result && FIELD_CONTENTS in result) //hover
				{
					var resultContents:Object = result.contents;
					var eventContents:Vector.<String> = new <String>[];
					if(resultContents is Array)
					{
						var resultContentsArray:Array = resultContents as Array;
						var resultContentsCount:int = resultContentsArray.length;
						for(i = 0; i < resultContentsCount; i++)
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
							eventChangesList[i] = parseTextEdit(resultChange);
						}
						eventChanges[key] = eventChangesList;
					}
					_globalDispatcher.dispatchEvent(new RenameEvent(RenameEvent.EVENT_APPLY_RENAME, eventChanges));
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
						_globalDispatcher.dispatchEvent(new GotoDefinitionEvent(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, eventLocations, position));
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
						_globalDispatcher.dispatchEvent(new ReferencesEvent(ReferencesEvent.EVENT_SHOW_REFERENCES, eventReferences));
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
						_globalDispatcher.dispatchEvent(new SymbolsEvent(SymbolsEvent.EVENT_SHOW_SYMBOLS, eventSymbolInfos));
					}
				}
			}
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
			vo.range = parseRange(original.range);
			vo.newText = original.newText;
			return vo;
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
			_globalDispatcher.dispatchEvent(new DiagnosticsEvent(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, path, diagnostics));
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
					var textEdit:TextEdit = parseTextEdit(resultChange);
					textEdits[i] = textEdit;
				}
				applyTextEditsToFile(file, textEdits);
			}
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

		private function didOpenCall(event:TypeAheadEvent):void
		{
			if(!_initialized)
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
			if(!_initialized)
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

		private function input_onData(event:Event):void
		{
			this._socketBuffer += _input.readUTFBytes(_input.bytesAvailable);
			this.parseMessageBuffer();
		}

		private function completionHandler(event:TypeAheadEvent):void
		{
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

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
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

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

		private function hoverHandler(event:TypeAheadEvent):void
		{
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

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

		private function gotoDefinitionHandler(event:TypeAheadEvent):void
		{
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

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
			if(!_initialized)
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
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

			var textDocument:Object = new Object();
			textDocument.uri = (_model.activeEditor as LanguageServerTextEditor).currentFile.fileBridge.url;

			var params:Object = new Object();
			params.textDocument = textDocument;
			
			this.sendRequest(METHOD_TEXT_DOCUMENT__DOCUMENT_SYMBOL, params);
		}

		private function findReferencesHandler(event:TypeAheadEvent):void
		{
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();
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

		private function renameHandler(event:TypeAheadEvent):void
		{
			if(!_initialized)
			{
				return;
			}
			if(event.isDefaultPrevented() || !isActiveEditorInProject())
			{
				return;
			}
			event.preventDefault();

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
			if(!_initialized)
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
	}
}