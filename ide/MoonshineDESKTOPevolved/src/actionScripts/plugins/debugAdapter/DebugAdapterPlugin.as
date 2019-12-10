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
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.EditorPluginEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.plugins.debugAdapter.events.DebugAdapterEvent;
    import actionScripts.plugins.debugAdapter.events.LoadVariablesEvent;
    import actionScripts.plugins.debugAdapter.events.StackFrameEvent;
    import actionScripts.plugins.debugAdapter.view.DebugAdapterView;
    import actionScripts.plugins.swflauncher.SWFDebugAdapterLauncher;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.valueObjects.ConstantsCoreVO;

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.IDataInput;
    import actionScripts.debugAdapter.DebugAdapter;
    import actionScripts.plugins.chromelauncher.ChromeDebugAdapterLauncher;
	
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
			dispatcher.addEventListener(ActionScriptBuildEvent.STOP_DEBUG, dispatcher_stopDebugHandler);
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, dispatcher_stepOverExecutionHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, dispatcher_continueExecutionHandler);
			dispatcher.addEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, dispatcher_terminateExecutionHandler);
			//if you add any new listeners here, before sure that you remove
			//them in deactivate()
			
			DebugHighlightManager.init();
		}
		
		override public function deactivate():void
		{
			super.deactivate();

			dispatcher.removeEventListener(EVENT_SHOW_HIDE_DEBUG_VIEW, dispatcher_showDebugViewHandler);
			dispatcher.removeEventListener(DebugAdapterEvent.START_DEBUG_ADAPTER, dispatcher_startDebugAdapterHandler);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, dispatcher_applicationExitHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.STOP_DEBUG, dispatcher_stopDebugHandler);
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, dispatcher_editorOpenHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, dispatcher_closeTabHandler);
			dispatcher.removeEventListener(DebugLineEvent.SET_DEBUG_LINE, dispatcher_setDebugLineHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.DEBUG_STEPOVER, dispatcher_stepOverExecutionHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.CONTINUE_EXECUTION, dispatcher_continueExecutionHandler);
			dispatcher.removeEventListener(ActionScriptBuildEvent.TERMINATE_EXECUTION, dispatcher_terminateExecutionHandler);
		}
		
		private function initializeDebugViewEventHandlers(event:Event):void
		{
            _debugPanel.playButton.addEventListener(MouseEvent.CLICK, playButton_clickHandler);
			_debugPanel.pauseButton.addEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
			_debugPanel.stepOverButton.addEventListener(MouseEvent.CLICK, stepOverButton_clickHandler);
			_debugPanel.stepIntoButton.addEventListener(MouseEvent.CLICK, stepIntoButton_clickHandler);
			_debugPanel.stepOutButton.addEventListener(MouseEvent.CLICK, stepOutButton_clickHandler);
			_debugPanel.stopButton.addEventListener(MouseEvent.CLICK, stopButton_clickHandler);
			_debugPanel.addEventListener(Event.REMOVED_FROM_STAGE, debugPanel_removedFromStageHandler);
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
            _debugPanel.removeEventListener(Event.REMOVED_FROM_STAGE, debugPanel_removedFromStageHandler);
		}

		private function refreshView():void
		{
			if(!_debugPanel.parent)
			{
				return;
			}

			_debugPanel.playButton.enabled = _debugAdapter && _debugAdapter.launchedOrAttached && _debugAdapter.paused;
			_debugPanel.pauseButton.enabled = _debugAdapter && _debugAdapter.launchedOrAttached && !_debugAdapter.paused;
			_debugPanel.stepOverButton.enabled = _debugAdapter && _debugAdapter.launchedOrAttached && _debugAdapter.paused;
			_debugPanel.stepIntoButton.enabled = _debugAdapter && _debugAdapter.launchedOrAttached && _debugAdapter.paused;
			_debugPanel.stepOutButton.enabled = _debugAdapter && _debugAdapter.launchedOrAttached && _debugAdapter.paused;
			_debugPanel.stopButton.enabled = _debugAdapter != null;
			_debugPanel.stackFrames = _debugAdapter ? _debugAdapter.stackFrames : null;
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

            dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, this._debugPanel));
            initializeDebugViewEventHandlers(event);
			isDebugViewVisible = true;
			
			DebugHighlightManager.IS_DEBUGGER_CONNECTED = false;
			var debugMode:Boolean = false;
			_debugAdapter = new DebugAdapter(CLIENT_ID, CLIENT_NAME, debugMode, dispatcher,
				_nativeProcess.standardOutput, _nativeProcess, ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcess.standardInput);
			_debugAdapter.addEventListener(Event.INIT, debugAdapter_initHandler);
			_debugAdapter.addEventListener(Event.CLOSE, debugAdapter_closeHandler);
			_debugAdapter.addEventListener(Event.CHANGE, debugAdapter_changeHandler);
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
			_debugAdapter = null;
			if(_nativeProcess)
			{
				//the process won't exit automatically
				_nativeProcess.exit(true);
			}
			refreshView();
		}

		private function debugAdapter_changeHandler(event:Event):void
		{
			refreshView();
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
				//abnormally, it might not have
				dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.TERMINATE_EXECUTION));
				
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
		
		protected function dispatcher_applicationExitHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.TERMINATE_EXECUTION));
		}

        private function debugPanel_removedFromStageHandler(event:Event):void
        {
            isDebugViewVisible = false;
        }

		protected function dispatcher_stopDebugHandler(event:ActionScriptBuildEvent):void
		{
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.TERMINATE_EXECUTION));
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
		
		protected function stopButton_clickHandler(event:MouseEvent):void
		{
			dispatcher.dispatchEvent(new ActionScriptBuildEvent(ActionScriptBuildEvent.TERMINATE_EXECUTION));
		}
		
		protected function pauseButton_clickHandler(event:MouseEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.pause();
		}
		
		protected function playButton_clickHandler(event:MouseEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.resume();
		}
		
		protected function stepOverButton_clickHandler(event:MouseEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepOver();
		}
		
		protected function stepIntoButton_clickHandler(event:MouseEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepInto();
		}
		
		protected function stepOutButton_clickHandler(event:MouseEvent):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepOut();
		}
		
		private function dispatcher_stepOverExecutionHandler(event:Event):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.stepOver();
		}
		
		private function dispatcher_continueExecutionHandler(event:Event):void
		{
			if(!_debugAdapter || !_debugAdapter.initialized)
			{
				return;
			}
			_debugAdapter.resume();
		}
		
		private function dispatcher_terminateExecutionHandler(event:Event):void
		{
			if(!_debugAdapter)
			{
				return;
			}
			//don't call stop() anywhere else except here
			_debugAdapter.stop();
		}
    }
}