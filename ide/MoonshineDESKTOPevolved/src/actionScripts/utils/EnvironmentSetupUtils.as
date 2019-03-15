package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class EnvironmentSetupUtils
	{
		private static var instance:EnvironmentSetupUtils;
		
		private var model:IDEModel = IDEModel.getInstance();
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var isErrorClose:Boolean;
		private var watchTimer:Timer;
		private var windowsBatchFile:File;
		private var externalCallCompletionHandler:Function;
		private var executeWithCommands:Array;
		
		public static function getInstance():EnvironmentSetupUtils
		{	
			if (!instance) instance = new EnvironmentSetupUtils();
			return instance;
		}
		
		public function updateToCurrentEnvironmentVariable():void
		{
			// don't execute in a race condition
			if (watchTimer && watchTimer.running) return;
			if (!watchTimer)
			{
				watchTimer = new Timer(1000, 1);
				watchTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onWatchTimerCompletes);
				watchTimer.start();
			}
			
			/*
			* @local
			*/
			function onWatchTimerCompletes(event:TimerEvent):void
			{
				watchTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onWatchTimerCompletes);
				watchTimer.stop();
				watchTimer = null;
				
				cleanUp();
				execute();
			}
		}
		
		public function getCommandPreparedToOSXEnvironment(completion:Function):void
		{
			externalCallCompletionHandler = completion;
			execute();
		}
		
		public function getBatchFilePathToWindowsEnvironment(completion:Function, withCommands:Array=null):void
		{
			cleanUp();
			externalCallCompletionHandler = completion;
			executeWithCommands = withCommands;
			execute();
		}
		
		private function cleanUp():void
		{
			externalCallCompletionHandler = null;
			executeWithCommands = null;
		}
		
		private function execute():void
		{
			if (ConstantsCoreVO.IS_MACOS) executeOSX();
			else executeWindows();
		}
		
		private function executeWindows():void
		{
			var setCommand:String = "@echo off\n";
			var isValidToExecute:Boolean;
			var setPathCommand:String = "set PATH=";
			
			if (UtilsCore.isJavaForTypeaheadAvailable())
			{
				setCommand += "set JAVA_HOME="+ model.javaPathForTypeAhead.fileBridge.nativePath +"\n"; 
				setPathCommand += "%JAVA_HOME%\\bin;";
				isValidToExecute = true;
			}
			if (UtilsCore.isAntAvailable())
			{
				setCommand += "set ANT_HOME="+ model.antHomePath.fileBridge.nativePath +"\n";
				setPathCommand += "%ANT_HOME%\\bin;";
				isValidToExecute = true;
			}
			if (UtilsCore.isDefaultSDKAvailable())
			{
				setCommand += "set FLEX_HOME="+ model.defaultSDK.fileBridge.nativePath +"\n";
				setPathCommand += "%FLEX_HOME%;";
				isValidToExecute = true;
			}
			
			// do not proceed if no path to set
			if (!isValidToExecute)
			{
				if (externalCallCompletionHandler != null) externalCallCompletionHandler(null);
				return;
			}
			
			setCommand += setPathCommand + "%PATH%";
			//  + (ConstantsCoreVO.IS_MACOS ? "; echo $JAVA_HOME" : "& echo !JAVA_HOME!")
			// TODO:: TEST LAST COMMAND to REMOVE
			
			windowsBatchFile = File.applicationStorageDirectory.resolvePath("setLocalEnvironment.bat");
			FileUtils.writeToFileAsync(windowsBatchFile, setCommand + (executeWithCommands ? "\n"+ executeWithCommands.join("\n") : ''), onBatchFileWriteComplete, onBatchFileWriteError);
		}
		
		private function executeOSX():void
		{
			var setCommand:String = "";
			var setPathCommand:String = "export PATH=";
			var isValidToExecute:Boolean;
			
			if (UtilsCore.isJavaForTypeaheadAvailable())
			{
				setCommand = "export JAVA_HOME=\""+ model.javaPathForTypeAhead.fileBridge.nativePath +"\"; ";
				setPathCommand += "$JAVA_HOME/bin:";
				isValidToExecute = true;
			}
			if (UtilsCore.isAntAvailable())
			{
				setCommand = "export ANT_HOME=\""+ model.antHomePath.fileBridge.nativePath +"\"; ";
				setPathCommand += "$ANT_HOME/bin:";
				isValidToExecute = true;
			}
			if (UtilsCore.isDefaultSDKAvailable())
			{
				setCommand = "export FLEX_HOME=\""+ model.defaultSDK.fileBridge.nativePath +"\"; ";
				setPathCommand += "$FLEX_HOME/bin:";
				isValidToExecute = true;
			}
			
			// do not proceed if no path to set
			if (!isValidToExecute)
			{
				if (externalCallCompletionHandler != null) externalCallCompletionHandler(null);
				return;
			}
			
			setCommand += setPathCommand +"$PATH";
			//  + (ConstantsCoreVO.IS_MACOS ? "; echo $JAVA_HOME" : "& echo !JAVA_HOME!")
			// TODO:: TEST LAST COMMAND to REMOVE
			
			if (externalCallCompletionHandler != null)
			{
				// in case of macOS - instead of retuning any
				// bash script file path return the full command
				// to execute by caller's own nativeProcess process
				externalCallCompletionHandler(setCommand);
				cleanUp();
			}
			else
			{
				onCommandLineExecutionWith(setCommand);
			}
		}
		
		private function getSetExportCommand(field:String, path:String):String
		{
			if (ConstantsCoreVO.IS_MACOS) return "export "+ field +"=\""+ path +"\"";
			return "set "+ field +"="+ path;
		}
		
		private function onBatchFileWriteComplete():void
		{
			if (externalCallCompletionHandler != null)
			{
				externalCallCompletionHandler(windowsBatchFile.nativePath);
				cleanUp();
				return;
			}
			
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = ConstantsCoreVO.IS_MACOS ? 
				File.documentsDirectory.resolvePath("/bin/bash") : new File("c:\\Windows\\System32\\cmd.exe");
			
			customInfo.arguments = Vector.<String>([ConstantsCoreVO.IS_MACOS ? "-c" : "/c", windowsBatchFile.nativePath]);
			customProcess = new NativeProcess();
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function onCommandLineExecutionWith(command:String):void
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = ConstantsCoreVO.IS_MACOS ? 
				File.documentsDirectory.resolvePath("/bin/bash") : new File("c:\\Windows\\System32\\cmd.exe");
			
			customInfo.arguments = Vector.<String>([ConstantsCoreVO.IS_MACOS ? "-c" : "/c", command]);
			customProcess = new NativeProcess();
			startShell(true);
			customProcess.start(customInfo);
		}
		
		private function onBatchFileWriteError(value:String):void
		{
			Alert.show("Local environment setup failed[1]!\n"+ value, "Error!");
		}
		
		private function startShell(start:Boolean):void 
		{
			if (start)
			{
				isErrorClose = false;
				customProcess = new NativeProcess();
				customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
			}
			else
			{
				if (!customProcess) return;
				if (customProcess.running) customProcess.exit();
				customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
				customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
				customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
				customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
				customProcess = null;
				isErrorClose = false;
			}
		}
		
		private function shellError(event:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				Alert.show("Local environment setup failed[2]!\n"+ data);
				startShell(false);
			}
		}
		
		private function shellExit(event:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				startShell(false);
			}
		}
		
		private function shellData(event:ProgressEvent):void 
		{
			/*var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);*/
		}
	}
}