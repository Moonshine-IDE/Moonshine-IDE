////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.debugAdapter
{
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.debugAdapter.vo.BaseVariablesReference;
	import actionScripts.debugAdapter.vo.Scope;
	import actionScripts.debugAdapter.vo.Source;
	import actionScripts.debugAdapter.vo.StackFrame;
	import actionScripts.debugAdapter.vo.Variable;
	import actionScripts.debugAdapter.vo.VariablesReferenceHierarchicalData;
	import actionScripts.ui.editor.text.events.DebugLineEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	import mx.collections.ArrayCollection;

	/**
	 * Dispatched when the debug protocol connection is initialized.
	 */
	[Event(name="init")]

	/**
	 * Dispatched when a launch or attach request has connected.
	 */
	[Event(name="connect")]

	/**
	 * Dispatched when the connection has ended.
	 */
	[Event(name="close")]

	/**
	 * Dispatched when the state has changed, such as visible variables/scopes,
	 * paused/running, etc.
	 */
	[Event(name="change")]

	public class DebugAdapter extends ConsoleOutputter
	{
		private static const HELPER_BYTES:ByteArray = new ByteArray();
		private static const PROTOCOL_HEADER_FIELD_CONTENT_LENGTH:String = "Content-Length: ";
		private static const PROTOCOL_END_OF_HEADER:String = "\r\n\r\n";
		private static const PROTOCOL_HEADER_DELIMITER:String = "\r\n";
		private static const MESSAGE_TYPE_REQUEST:String = "request";
		private static const MESSAGE_TYPE_RESPONSE:String = "response";
		private static const MESSAGE_TYPE_EVENT:String = "event";
		private static const COMMAND_INITIALIZE:String = "initialize";
		private static const COMMAND_LAUNCH:String = "launch";
		private static const COMMAND_ATTACH:String = "attach";
		private static const COMMAND_THREADS:String = "threads";
		private static const COMMAND_SET_BREAKPOINTS:String = "setBreakpoints";
		private static const COMMAND_PAUSE:String = "pause";
		private static const COMMAND_CONTINUE:String = "continue";
		private static const COMMAND_NEXT:String = "next";
		private static const COMMAND_STEP_IN:String = "stepIn";
		private static const COMMAND_STEP_OUT:String = "stepOut";
		private static const COMMAND_DISCONNECT:String = "disconnect";
		private static const COMMAND_SCOPES:String = "scopes";
		private static const COMMAND_STACK_TRACE:String = "stackTrace";
		private static const COMMAND_VARIABLES:String = "variables";
		private static const COMMAND_CONFIGURATION_DONE:String = "configurationDone";
		private static const PREINITIALIZED_COMMANDS:Vector.<String> = new <String>[COMMAND_LAUNCH, COMMAND_ATTACH, COMMAND_DISCONNECT];
		private static const EVENT_INITIALIZED:String = "initialized";
		private static const EVENT_BREAKPOINT:String = "breakpoint";
		private static const EVENT_OUTPUT:String = "output";
		private static const EVENT_STOPPED:String = "stopped";
		private static const EVENT_TERMINATED:String = "terminated";
		private static const EVENT_LOADED_SOURCE:String = "loadedSource";
		private static const REQUEST_LAUNCH:String = "launch";
		private static const REQUEST_ATTACH:String = "attach";
		private static const OUTPUT_CATEGORY_CONSOLE:String = "console";
		private static const OUTPUT_CATEGORY_STDOUT:String = "stdout";
		private static const OUTPUT_CATEGORY_STDERR:String = "stderr";
		private static const OUTPUT_CATEGORY_TELEMETRY:String = "telemetry";

		public function DebugAdapter(clientID:String, clientName:String, debugMode:Boolean, dispatcher:IEventDispatcher,
			input:IDataInput, inputDispatcher:IEventDispatcher, inputEvent:String,
			output:IDataOutput, outputFlushCallback:Function = null)
		{
			_clientID = clientID;
			_clientName = clientName;
			_debugMode = debugMode;
			_dispatcher = dispatcher;
			_input = input;
			_inputDispatcher = inputDispatcher;
			_inputEvent = inputEvent;
			_output = output;
			_outputFlushCallback = outputFlushCallback;

			_inputDispatcher.addEventListener(_inputEvent, input_onData);
		}

		private var _clientID:String;
		private var _clientName:String;
		private var _debugMode:Boolean = false;
		private var _dispatcher:IEventDispatcher;
		private var _input:IDataInput;
		private var _output:IDataOutput;
		private var _inputDispatcher:IEventDispatcher;
		private var _inputEvent:String;
		private var _outputFlushCallback:Function;
		private var _model:IDEModel = IDEModel.getInstance();

		private var _supportsConfigurationDoneRequest:Boolean = false;

		private var _seq:int = 0;
		private var _messageBuffer:String = "";
		private var _messageBytes:ByteArray = new ByteArray();
		private var _contentLength:int = -1;
		private var mainThreadID:int = -1;
		private var _currentRequest:PendingRequest;

		private var _stackFrames:ArrayCollection = new ArrayCollection();

		public function get stackFrames():ArrayCollection
		{
			return _stackFrames;
		}

		private var _scopesAndVars:VariablesReferenceHierarchicalData = new VariablesReferenceHierarchicalData();

		public function get scopesAndVars():VariablesReferenceHierarchicalData
		{
			return _scopesAndVars;
		}

		private var _variablesLookup:Dictionary = new Dictionary();

		private var _receivedInitializeResponse:Boolean = false;
		private var _receivedInitializedEvent:Boolean = false;
		private var _waitingForLaunchOrAttach:Boolean = false;

		public function get initialized():Boolean
		{
			return _receivedInitializedEvent;
		}

		public function get launchedOrAttached():Boolean
		{
			return initialized && !_waitingForLaunchOrAttach;
		}

		private var _paused:Boolean = true;

		public function get paused():Boolean
		{
			return _paused;
		}

		public function start(adapterID:String, request:String, additionalProperties:Object):void
		{
			if(request != REQUEST_LAUNCH && request != REQUEST_ATTACH)
			{
				throw new IllegalOperationError("Unknown request to start debugger: " + request);
			}

			_currentRequest = new PendingRequest(adapterID, request, additionalProperties);

			this._stackFrames = new ArrayCollection();
			this._scopesAndVars = new VariablesReferenceHierarchicalData();
			
			_receivedInitializeResponse = false;
			_receivedInitializedEvent = false;
			_waitingForLaunchOrAttach = false;
			
			mainThreadID = -1;
			
			sendRequest(COMMAND_INITIALIZE,
			{
				"clientID": this._clientID,
				"clientName": this._clientName,
				"adapterID": adapterID,
				"pathFormat": "path",
				"linesStartAt1": true,
				"columnsStartAt1": true,
				"supportsVariableType": false,
				"supportsVariablePaging": false,
				"supportsRunInTerminalRequest": false,
				"supportsMemoryReferences": false,
				"locale": "en-us"
			});
		}

		public function stop():void
		{
			if(_receivedInitializeResponse && !_waitingForLaunchOrAttach)
			{
				this.sendRequest(COMMAND_DISCONNECT);
			}
			else
			{
				//if we haven't yet received a response to the initialize
				//request or if we're waiting for a response to attach/launch,
				//then we need to force the debug adapter to stop because it
				//won't be able to handle the disconnect request
				this.handleDisconnectOrTerminated();
			}
			_dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));

			this.cleanup();
		}

		private function cleanup():void
		{
		}

		public function resume():void
		{
            if (!_receivedInitializedEvent || _waitingForLaunchOrAttach || !_paused)
			{
				return;
			}

			this.sendRequest(COMMAND_CONTINUE);
			_dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
		}

		public function pause():void
		{
            if (!_receivedInitializedEvent || _waitingForLaunchOrAttach || _paused)
			{
				return;
			}

			this.sendRequest(COMMAND_PAUSE);
		}

		public function stepOver():void
		{
            if (!_receivedInitializedEvent || _waitingForLaunchOrAttach || !_paused)
			{
				return;
			}

			this.sendRequest(COMMAND_NEXT);
		}

		public function stepInto():void
		{
            if (!_receivedInitializedEvent || _waitingForLaunchOrAttach || !_paused)
			{
				return;
			}

			this.sendRequest(COMMAND_STEP_IN);
		}

		public function stepOut():void
		{
            if (!_receivedInitializedEvent || _waitingForLaunchOrAttach || !_paused)
			{
				return;
			}

			this.sendRequest(COMMAND_STEP_OUT);
		}
		
		private function handleDisconnectOrTerminated():void
		{
			//this function may be called when the debug adapter is in a bad
			//state. it may not have even started, or it may not be connected.
			//be careful what variables you access because some may be null.
			_paused = true;
			this._variablesLookup = new Dictionary();
			this._scopesAndVars.removeAll();
			this._stackFrames.removeAll();
			_receivedInitializeResponse = false;
			_receivedInitializedEvent = false;
			_waitingForLaunchOrAttach = false;
			
			_inputDispatcher.removeEventListener(_inputEvent, input_onData);

			this.dispatchEvent(new Event(Event.CHANGE));

			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function parseMessageBuffer():void
		{
			var object:Object = null;
			try
			{
				var needsHeaderPart:Boolean = _contentLength == -1;
				if(needsHeaderPart && _messageBuffer.indexOf(PROTOCOL_END_OF_HEADER) == -1)
				{
					//not enough data for the header yet
					return;
				}
				while(needsHeaderPart)
				{
					var index:int = _messageBuffer.indexOf(PROTOCOL_HEADER_DELIMITER);
					var headerField:String = _messageBuffer.substr(0, index);
					_messageBuffer = _messageBuffer.substr(index + PROTOCOL_HEADER_DELIMITER.length);
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
					trace("Error: Debug adapter client failed to parse Content-Length header");
					return;
				}
				//keep adding to the byte array until we have the full content
				_messageBytes.writeUTFBytes(_messageBuffer);
				_messageBuffer = "";
				if(_messageBytes.length < _contentLength)
				{
					//we don't have the full content part of the message yet,
					//so we'll try again the next time we have new data
					return;
				}
				_messageBytes.position = 0;
				var message:String = _messageBytes.readUTFBytes(_contentLength);
				//add any remaining bytes back into the buffer because they are
				//the beginning of the next message
				_messageBuffer = _messageBytes.readUTFBytes(_messageBytes.length - _contentLength);
				_messageBytes.clear();
				_contentLength = -1;
				object = JSON.parse(message);
			}
			catch(error:Error)
			{
				trace("Error: Debug adapter client failed to parse JSON.");
				return;
			}
			parseProtocolMessage(object);

			//check if there's another message in the buffer
			parseMessageBuffer();
		}
		
		private function sendRequest(command:String, args:Object = null):void
		{
			if(command != COMMAND_INITIALIZE && !_receivedInitializeResponse)
			{
				throw new IllegalOperationError("Send request failed. Must wait for initialize response before sending request of type '" + command + "' to the debug adapter.");
			}
			if(PREINITIALIZED_COMMANDS.indexOf(command) == -1 && _receivedInitializeResponse && !_receivedInitializedEvent)
			{
				throw new IllegalOperationError("Send request failed. Must wait for initialized event before sending request of type '" + command + "' to the debug adapter.");
			}
			_seq++;
			var message:Object =
				{
					"type": MESSAGE_TYPE_REQUEST,
					"seq": _seq,
					"command": command
				};
			if(args !== null)
			{
				message.arguments = args;
			}
			sendProtocolMessage(message);
		}
		
		private function sendProtocolMessage(message:Object):void
		{
			var contentJSON:String = JSON.stringify(message);
			if(_debugMode)
			{
				trace("<<< ", contentJSON);
			}
			HELPER_BYTES.clear();
			HELPER_BYTES.writeUTFBytes(contentJSON);
			var contentLength:int = HELPER_BYTES.length;
			HELPER_BYTES.clear();
			_output.writeUTFBytes(PROTOCOL_HEADER_FIELD_CONTENT_LENGTH);
			_output.writeUTFBytes(contentLength.toString());
			_output.writeUTFBytes(PROTOCOL_END_OF_HEADER);
			_output.writeUTFBytes(contentJSON);
			if(_outputFlushCallback != null)
			{
				_outputFlushCallback();
			}
		}
		
		private function parseProtocolMessage(message:Object):void
		{
			if("type" in message)
			{
				switch(message.type)
				{
					case MESSAGE_TYPE_RESPONSE:
					{
						this.parseResponse(message);
						break;
					}
					case MESSAGE_TYPE_EVENT:
					{
						this.parseEvent(message);
						break;
					}
					default:
					{
						trace("Cannot parse debug message. Unknown type: \"" + message.type + "\", Full message:", JSON.stringify(message));
					}
				}
			}
			else
			{
				trace("Cannot parse debug message. Missing type. Full message:", JSON.stringify(message));
			}
		}
		
		private function parseResponse(response:Object):void
		{
			if(_debugMode)
			{
				trace(">>> (RESPONSE) ", JSON.stringify(response));
			}
			if("command" in response)
			{
				switch(response.command)
				{
					case COMMAND_INITIALIZE:
					{
						this.parseInitializeResponse(response);
						break;
					}
					case COMMAND_ATTACH:
					{
						this.parseAttachResponse(response);
						break;
					}
					case COMMAND_LAUNCH:
					{
						this.parseLaunchResponse(response);
						break;
					}
					case COMMAND_CONFIGURATION_DONE:
					{
						this.parseConfigurationDoneResponse(response);
						break;
					}
					case COMMAND_CONTINUE:
					{
						this.parseContinueResponse(response);
						break;
					}
					case COMMAND_THREADS:
					{
						this.parseThreadsResponse(response);
						break;
					}
					case COMMAND_SET_BREAKPOINTS:
					{
						this.parseSetBreakpointsResponse(response);
						break;
					}
					case COMMAND_STACK_TRACE:
					{
						this.parseStackTraceResponse(response);
						break;
					}
					case COMMAND_SCOPES:
					{
						this.parseScopesResponse(response);
						break;
					}
					case COMMAND_VARIABLES:
					{
						this.parseVariablesResponse(response);
						break;
					}
					case COMMAND_DISCONNECT:
					{
						this.parseDisconnectResponse(response);
						break;
					}
					case COMMAND_PAUSE:
					case COMMAND_STEP_IN:
					case COMMAND_STEP_OUT:
					case COMMAND_NEXT:
					{
						if(response.success === false)
						{
							trace("debug adapter \"" + response.command + "\" command not successful");
						}
						break;
					}
					default:
					{
						trace("Cannot parse debug response. Unknown command: \"" + response.command + "\", Full message:", JSON.stringify(response));
					}
				}
			}
			else
			{
				trace("Cannot parse debug response. Missing command. Full message:", JSON.stringify(response));
			}
		}
		
		private function parseEvent(event:Object):void
		{
			if(_debugMode)
			{
				trace(">>> (EVENT) ", JSON.stringify(event));
			}
			if("event" in event)
			{
				switch(event.event)
				{
					case EVENT_INITIALIZED:
					{
						this.parseInitializedEvent(event);
						break;
					}
					case EVENT_OUTPUT:
					{
						this.parseOutputEvent(event);
						break;
					}
					case EVENT_BREAKPOINT:
					{
						//we don't currently indicate if a breakpoint is verified or
						//not so, we can ignore this one.
						break;
					}
					case EVENT_LOADED_SOURCE:
					{
						//we don't currently do anything with this event.
						break;
					}
					case EVENT_STOPPED:
					{
						this.parseStoppedEvent(event);
						break;
					}
					case EVENT_TERMINATED:
					{
						this.parseTerminatedEvent(event);
						break;
					}
					default:
					{
						trace("Cannot parse debug event. Unknown event:", "\"" + event.event + "\", Full message:", JSON.stringify(event));
					}
				}
			}
			else
			{
				trace("Cannot parse debug event. Missing event. Full message:", JSON.stringify(event));
			}
		}
		
		private function parseInitializeResponse(response:Object):void
		{
			if(!response.success)
			{
				error("debug adapter \"initialize\" command not successful");
				this.handleDisconnectOrTerminated();
				return;
			}
			var body:Object = response.body;
			_supportsConfigurationDoneRequest = body && body.supportsConfigurationDoneRequest === true;
			_receivedInitializeResponse = true;
			_receivedInitializedEvent = false;
			_waitingForLaunchOrAttach = false;

			//the request and command are the same constant
			var command:String = this._currentRequest.request;
			var args:Object =
			{
				"request": this._currentRequest.request,
				"type": this._currentRequest.adapterID
			};
			if(this._currentRequest.additionalProperties)
			{
				for(var key:String in this._currentRequest.additionalProperties)
				{
					args[key] = this._currentRequest.additionalProperties[key];
				}
			}
			this._waitingForLaunchOrAttach = true;
			this.sendRequest(command, args);
		}
		
		private function parseLaunchResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"launch\" command not successful");
				error("Debug launch failed.");
				this.stop();
				return;
			}
			this._waitingForLaunchOrAttach = false;
			this.dispatchEvent(new Event(Event.CONNECT));
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function parseAttachResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"attach\" command not successful");
				error("Debug attach failed.");
				this.stop();
				return;
			}
			this._waitingForLaunchOrAttach = false;
			this.dispatchEvent(new Event(Event.CONNECT));
			this.dispatchEvent(new Event(Event.CHANGE));
		}

		private function parseConfigurationDoneResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"configurationDone\" command not successful");
				error("Debug attach failed.");
				this.stop();
				return;
			}
			this.sendRequest(COMMAND_THREADS);
		}
		
		private function parseContinueResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"continue\" command not successful");
				return;
			}
			this._paused = false;
			
			//we're no longer paused, so clear this until we pause again
			this._stackFrames.removeAll();
			this._scopesAndVars.removeAll();

			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function parseThreadsResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"threads\" command not successful");
				return;
			}
			this._paused = false;
			this.dispatchEvent(new Event(Event.CHANGE));
			
			var body:Object = response.body;
			if("threads" in body)
			{
				var threads:Array = body.threads as Array;
				mainThreadID = threads[0].id;
			}
		}
		
		private function parseSetBreakpointsResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"setBreakpoints\" command not successful");
				return;
			}
			if(mainThreadID === -1)
			{
				this.sendRequest(COMMAND_THREADS);
			}
		}
		
		private function parseStackTraceResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"stackTrace\" command not successful");
				return;
			}
			var body:Object = response.body;
			if("stackFrames" in body)
			{
				this._stackFrames.removeAll();
				var stackFrames:Array = body.stackFrames as Array;
				var stackFramesCount:int = stackFrames.length;
				for(var i:int = 0; i < stackFramesCount; i++)
				{
					var stackFrame:StackFrame = this.parseStackFrame(stackFrames[i]);
					this._stackFrames.addItem(stackFrame);
				}
			}
			this.dispatchEvent(new Event(Event.CHANGE));
			if(this._stackFrames.length > 0)
			{
				var firstStackFrame:StackFrame = StackFrame(this._stackFrames.getItemAt(0));
				this.gotoStackFrame(firstStackFrame);
			}
		}
		
		private function parseStackFrame(response:Object):StackFrame
		{
			var vo:StackFrame = new StackFrame();
			vo.id = int(response.id);
			vo.name = response.name as String;
			vo.line = int(response.line);
			vo.column = int(response.column);
			vo.source = this.parseSource(response.source);
			return vo;
		}
		
		private function parseSource(response:Object):Source
		{
			if(!response)
			{
				//the stack trace sometimes includes functions internal to the
				//runtime that don't have a source. That's perfectly fine!
				return null;
			}
			var vo:Source = new Source();
			vo.name = response.name as String;
			vo.path = response.path as String;
			vo.sourceReference = response.sourceReference as Number;
			return vo;
		}
		
		public function loadVariables(scopeOrVar:BaseVariablesReference):void
		{
			var nextSeq:int = _seq + 1;
			this._variablesLookup[nextSeq] = scopeOrVar;
			this.sendRequest(COMMAND_VARIABLES,
			{
				variablesReference: scopeOrVar.variablesReference
			});
		}
		
		public function gotoStackFrame(stackFrame:StackFrame):void
		{
			if(!stackFrame.source)
			{
				//nothing to open! sometimes the stack trace includes functions
				//internal to the runtime that cannot be viewed as source.
				return;
			}
			var filePath:String = stackFrame.source.path;
			var line:int = stackFrame.line - 1;
			var character:int = stackFrame.column;
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.TRACE_LINE,
				[new FileLocation(filePath)], line);
			openEvent.atChar = character;
			_dispatcher.dispatchEvent(openEvent);
			
			this.sendRequest(COMMAND_SCOPES,
			{
				frameId: stackFrame.id
			});
		}
		
		public function setBreakpoints(path:String, breakpoints:Array):void
		{
			breakpoints = breakpoints.map(function(item:int, index:int, source:Array):Object
			{
				//the debugger expects breakpoints to start at line 1
				//but moonshine stores breakpoints from line 0
				return { line: item + 1 };
			});
			this.sendRequest(COMMAND_SET_BREAKPOINTS,
			{
				source: { path: path },
				breakpoints: breakpoints
			});
		}
		
		private function parseScopesResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"scopes\" command not successful");
				return;
			}
			var body:Object = response.body;
			if("scopes" in body)
			{
				this._variablesLookup = new Dictionary();
				var resultScopes:Array = [];
				var scopes:Array = body.scopes as Array;
				var scopesCount:int = scopes.length;
				for(var i:int = 0; i < scopesCount; i++)
				{
					var scope:Scope = this.parseScope(scopes[i]);
					resultScopes.push(scope);
				}
				this._scopesAndVars.setScopes(resultScopes);
				if(resultScopes.length > 0)
				{
					this.loadVariables(resultScopes[0]);
				}
			}
		}
		
		private function parseScope(response:Object):Scope
		{
			var vo:Scope = new Scope();
			vo.name = response.name as String;
			vo.variablesReference = response.variablesReference as Number;
			vo.expensive = response.expensive === true;
			return vo;
		}
		
		private function parseVariablesResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"variables\" command not successful");
				return;
			}
			var body:Object = response.body;
			if("variables" in body)
			{
				var requestID:int = response.request_seq;
				if(!(requestID in this._variablesLookup))
				{
					//we have new scopes, so we don't care anymore
					return;
				}
				var scopeOrVar:BaseVariablesReference = BaseVariablesReference(this._variablesLookup[requestID]);
				delete this._variablesLookup[requestID];
				var resultVariables:Array = [];
				var variables:Array = body.variables as Array;
				var variablesCount:int = variables.length;
				for(var i:int = 0; i < variablesCount; i++)
				{
					var variable:Variable = this.parseVariable(variables[i]);
					resultVariables[i] = variable;
				}
				this._scopesAndVars.setVariablesForScopeOrVar(resultVariables, scopeOrVar);
			}
		}
		
		private function parseVariable(response:Object):Variable
		{
			var vo:Variable = new Variable();
			vo.name = response.name as String;
			vo.value = response.value as String;
			if("variablesReference" in response)
			{
				//only populate if it exists!
				vo.variablesReference = response.variablesReference as Number;
			}
			else
			{
				vo.variablesReference = -1;
			}
			vo.type = response.type as String;
			return vo;
		}
		
		private function parseDisconnectResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"disconnect\" command not successful");
				return;
			}
			this.handleDisconnectOrTerminated();
		}
		
		private function parseInitializedEvent(event:Object):void
		{
			_receivedInitializedEvent = true;
			this.dispatchEvent(new Event(Event.INIT));
			if(this._supportsConfigurationDoneRequest)
			{
				this.sendRequest(COMMAND_CONFIGURATION_DONE, {});
			}
			else
			{
				this.sendRequest(COMMAND_THREADS);
			}
		}
		
		private function parseOutputEvent(event:Object):void
		{
			var output:String = null;
			var category:String = "console";
			if("body" in event)
			{
				var body:Object = event.body;
				if("output" in body)
				{
					output = body.output as String;
				}
				if("category" in body)
				{
					category = body.category as String;
				}
			}
			if(output != null)
			{
				if(category == OUTPUT_CATEGORY_STDERR)
				{
					error(output);
				}
				else if(category != OUTPUT_CATEGORY_TELEMETRY)
				{
					print(output);
				}
			}
		}
		
		private function parseStoppedEvent(event:Object):void
		{
			this.sendRequest(COMMAND_STACK_TRACE,
				{
					threadId: mainThreadID
				});
			_paused = true;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function parseTerminatedEvent(event:Object):void
		{
			this.handleDisconnectOrTerminated();
		}
		
		protected function input_onData(event:Event):void
		{
			_messageBuffer += _input.readUTFBytes(_input.bytesAvailable);
			parseMessageBuffer();
		}
	}
}

class PendingRequest
{
	public function PendingRequest(adapterID:String, request:String, additionalProperties:Object)
	{
		this.adapterID = adapterID;
		this.request = request;
		this.additionalProperties = additionalProperties;
	}

	public var request:String;
	public var adapterID:String;
	public var additionalProperties:Object;
}