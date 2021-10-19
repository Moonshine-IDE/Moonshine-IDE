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
	
	import actionScripts.debugAdapter.DebugAdapter;
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.DebugActionEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.plugins.chromelauncher.ChromeDebugAdapterLauncher;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import actionScripts.plugins.debugAdapter.events.LoadVariablesEvent;
    import actionScripts.plugins.debugAdapter.events.StackFrameEvent;
    import actionScripts.plugins.debugAdapter.view.DebugAdapterView;
    import actionScripts.plugins.firefoxlauncher.FirefoxDebugAdapterLauncher;
    import actionScripts.plugins.hashlinklauncher.HashLinkDebugAdapterLauncher;
    import actionScripts.plugins.hxcpplauncher.HxCppDebugAdapterLauncher;
    import actionScripts.plugins.swflauncher.SWFDebugAdapterLauncher;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class DebugAdapterPlugin extends PluginBase
	{
		public static const EVENT_SHOW_HIDE_DEBUG_VIEW:String = "EVENT_SHOW_HIDE_DEBUG_VIEW";
		private static const MAX_RETRY_COUNT:int = 5;
		private static const CLIENT_ID:String = "moonshine";
		private static const CLIENT_NAME:String = "Moonshine IDE";
		
		override public function get name():String 			{ return "Debug Adapter Protocol Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String 	{ return "Debugs ActionScript and MXML projects with the Debug Adapter Protocol."; }
		
		private var _debugPanel:DebugAdapterView;
		private var _nativeProcess:NativeProcess;
		private var _debugAdapter:DebugAdapter;
		private var isDebugViewVisible:Boolean;
		private var _calledStop:Boolean = false;
		private var _breakpoints:Object = {};
		
		public function DebugAdapterPlugin()
		{
		}
		
		override public function activate():void
		{
			super.activate();
			
			this._debugPanel = new DebugAdapterView();

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
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_PAUSE, debugPanel_debugPauseHandler);
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_RESUME, debugPanel_debugResumeHandler);
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_STEP_INTO, debugPanel_debugStepIntoHandler);
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_STEP_OUT, debugPanel_debugStepOutHandler);
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_STEP_OVER, debugPanel_debugStepOverHandler);
			_debugPanel.addEventListener(DebugActionEvent.DEBUG_STOP, debugPanel_debugStopHandler);
			_debugPanel.addEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
			_debugPanel.addEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
			_debugPanel.addEventListener(Event.REMOVED_FROM_STAGE, debugPanel_removedFromStageHandler);
		}

		private function cleanupDebugViewEventHandlers():void
		{
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_PAUSE, debugPanel_debugPauseHandler);
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_RESUME, debugPanel_debugResumeHandler);
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_STEP_INTO, debugPanel_debugStepIntoHandler);
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_STEP_OUT, debugPanel_debugStepOutHandler);
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_STEP_OVER, debugPanel_debugStepOverHandler);
			_debugPanel.removeEventListener(DebugActionEvent.DEBUG_STOP, debugPanel_debugStopHandler);
			_debugPanel.removeEventListener(LoadVariablesEvent.LOAD_VARIABLES, debugPanel_loadVariablesHandler);
			_debugPanel.removeEventListener(StackFrameEvent.GOTO_STACK_FRAME, debugPanel_gotoStackFrameHandler);
			_debugPanel.removeEventListener(Event.REMOVED_FROM_STAGE, debugPanel_removedFromStageHandler);
		}

		private function refreshView():void
		{
			if(!_debugPanel.parent)
			{
				return;
			}

			_debugPanel.active = _debugAdapter != null;
			_debugPanel.pausedThreads = _debugAdapter ? _debugAdapter.pausedThreads : null;
			_debugPanel.threadsAndStackFrames = _debugAdapter ? _debugAdapter.threadsAndStackFrames : null;
			_debugPanel.scopesAndVars = _debugAdapter ? _debugAdapter.scopesAndVars : null;
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

		private function pauseDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.pause(threadId);
		}

		private function resumeDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.resume(threadId);
		}

		private function stepOverDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepOver(threadId);
		}

		private function stepOutDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepOut(threadId);
		}

		private function stepIntoDebugAdapter(threadId:int):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepInto(threadId);
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
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
				initializeDebugViewEventHandlers(event);
				isDebugViewVisible = true;
			}
			
			_calledStop = false;
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, event.project.projectName));

			var debugMode:Boolean = false;
			_debugAdapter = new DebugAdapter(CLIENT_ID, CLIENT_NAME, debugMode, dispatcher,
				_nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_debugAdapter.addEventListener(Event.INIT, debugAdapter_initHandler);
			_debugAdapter.addEventListener(Event.CLOSE, debugAdapter_closeHandler);
			_debugAdapter.addEventListener(Event.CHANGE, debugAdapter_changeHandler);
			_debugAdapter.addEventListener(Event.SUSPEND, debugAdapter_suspendHandler);
			_debugAdapter.start(event.adapterID, event.request, event.additionalProperties);

			refreshView();
		}

		private function debugAdapter_initHandler(event:Event):void
		{
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = true;
			for(var path:String in _breakpoints)
			{
				_debugAdapter.setBreakpoints(path, _breakpoints[path] as Array);
			}
		}

		private function debugAdapter_closeHandler(event:Event):void
		{
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
			_debugAdapter = null;
			if(_nativeProcess)
			{
				//the process won't exit automatically
				_nativeProcess.exit(true);
			}
			refreshView();
			if(!_calledStop)
			{
				//dispatch the event instead of calling stopDebugAdapter()
				//directly because other parts of the UI need to know that
				//debug/run has stopped
				dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
			}
		}

		private function debugAdapter_changeHandler(event:Event):void
		{
			refreshView();
		}

		private function debugAdapter_suspendHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, this._debugPanel));
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
				if(!(path in _breakpoints))
				{
					return;
				}
				var breakpoints:Array = _breakpoints[path] as Array;
				_debugAdapter.setBreakpoints(path, breakpoints);
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
			var breakpoints:Array = this._breakpoints[path] as Array;
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
				this.saveEditorBreakpoints(editor);
			}
		}
		
		protected function dispatcher_applicationExitHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP));
		}

        private function debugPanel_removedFromStageHandler(event:Event):void
        {
            isDebugViewVisible = false;
        }
		
		protected function debugPanel_loadVariablesHandler(event:LoadVariablesEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.loadVariables(event.scopeOrVar);
		}
		
		protected function debugPanel_gotoStackFrameHandler(event:StackFrameEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.gotoStackFrame(event.stackFrame);
		}
		
		protected function debugPanel_debugStopHandler(event:DebugActionEvent):void
		{
			dispatcher.dispatchEvent(new DebugActionEvent(DebugActionEvent.DEBUG_STOP, event.threadId));
		}
		
		protected function debugPanel_debugResumeHandler(event:DebugActionEvent):void
		{
			this.resumeDebugAdapter(event.threadId);
		}
		
		protected function debugPanel_debugPauseHandler(event:DebugActionEvent):void
		{
			this.pauseDebugAdapter(event.threadId);
		}
		
		protected function debugPanel_debugStepOverHandler(event:DebugActionEvent):void
		{
			this.stepOverDebugAdapter(event.threadId);
		}
		
		protected function debugPanel_debugStepIntoHandler(event:DebugActionEvent):void
		{
			this.stepIntoDebugAdapter(event.threadId);
		}
		
		protected function debugPanel_debugStepOutHandler(event:DebugActionEvent):void
		{
			this.stepOutDebugAdapter(event.threadId);
		}
		
		private function dispatcher_debugStepOverHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			this.stepOverDebugAdapter(threadId);
		}
		
		private function dispatcher_debugStepOutHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			this.stepOutDebugAdapter(threadId);
		}
		
		private function dispatcher_debugStepIntoHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			this.stepIntoDebugAdapter(threadId);
		}
		
		private function dispatcher_debugResumeHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			this.resumeDebugAdapter(threadId);
		}
		
		private function dispatcher_debugPauseHandler(event:Event):void
		{
			var threadId:int = -1;
			if(event is DebugActionEvent)
			{
				threadId = DebugActionEvent(event).threadId;
			}
			this.pauseDebugAdapter(threadId);
		}

		protected function dispatcher_debugStopHandler(event:Event):void
		{
			if(!_debugAdapter)
			{
				return;
			}
			//don't call stop() anywhere else in this class. we call it here
			//and we use this flag to determine if we must notify other parts
			//of the app that the debugging has stopped
			_calledStop = true;
			_debugAdapter.stop();
		}
    }
}