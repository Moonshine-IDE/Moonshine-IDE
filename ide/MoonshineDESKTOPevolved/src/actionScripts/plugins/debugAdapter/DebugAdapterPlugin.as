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
package actionScripts.plugins.debugAdapter
{
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;
    import flash.utils.clearTimeout;

    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.EditorPluginEvent;
    import actionScripts.events.OpenFileEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.plugins.swflauncher.SWFDebugAdapterLauncher;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import actionScripts.plugins.debugAdapter.events.LoadVariablesEvent;
    import actionScripts.plugins.debugAdapter.events.StackFrameEvent;
    import actionScripts.plugins.debugAdapter.view.DebugAdapterView;
    import actionScripts.plugins.debugAdapter.vo.BaseVariablesReference;
    import actionScripts.plugins.debugAdapter.vo.Scope;
    import actionScripts.plugins.debugAdapter.vo.Source;
    import actionScripts.plugins.debugAdapter.vo.StackFrame;
    import actionScripts.plugins.debugAdapter.vo.Variable;
    import actionScripts.plugins.debugAdapter.vo.VariablesReferenceHierarchicalData;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;

    import mx.collections.ArrayCollection;
	
	public class DebugAdapterPlugin extends PluginBase
	{
		public static const EVENT_SHOW_HIDE_DEBUG_VIEW:String = "EVENT_SHOW_HIDE_DEBUG_VIEW";
		private static const MAX_RETRY_COUNT:int = 5;
		private static const TWO_CRLF:String = "\r\n\r\n";
		private static const CONTENT_LENGTH_PREFIX:String = "Content-Length: ";
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
		private static const EVENT_INITIALIZED:String = "initialized";
		private static const EVENT_BREAKPOINT:String = "breakpoint";
		private static const EVENT_OUTPUT:String = "output";
		private static const EVENT_STOPPED:String = "stopped";
		private static const EVENT_TERMINATED:String = "terminated";
		private static const REQUEST_LAUNCH:String = "launch";
		private static const REQUEST_ATTACH:String = "attach";
		private static const DEBUG_TYPE_SWF:String = "swf";
		private static const OUTPUT_CATEGORY_STDERR:String = "stderr";
		private static const CLIENT_ID:String = "moonshine";
		
		override public function get name():String 			{ return "VSCode Debug Protocol Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String 	{ return "Debugs ActionScript and MXML projects with the Visual Studio Code Debug Protocol."; }
		
		private var _breakpoints:Object = {};
		private var _debugPanel:DebugAdapterView;
		private var _nativeProcess:NativeProcess;
		private var _byteArray:ByteArray;
		private var _retryCount:int;
		private var _paused:Boolean = true;
		private var _seq:int = 0;
		private var _messageBuffer:String = "";
		private var _bodyLength:int = -1;
		private var mainThreadID:int = -1;
		private var connectTimeout:uint = uint.MAX_VALUE;
		private var _stackFrames:ArrayCollection = new ArrayCollection();
		private var _scopesAndVars:VariablesReferenceHierarchicalData = new VariablesReferenceHierarchicalData();
		private var _variablesLookup:Dictionary = new Dictionary();
		private var _currentProject:ProjectVO;
		private var _currentRequest:PendingRequest;
		private var isDebugViewVisible:Boolean;
		
		//change to true to enable more detailed debug logs
		private var _debugMode:Boolean = false;

		private var _connected:Boolean = false;
		private var _receivedInitializeResponse:Boolean = false;
		private var _waitingForLaunchOrAttach:Boolean = false;
		
		public function DebugAdapterPlugin()
		{
			_byteArray = new ByteArray();
		}
		
		override public function activate():void
		{
			super.activate();
			
			this._debugPanel = new DebugAdapterView();

			dispatcher.addEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
			dispatcher.addEventListener(DebugAdapterEvent.START_DEBUG_ADAPTER, dispatcher_startDebugAdapterHandler);
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_quitHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, stepOverExecutionHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, continueExecutionHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, terminateExecutionHandler);
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.STOP_DEBUG, dispatcher_stopDebugHandler);
			//if you add any new listeners here, before sure that you remove
			//them in deactivate()
			
			DebugHighlightManager.init();
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
			dispatcher.removeEventListener(DebugAdapterEvent.START_DEBUG_ADAPTER, dispatcher_startDebugAdapterHandler);
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_quitHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, stepOverExecutionHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, continueExecutionHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, terminateExecutionHandler);
			dispatcher.removeEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.STOP_DEBUG, dispatcher_stopDebugHandler);
		}
		
		private function saveEditorBreakpoints(editor:BasicTextEditor):void
		{
			if(!editor)
			{
				return;
			}
			if(!editor.currentFile)
			{
				return;
			}
			
			var path:String = editor.currentFile.fileBridge.nativePath;
			if (path == "")
			{
				return;
			}
			
			this._breakpoints[path] = editor.getEditorComponent().breakpoints;
		}
		
		private function parseMessageBuffer():void
		{
			if(this._bodyLength !== -1)
			{
				if(this._messageBuffer.length < this._bodyLength)
				{
					//we don't have the full body yet
					return;
				}
				var body:String = this._messageBuffer.substr(0, this._bodyLength);
				this._messageBuffer = this._messageBuffer.substr(this._bodyLength);
				this._bodyLength = -1;
				var message:Object = JSON.parse(body);
				this.parseProtocolMessage(message);
			}
			else if(this._messageBuffer.length > CONTENT_LENGTH_PREFIX.length)
			{
				//start with a new header
				var index:int = this._messageBuffer.indexOf(TWO_CRLF, CONTENT_LENGTH_PREFIX.length);
				if(index === -1)
				{
					//we don't have a full header yet
					return;
				}
				var lengthString:String = this._messageBuffer.substr(CONTENT_LENGTH_PREFIX.length, index - CONTENT_LENGTH_PREFIX.length);
				this._bodyLength = parseInt(lengthString, 10);
				this._messageBuffer = this._messageBuffer.substr(index + TWO_CRLF.length);
			}
			else
			{
				//we don't have a full header yet
				return;
			}
			//keep trying to parse until we hit one of the return statements
			//above
			this.parseMessageBuffer();
		}
		
		private function sendRequest(command:String, args:Object = null):void
		{
			if(command != COMMAND_INITIALIZE && !_receivedInitializeResponse)
			{
				throw new IllegalOperationError("Send request failed. Must wait for initialize response before sending request of type '" + command + "' to the debug adapter.");
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
			var string:String = JSON.stringify(message);
			if(_debugMode)
			{
				trace("<<< ", string);
			}
			_byteArray.clear();
			_byteArray.writeUTFBytes(string);
			var contentLength:String = _byteArray.length.toString();
			_byteArray.clear();
			_nativeProcess.standardInput.writeUTFBytes(CONTENT_LENGTH_PREFIX);
			_nativeProcess.standardInput.writeUTFBytes(contentLength);
			_nativeProcess.standardInput.writeUTFBytes(TWO_CRLF);
			_nativeProcess.standardInput.writeUTFBytes(string);
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
				if(_nativeProcess)
				{
					//the process won't exit automatically
					_nativeProcess.exit(true);
				}
				return;
			}
			_receivedInitializeResponse = true;

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

			refreshView();
		}
		
		private function parseThreadsResponse(response:Object):void
		{
			if(!response.success)
			{
				trace("debug adapter \"threads\" command not successful");
				return;
			}
			this._paused = false;
			refreshView();
			
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
				trace("debug adapter \"setbreakpoints\" command not successful");
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
			refreshView();
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
		
		private function loadVariables(scopeOrVar:BaseVariablesReference):void
		{
			var nextSeq:int = _seq + 1;
			this._variablesLookup[nextSeq] = scopeOrVar;
			this.sendRequest(COMMAND_VARIABLES,
			{
				variablesReference: scopeOrVar.variablesReference
			});
		}
		
		private function gotoStackFrame(stackFrame:StackFrame):void
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
			dispatcher.dispatchEvent(openEvent);
			
			this.sendRequest(COMMAND_SCOPES,
			{
				frameId: stackFrame.id
			});
		}

		private function stop():void
		{
			if(connectTimeout != uint.MAX_VALUE)
			{
				clearTimeout(connectTimeout);
				connectTimeout = uint.MAX_VALUE;
			}
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
				if(_nativeProcess)
				{
					//the process won't exit automatically
					_nativeProcess.exit(true);
				}
			}
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
		}

		private function play():void
		{
            if (!_receivedInitializeResponse || !_debugPanel.playButton.enabled) return;

			this.sendRequest(COMMAND_CONTINUE);
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
		}

		private function pause():void
		{
            if (!_receivedInitializeResponse || !_debugPanel.pauseButton.enabled) return;

			this.sendRequest(COMMAND_PAUSE);
		}

		private function stepOver():void
		{
            if (!_receivedInitializeResponse || !_debugPanel.stepOverButton.enabled) return;

			this.sendRequest(COMMAND_NEXT);
		}

		private function stepInto():void
		{
            if (!_receivedInitializeResponse || !_debugPanel.stepIntoButton.enabled) return;

			this.sendRequest(COMMAND_STEP_IN);
		}

		private function stepOut():void
		{
            if (!_receivedInitializeResponse || !_debugPanel.stepOutButton.enabled) return;

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
			_waitingForLaunchOrAttach = false;
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			refreshView();
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
			this.refreshView();
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
			this.refreshView();
		}
		
		private function parseInitializedEvent(event:Object):void
		{
			var hasBreakpoints:Boolean = false;
			for(var key:String in _breakpoints)
			{
				hasBreakpoints = true;
				sendSetBreakpointsRequestForPath(key);
			}
			if(!hasBreakpoints)
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
			if(output !== null)
			{
				if(category === OUTPUT_CATEGORY_STDERR)
				{
					error(output);
				}
				else
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
			refreshView();
		}
		
		private function parseTerminatedEvent(event:Object):void
		{
			this.handleDisconnectOrTerminated();
			if(_nativeProcess)
			{
				//the process won't exit automatically
				_nativeProcess.exit(true);
			}
		}
		
		private function initializeDebugViewEventHandlers(event:Event):void
		{
            _debugPanel.playButton.addEventListener(MouseEvent.CLICK, playButton_clickHandler);
			_debugPanel.pauseButton.addEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
			_debugPanel.stepOverButton.addEventListener(MouseEvent.CLICK, stepOverButton_clickHandler);
			_debugPanel.stepIntoButton.addEventListener(MouseEvent.CLICK, stepIntoButton_clickHandler);
			_debugPanel.stepOutButton.addEventListener(MouseEvent.CLICK, stepOutButton_clickHandler);
			_debugPanel.stopButton.addEventListener(MouseEvent.CLICK, stopButton_clickHandler);
			_debugPanel.addEventListener(Event.REMOVED_FROM_STAGE, debugPanel_RemovedFromStage);
			_debugPanel.addEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
			_debugPanel.addEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
		}

		private function cleanupDebugViewEventHandlers():void
		{
            _debugPanel.playButton.removeEventListener(MouseEvent.CLICK, playButton_clickHandler);
            _debugPanel.pauseButton.removeEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
            _debugPanel.stepOverButton.removeEventListener(MouseEvent.CLICK, stepOverButton_clickHandler);
            _debugPanel.stepIntoButton.removeEventListener(MouseEvent.CLICK, stepIntoButton_clickHandler);
            _debugPanel.stepOutButton.removeEventListener(MouseEvent.CLICK, stepOutButton_clickHandler);
            _debugPanel.stopButton.removeEventListener(MouseEvent.CLICK, stopButton_clickHandler);
            _debugPanel.removeEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
            _debugPanel.removeEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
            _debugPanel.removeEventListener(Event.REMOVED_FROM_STAGE, debugPanel_RemovedFromStage);
		}

		private function refreshView():void
		{
			if(!_debugPanel.parent)
			{
				return;
			}
			var launchedOrAttached:Boolean = _receivedInitializeResponse && !_waitingForLaunchOrAttach;
			_debugPanel.playButton.enabled = launchedOrAttached && _paused;
			_debugPanel.pauseButton.enabled = launchedOrAttached && !_paused;
			_debugPanel.stepOverButton.enabled = launchedOrAttached && _paused;
			_debugPanel.stepIntoButton.enabled = launchedOrAttached && _paused;
			_debugPanel.stepOutButton.enabled = launchedOrAttached && _paused;
			_debugPanel.stopButton.enabled = _receivedInitializeResponse;
			_debugPanel.stackFrames = _stackFrames;
			_debugPanel.scopesAndVars = _scopesAndVars;
		}
		
		private function sendSetBreakpointsRequestForPath(path:String):void
		{
			if(!(path in _breakpoints))
			{
				return;
			}
			var breakpoints:Array = _breakpoints[path] as Array;
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
		
		private function dispatcher_showDebugViewHandler(event:Event):void
		{
			if (!isDebugViewVisible)
            {
                dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
                initializeDebugViewEventHandlers(event);
				isDebugViewVisible = true;
            }
			else
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, this._debugPanel));
                cleanupDebugViewEventHandlers();
				isDebugViewVisible = false;
			}
		}
		
		private function stepOverExecutionHandler(event:Event):void
		{
			this.stepOver();
		}
		
		private function continueExecutionHandler(event:Event):void
		{
			this.play();
		}
		
		private function terminateExecutionHandler(event:Event):void
		{
			this.stop();
		}
		
		private function dispatcher_editorOpenHandler(event:EditorPluginEvent):void
		{
			if (event.newFile || !event.file)
			{
				return;
			}
			
			var path:String = event.file.fileBridge.nativePath;
			var breakpoints:Array = this._breakpoints[path] as Array;
			if(breakpoints)
			{
				//restore the breakpoints
				event.editor.breakpoints = breakpoints;
			}
		}
		
		private function dispatcher_closeTabHandler(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				var editor:BasicTextEditor = CloseTabEvent(event).tab as BasicTextEditor;
				this.saveEditorBreakpoints(editor);
			}
		}
		
		private function dispatcher_setDebugLineHandler(event:DebugLineEvent):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			saveEditorBreakpoints(editor);
			if(_receivedInitializeResponse)
			{
				var path:String = editor.currentFile.fileBridge.nativePath;
				sendSetBreakpointsRequestForPath(path);
			}
		}
		
		protected function dispatcher_startDebugAdapterHandler(event:DebugAdapterEvent):void
		{
			if(event.request != REQUEST_LAUNCH && event.request != REQUEST_ATTACH)
			{
				error("Unknown request to start debugger: " + event.request);
				return;
			}

			var launcher:IDebugAdapterLauncher = null;
			switch(event.adapterID)
			{
				case "swf":
				{
					launcher = new SWFDebugAdapterLauncher();
					break;
				}
				default:
				{
					error("Unknown debug adapter: " + event.adapterID);
					return;
				}
			}
			var startupInfo:NativeProcessStartupInfo = launcher.getStartupInfo(event.project);
			if(!startupInfo)
			{
				return;
			}

			this._currentProject = event.project;
			this._currentRequest = new PendingRequest(event.adapterID, event.request, event.additionalProperties);

			this._stackFrames = new ArrayCollection();
			this._scopesAndVars = new VariablesReferenceHierarchicalData();
			if(_nativeProcess)
			{
				//if we're already debugging, kill the previous process
				_nativeProcess.exit(true);
			}
			
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			_receivedInitializeResponse = false;
			_waitingForLaunchOrAttach = false;
			refreshView();

			_nativeProcess = new NativeProcess();
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_standardOutputDataHandler);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
			_nativeProcess.start(startupInfo);
			
			//connect after a delay because it's not clear when the server has
			//been started by the process
			_retryCount = 0;
			mainThreadID = -1;

			DebugHighlightManager.IS_DEBUGGER_CONNECTED = true;

            dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
            initializeDebugViewEventHandlers(event);
			isDebugViewVisible = true;
			//see above for why we call refreshView() instead of immediately
			//after connected is set to true
			refreshView();
			
			sendRequest(COMMAND_INITIALIZE,
			{
				"clientID": CLIENT_ID,
				"adapterID": this._currentRequest.adapterID
			});
		}
		
		protected function nativeProcess_standardOutputDataHandler(event:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardOutput;
			this._messageBuffer += output.readUTFBytes(output.bytesAvailable);
			this.parseMessageBuffer();
		}
		
		protected function nativeProcess_standardErrorDataHandler(event:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			error("Process error: %s", data);
		}
		
		protected function nativeProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_standardOutputDataHandler);
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
			_nativeProcess.exit();
			_nativeProcess = null;
			
			_receivedInitializeResponse = false;
			_waitingForLaunchOrAttach = false;
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			refreshView();
		}
		
		protected function dispatcher_quitHandler(event:Event):void
		{
			//force quit because we don't have time to clean up when the whole
			//app is exiting?
			if(!_nativeProcess)
			{
				return;
			}
			_nativeProcess.exit(true);
		}

		protected function dispatcher_stopDebugHandler(event:ActionScriptBuildEvent):void
		{
			this.stop();
		}
		
		protected function debugPanel_loadVariablesHandler(event:LoadVariablesEvent):void
		{
			this.loadVariables(event.scopeOrVar);
		}
		
		protected function debugPanel_gotoStackFrameHandler(event:StackFrameEvent):void
		{
			this.gotoStackFrame(event.stackFrame);
		}
		
		protected function stopButton_clickHandler(event:MouseEvent):void
		{
			this.stop();
		}
		
		protected function pauseButton_clickHandler(event:MouseEvent):void
		{
			this.pause();
		}
		
		protected function playButton_clickHandler(event:MouseEvent):void
		{
			this.play();
		}
		
		protected function stepOverButton_clickHandler(event:MouseEvent):void
		{
			this.stepOver();
		}
		
		protected function stepIntoButton_clickHandler(event:MouseEvent):void
		{
			this.stepInto();
		}
		
		protected function stepOutButton_clickHandler(event:MouseEvent):void
		{
			this.stepOut();
		}

        private function debugPanel_RemovedFromStage(event:Event):void
        {
            isDebugViewVisible = false;
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