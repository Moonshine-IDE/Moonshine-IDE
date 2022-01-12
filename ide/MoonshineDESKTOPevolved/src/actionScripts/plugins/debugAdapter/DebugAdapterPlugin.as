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
    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.IDataInput;
	
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.DebugActionEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.plugins.chromelauncher.ChromeDebugAdapterLauncher;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import actionScripts.plugins.firefoxlauncher.FirefoxDebugAdapterLauncher;
    import actionScripts.plugins.hashlinklauncher.HashLinkDebugAdapterLauncher;
    import actionScripts.plugins.hxcpplauncher.HxCppDebugAdapterLauncher;
    import actionScripts.plugins.swflauncher.SWFDebugAdapterLauncher;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import moonshine.dsp.DebugAdapterClient;
    import feathers.data.ArrayCollection;
    import actionScripts.events.OpenFileEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.ui.FeathersUIWrapper;
    import moonshine.plugin.debugadapter.view.DebugAdapterView;
	import moonshine.plugin.debugadapter.data.CallStackHierarchicalCollection;
	import moonshine.plugin.debugadapter.data.VariablesReferenceHierarchicalCollection;
	import moonshine.plugin.debugadapter.events.DebugAdapterViewThreadEvent;
	import moonshine.plugin.debugadapter.events.DebugAdapterViewLoadVariablesEvent;
	import moonshine.plugin.debugadapter.events.DebugAdapterViewStackFrameEvent;

    public class DebugAdapterPlugin extends PluginBase
	{
		public static const EVENT_SHOW_HIDE_DEBUG_VIEW:String = "EVENT_SHOW_HIDE_DEBUG_VIEW";
		private static const MAX_RETRY_COUNT:int = 5;
		private static const CLIENT_ID:String = "moonshine";
		private static const CLIENT_NAME:String = "Moonshine IDE";
		
		override public function get name():String 			{ return "Debug Adapter Protocol Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String 	{ return "Debugs ActionScript and MXML projects with the Debug Adapter Protocol."; }
		
		private var debugView:DebugAdapterView;
		private var debugViewWrapper:DebugAdapterViewWrapper;
		private var _nativeProcess:NativeProcess;
		private var _debugAdapter:DebugAdapterClient;
		private var _pendingAdapterID:String;
		private var _pendingRequest:String;
		private var _pendingAdditionalProperties:Object;
		private var isDebugViewVisible:Boolean;
		private var _calledDisconnect:Boolean = false;
		private var _breakpoints:Object = {};

		private var _threadsAndStackFrames:CallStackHierarchicalCollection = new CallStackHierarchicalCollection();
		private var _scopesAndVars:VariablesReferenceHierarchicalCollection = new VariablesReferenceHierarchicalCollection();
		private var _pausedThreads:ArrayCollection = new ArrayCollection();

		private var _supportsConfigurationDoneRequest:Boolean = false;
		private var _receivedInitializeResponse:Boolean = false;
		private var _receivedInitializedEvent:Boolean = false;
		
		public function DebugAdapterPlugin()
		{
			debugView = new DebugAdapterView();
			debugViewWrapper = new DebugAdapterViewWrapper(debugView);
			debugViewWrapper.percentWidth = 100;
			debugViewWrapper.percentHeight = 100;
			debugViewWrapper.minWidth = 0;
			debugViewWrapper.minHeight = 0;
		}
		
		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
			dispatcher.addEventListener(DebugAdapterEvent.START_DEBUG_ADAPTER, dispatcher_startDebugAdapterHandler);
			dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_applicationExitHandler);
			dispatcher.addEventListener(AddTabEvent.EVENT_ADD_TAB, dispatcher_addTabHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_STOP, dispatcher_debugStopHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_STEP_OVER, dispatcher_debugStepOverHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_STEP_INTO, dispatcher_debugStepIntoHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_STEP_OUT, dispatcher_debugStepOutHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_RESUME, dispatcher_debugResumeHandler);
			dispatcher.addEventListener(DebugActionEvent.DEBUG_PAUSE, dispatcher_debugPauseHandler);
			//if you add any new listeners here, before sure that you remove
			//them in deactivate()
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
			dispatcher.removeEventListener(DebugAdapterEvent.START_DEBUG_ADAPTER, dispatcher_startDebugAdapterHandler);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_applicationExitHandler);
			dispatcher.removeEventListener(AddTabEvent.EVENT_ADD_TAB, dispatcher_addTabHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.removeEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STOP, dispatcher_debugStopHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STEP_OVER, dispatcher_debugStepOverHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STEP_INTO, dispatcher_debugStepIntoHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STEP_OUT, dispatcher_debugStepOutHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_RESUME, dispatcher_debugResumeHandler);
			dispatcher.removeEventListener(DebugActionEvent.DEBUG_PAUSE, dispatcher_debugPauseHandler);
		}
		
		private function initializeDebugViewEventHandlers(event:Event):void
		{
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_PAUSE, debugView_debugPauseHandler);
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_RESUME, debugView_debugResumeHandler);
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_INTO, debugView_debugStepIntoHandler);
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_OUT, debugView_debugStepOutHandler);
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_OVER, debugView_debugStepOverHandler);
			debugView.addEventListener(DebugAdapterViewThreadEvent.DEBUG_STOP, debugView_debugStopHandler);
			debugView.addEventListener(DebugAdapterViewLoadVariablesEvent.LOAD_VARIABLES, debugView_loadVariablesHandler);
			debugView.addEventListener(DebugAdapterViewStackFrameEvent.GOTO_STACK_FRAME, debugView_gotoStackFrameHandler);
			debugView.addEventListener(Event.REMOVED_FROM_STAGE, debugView_removedFromStageHandler);
		}

		private function cleanupDebugViewEventHandlers():void
		{
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_PAUSE, debugView_debugPauseHandler);
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_RESUME, debugView_debugResumeHandler);
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_INTO, debugView_debugStepIntoHandler);
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_OUT, debugView_debugStepOutHandler);
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_STEP_OVER, debugView_debugStepOverHandler);
			debugView.removeEventListener(DebugAdapterViewThreadEvent.DEBUG_STOP, debugView_debugStopHandler);
			debugView.removeEventListener(DebugAdapterViewLoadVariablesEvent.LOAD_VARIABLES, debugView_loadVariablesHandler);
			debugView.removeEventListener(DebugAdapterViewStackFrameEvent.GOTO_STACK_FRAME, debugView_gotoStackFrameHandler);
			debugView.removeEventListener(Event.REMOVED_FROM_STAGE, debugView_removedFromStageHandler);
		}

		private function refreshView():void
		{
			if(!debugViewWrapper.parent)
			{
				return;
			}

			debugView.active = _debugAdapter != null;
			debugView.pausedThreads = _debugAdapter ? _pausedThreads : null;
			debugView.threadsAndStackFrames = _debugAdapter ? _threadsAndStackFrames : null;
			debugView.scopesAndVariables = _debugAdapter ? _scopesAndVars : null;
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
			
			_breakpoints[path] = editor.getEditorComponent().breakpoints;
		}

		private function pauseDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			//it might have changed, if the original was -1
			threadId = thread.id;
			_debugAdapter.pauseThread({
				threadId: threadId
			}, function():void {});
		}

		private function resumeDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			//it might have changed, if the original was -1
			threadId = thread.id;
			_debugAdapter.continueThread({
				threadId: threadId
			}, function(body:Object):void
			{
				handleContinue(threadId);
			});
		}

		private function stepOverDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			_debugAdapter.next({
				threadId: thread.id
			}, function():void {});
		}

		private function stepOutDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			//it might have changed, if the original was -1
			threadId = thread.id;
			_debugAdapter.stepOut({
				threadId: threadId
			}, function():void {});
		}

		private function stepIntoDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			//it might have changed, if the original was -1
			threadId = thread.id;
			_debugAdapter.stepIn({
				threadId: threadId
			}, function():void {});
		}
		
		private function dispatcher_showDebugViewHandler(event:Event):void
		{
			if (!isDebugViewVisible)
            {
                dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, debugViewWrapper));
                initializeDebugViewEventHandlers(event);
				isDebugViewVisible = true;
            }
			else
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.REMOVE_VIEW_TO_PROJECT_PANEL, debugViewWrapper));
                cleanupDebugViewEventHandlers();
				isDebugViewVisible = false;
			}
		}
		
		protected function dispatcher_startDebugAdapterHandler(event:DebugAdapterEvent):void
		{
			var launcher:IDebugAdapterLauncher = null;
			print("Launching application using adapter: " + event.adapterID);
			switch(event.adapterID)
			{
				case "swf":
				{
					launcher = new SWFDebugAdapterLauncher();
					break;
				}
				case "chrome":
				{
					launcher = new ChromeDebugAdapterLauncher();
					break;
				}
				case "firefox":
				{
					launcher = new FirefoxDebugAdapterLauncher();
					break;
				}
				case "hl":
				{
					launcher = new HashLinkDebugAdapterLauncher();
					break;
				}
				case "hxcpp":
				{
					launcher = new HxCppDebugAdapterLauncher();
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
			
			if(_nativeProcess)
			{
				//if we're already debugging, kill the previous process
				_nativeProcess.exit(true);
			}

			_nativeProcess = new NativeProcess();
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
			_nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
			_nativeProcess.start(startupInfo);

			if(!event.additionalProperties || !event.additionalProperties.noDebug)
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, debugViewWrapper));
				initializeDebugViewEventHandlers(event);
				isDebugViewVisible = true;
			}
			
			_threadsAndStackFrames = new CallStackHierarchicalCollection();
			_scopesAndVars = new VariablesReferenceHierarchicalCollection();
			_pausedThreads = new ArrayCollection();
			_calledDisconnect = false;
			_receivedInitializeResponse = false;
			_receivedInitializedEvent = false;
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, event.project.projectName));

			_pendingRequest = event.request;
			_pendingAdditionalProperties = event.additionalProperties;
			var debugMode:Boolean = false;
			_debugAdapter = new DebugAdapterClient(_nativeProcess.standardOutput, _nativeProcess,
				ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_debugAdapter.debugMode = debugMode;
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_OUTPUT, debugAdapter_onOutputEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_INITIALIZED, debugAdapter_onInitializedEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_TERMINATED, debugAdapter_onTerminatedEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_STOPPED, debugAdapter_onStoppedEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_CONTINUED, debugAdapter_onContinuedEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_THREAD, debugAdapter_onThreadEvent);
			_debugAdapter.addProtocolEventListener(DebugAdapterClient.EVENT_BREAKPOINT, debugAdapter_onBreakpointEvent);
			_debugAdapter.initialize({
				clientID: CLIENT_ID,
				clientName: CLIENT_NAME,
				adapterID: event.adapterID,
				pathFormat: "path",
				linesStartAt1: true,
				columnsStartAt1: true,
				supportsVariableType: false,
				supportsVariablePaging: false,
				supportsRunInTerminalRequest: false,
				supportsMemoryReferences: false,
				locale: "en-us"

			}, debugAdapter_onInitializeResponse);

			refreshView();
		}

		private function setBreakpointsForPath(path:String):void
		{
			if(!(path in _breakpoints))
			{
				return;
			}
			var breakpointsForPath:Array = (_breakpoints[path] as Array).map(function(item:int, index:int, source:Array):Object
			{
				//the debugger expects breakpoints to start at line 1
				//but moonshine stores breakpoints from line 0
				return { line: item + 1 };
			});
			_debugAdapter.setBreakpoints({
				source: { path: path },
				breakpoints: breakpointsForPath
			}, debugAdapter_onSetBreakpointsResponse);
		}

		private function handlePostInit():void
		{
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = true;
			for(var path:String in _breakpoints)
			{
				setBreakpointsForPath(path);
			}

			if(_supportsConfigurationDoneRequest)
			{
				_debugAdapter.configurationDone({}, debugAdapter_onConfigurationDoneResponse);
			}
			else
			{
				refreshView();
				_debugAdapter.threads({}, debugAdapter_onThreadsResponse);
			}
		}

		private function handleContinue(threadId:int):void
		{
			var thread:Object = findThread(threadId);
			if(!thread)
			{
				return;
			}
			_pausedThreads.remove(thread.id);
			
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
			
			//we're no longer paused, so clear these until we pause again
			_threadsAndStackFrames.setStackFramesForThread([], thread);
			_scopesAndVars.removeAll();
			refreshView();
		}

		private function attachOrLaunch():void
		{
			var request:String = _pendingRequest;
			var adapterID:String = _pendingAdapterID;
			var additionalProperties:Object = _pendingAdditionalProperties;
			_pendingRequest = null;
			_pendingAdapterID = null;
			_pendingAdditionalProperties = null;
			switch(request) {
				case "attach":
					_debugAdapter.attach(additionalProperties ? additionalProperties : {}, 
						function():void
						{
							refreshView();
						});
					break;
				case "launch":
					_debugAdapter.launch(additionalProperties ? additionalProperties : {},
						function():void
						{
							refreshView();
						});
					break;
				default:
					error("Unknown request: " + request);
					return;
			}

		}
		
		private function variables(scopeOrVar:Object):void
		{
			_debugAdapter.variables({
				variablesReference: scopeOrVar.variablesReference
			}, function(body:Object):void
			{
				if("variables" in body)
				{
					var variables:Array = body.variables as Array;
					_scopesAndVars.setVariablesForScopeOrVar(variables, scopeOrVar);
				}
			});
		}
		
		private function scopes(stackFrame:Object):void
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
			var file:FileLocation = new FileLocation(filePath);
			//make sure that we don't have any differences in case
			//otherwise, a duplicate editor might be opened!
			file.fileBridge.canonicalize();
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.TRACE_LINE,
				[file], line);
			openEvent.atChar = character;
			dispatcher.dispatchEvent(openEvent);
			
			_debugAdapter.scopes(
			{
				frameId: stackFrame.id
			}, function(body:Object):void {
				if("scopes" in body)
				{
					var scopes:Array = body.scopes as Array;
					_scopesAndVars.setScopes(scopes);
					if(scopes.length > 0)
					{
						variables(scopes[0]);
					}
				}
			});
		}

		private function stackTrace(threadId:int):void
		{
			var thread:Object = findThread(threadId);
			if(thread == null)
			{
				return;
			}
			//it might have changed, if the original was -1
			threadId = thread.id;
			_debugAdapter.stackTrace({
				threadId: threadId,
				startFrame: 0,
				//it should be possible to omit levels or set it to 0, but the
				//HashLink debugger incorrectly requires it
				//https://github.com/vshaxe/hashlink-debugger/issues/74
				levels: 10000
			}, function debugAdapter_onStackTraceResponse(body:Object):void
			{
				if("stackFrames" in body)
				{
					var stackFrames:Array = body.stackFrames as Array;
					_threadsAndStackFrames.setStackFramesForThread(stackFrames, thread);
					refreshView();
					if(stackFrames.length > 0)
					{
						scopes(stackFrames[0]);
					}
				}
			});
		}

		private function findThread(threadId:int):Object
		{
			var threadCount:int = _threadsAndStackFrames.getLength();
			for(var i:int = 0; i < threadCount; i++)
			{
				var thread:Object = _threadsAndStackFrames.get([i]);
				if(threadId == thread.id || threadId == -1)
				{
					return thread;
				}
			}
			return null;
		}

		private function debugAdapter_onOutputEvent(event:Object):void
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
				if(category == DebugAdapterClient.OUTPUT_CATEGORY_STDERR)
				{
					error(output);
				}
				else if(category != DebugAdapterClient.OUTPUT_CATEGORY_TELEMETRY)
				{
					print(output);
				}
			}
		}

		private function debugAdapter_onInitializedEvent(event:Object):void
		{
			_receivedInitializedEvent = true;
			if(!_receivedInitializeResponse)
			{
				//hxcpp-debug-server (and maybe other debug adapters too?) sends
				//initialized before the initialize response, which is against
				//spec. normally, we'd send some requests after this event, but
				//instead, we'll wait until after the initialize response.
				return;
			}
			handlePostInit();
		}

		private function debugAdapter_onInitializeResponse(capabilities:Object):void
		{
			_supportsConfigurationDoneRequest = capabilities.supportsConfigurationDoneRequest;
			_receivedInitializeResponse = true;
			if(_receivedInitializedEvent) {
				handlePostInit();
			}
			attachOrLaunch();
		}

		private function debugAdapter_onConfigurationDoneResponse():void
		{
			refreshView();
			_debugAdapter.threads({}, debugAdapter_onThreadsResponse);
		}

		private function debugAdapter_onSetBreakpointsResponse(body:Object):void
		{
			var threadCount:int = _threadsAndStackFrames.getLength();
			if(threadCount == 0)
			{
				_debugAdapter.threads({}, debugAdapter_onThreadsResponse);
			}
		}

		private function debugAdapter_onThreadsResponse(body:Object):void
		{
			if("threads" in body)
			{
				var resultThreads:Array = [];
				var threads:Array = body.threads as Array;
				_threadsAndStackFrames.setThreads(threads);
				var threadCount:int = threads.length;
				for(var i:int = 0; i < threadCount; i++)
				{
					var thread:Object = threads[i];
					if(_pausedThreads.contains(thread.id))
					{
						stackTrace(thread.id);
					}
				}
			}
		}

		private function handleDisconnectOrTerminated():void
		{
			_debugAdapter = null;
			_calledDisconnect = false;
			_receivedInitializedEvent = false;
			_receivedInitializeResponse = false;
			_scopesAndVars.removeAll();
			_threadsAndStackFrames.removeAll();
			_pausedThreads.removeAll();
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
			if(_nativeProcess)
			{
				//the process won't exit automatically
				_nativeProcess.exit(true);
			}
			refreshView();
			if(!_calledDisconnect)
			{
				//dispatch the event instead of calling disconnect() directly
				//on the debug adapter because other parts of the UI need to
				//know that debug/run has stopped
				dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
			}
		}

		private function debugAdapter_onDisconnectResponse():void
		{
			handleDisconnectOrTerminated();
		}

		private function debugAdapter_onTerminatedEvent(event:Object):void
		{
			handleDisconnectOrTerminated();
		}

		private function debugAdapter_onStoppedEvent(event:Object):void
		{
			var body:Object = event.body;
			var threadId:int = -1;
			if("threadId" in body)
			{
				threadId = body.threadId;
			}
			var thread:Object = findThread(threadId);
			if(thread != null)
			{
				_pausedThreads.add(thread.id);
				stackTrace(thread.id);
			}

			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, debugViewWrapper));
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, debugViewWrapper));
		}

		private function debugAdapter_onContinuedEvent(event:Object):void
		{
			//but if we are paused, we should update our state
			var body:Object = event.body;
			var threadId:int = -1;
			if("threadId" in body)
			{
				threadId = body.threadId;
			}
			handleContinue(threadId);
		}

		private function debugAdapter_onThreadEvent(event:Object):void
		{
			if(!_receivedInitializedEvent)
			{
				//not ready to request threads, so ignore for now
				return;
			}
			_debugAdapter.threads({}, debugAdapter_onThreadsResponse);
		}

		private function debugAdapter_onBreakpointEvent(event:Object):void
		{
			//we don't currently indicate if a breakpoint is verified or
			//not so, we can ignore this one.
		}

		private function debugAdapter_onLoadedSourceEvent(event:Object):void
		{
			//we don't currently do anything with this event.
		}
		
		protected function nativeProcess_standardErrorDataHandler(event:ProgressEvent):void
		{
			var output:IDataInput = _nativeProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);

			error("Process error: %s", data);
		}
		
		protected function nativeProcess_exitHandler(event:NativeProcessExitEvent):void
		{
			if(_debugAdapter)
			{
				//this should have already happened, but if the process exits
				//abnormally, it might not have yet
				dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
				
				warning("Debug adapter exited unexpectedly.");
			}

			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorDataHandler);
			_nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exitHandler);
			_nativeProcess.exit();
			_nativeProcess = null;
		}
		
		private function dispatcher_setDebugLineHandler(event:DebugLineEvent):void
		{
			var editor:BasicTextEditor = model.activeEditor as BasicTextEditor;
			saveEditorBreakpoints(editor);

			if(_debugAdapter && _debugAdapter.initialized)
			{
				var path:String = editor.currentFile.fileBridge.nativePath;
				setBreakpointsForPath(path);
			}
		}
		
		private function dispatcher_addTabHandler(event:AddTabEvent):void
		{
			var editor:BasicTextEditor = event.tab as BasicTextEditor;
			if (!editor || !editor.currentFile)
			{
				return;
			}
			
			var path:String = editor.currentFile.fileBridge.nativePath;
			var breakpoints:Array = _breakpoints[path] as Array;
			if(breakpoints)
			{
				//restore the breakpoints
				editor.getEditorComponent().breakpoints = breakpoints;
			}
		}
		
		private function dispatcher_closeTabHandler(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				var editor:BasicTextEditor = CloseTabEvent(event).tab as BasicTextEditor;
				saveEditorBreakpoints(editor);
			}
		}
		
		protected function dispatcher_applicationExitHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
		}

        private function debugView_removedFromStageHandler(event:Event):void
        {
            isDebugViewVisible = false;
        }
		
		protected function debugView_loadVariablesHandler(event:DebugAdapterViewLoadVariablesEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			variables(event.scopeOrVar);
		}
		
		protected function debugView_gotoStackFrameHandler(event:DebugAdapterViewStackFrameEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			scopes(event.stackFrame);
		}
		
		protected function debugView_debugStopHandler(event:DebugAdapterViewThreadEvent):void
		{
			dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP, event.threadId));
		}
		
		protected function debugView_debugResumeHandler(event:DebugAdapterViewThreadEvent):void
		{
			resumeDebugAdapter(event.threadId);
		}
		
		protected function debugView_debugPauseHandler(event:DebugAdapterViewThreadEvent):void
		{
			pauseDebugAdapter(event.threadId);
		}
		
		protected function debugView_debugStepOverHandler(event:DebugAdapterViewThreadEvent):void
		{
			stepOverDebugAdapter(event.threadId);
		}
		
		protected function debugView_debugStepIntoHandler(event:DebugAdapterViewThreadEvent):void
		{
			stepIntoDebugAdapter(event.threadId);
		}
		
		protected function debugView_debugStepOutHandler(event:DebugAdapterViewThreadEvent):void
		{
			stepOutDebugAdapter(event.threadId);
		}
		
		private function dispatcher_debugStepOverHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			stepOverDebugAdapter(threadId);
		}
		
		private function dispatcher_debugStepOutHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			stepOutDebugAdapter(threadId);
		}
		
		private function dispatcher_debugStepIntoHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			stepIntoDebugAdapter(threadId);
		}
		
		private function dispatcher_debugResumeHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			resumeDebugAdapter(threadId);
		}
		
		private function dispatcher_debugPauseHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			pauseDebugAdapter(threadId);
		}

		protected function dispatcher_debugStopHandler(event:Event):void
		{
			if(!_debugAdapter)
			{
				return;
			}
			//don't call disconnect() anywhere else in this class. we call it
			//here and we use this flag to determine if we must notify other
			//parts of the app that the debugging has stopped
			_calledDisconnect = true;
			_debugAdapter.disconnect({}, debugAdapter_onDisconnectResponse);
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_FINISH, -1, false));
		}
    }
}

import actionScripts.interfaces.IViewWithTitle;
import actionScripts.ui.FeathersUIWrapper;

import moonshine.plugin.debugadapter.view.DebugAdapterView;

class DebugAdapterViewWrapper extends FeathersUIWrapper implements IViewWithTitle {
	public function DebugAdapterViewWrapper(feathersUIControl:DebugAdapterView)
	{
		super(feathersUIControl);
	}

	public function get title():String {
		return DebugAdapterView(feathersUIControl).title;
	}

	override public function get className():String
	{
		//className may be used by LayoutModifier
		return "DebugAdapterView";
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}