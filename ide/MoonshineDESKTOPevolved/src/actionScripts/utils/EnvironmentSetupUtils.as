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
				execute();
			}
		}
		
		public function getCommandPreparedToOSXEnvironment(completion:Function):void
		{
			externalCallCompletionHandler = completion;
			execute();
		}
		
		public function getBatchFilePathToWindowsEnvironment(completion:Function):void
		{
			externalCallCompletionHandler = completion;
			execute();
		}
		
		private function execute():void
		{
			var commandSeparator:String = ConstantsCoreVO.IS_MACOS ? "; " : "& ";
			var setOrExport:String = ConstantsCoreVO.IS_MACOS ? "export " : "set ";
			var setCommand:String = "";
			var setPathCommand:String = setOrExport+ "PATH=";
			var isValidToExecute:Boolean;
			
			if (UtilsCore.isJavaForTypeaheadAvailable())
			{
				setCommand = getSetExportCommand("JAVA_HOME", model.javaPathForTypeAhead.fileBridge.nativePath) + commandSeparator;
				setPathCommand += ConstantsCoreVO.IS_MACOS ? "$JAVA_HOME/bin:" : "!JAVA_HOME!\\bin;";
				isValidToExecute = true;
			}
			if (UtilsCore.isAntAvailable())
			{
				setCommand += getSetExportCommand("ANT_HOME", model.antHomePath.fileBridge.nativePath) + commandSeparator;
				setPathCommand += ConstantsCoreVO.IS_MACOS ? "$ANT_HOME/bin:" : "!ANT_HOME!\\bin;";
				isValidToExecute = true;
			}
			if (UtilsCore.isDefaultSDKAvailable())
			{
				setCommand += getSetExportCommand("FLEX_HOME", model.defaultSDK.fileBridge.nativePath) + commandSeparator;
				setPathCommand += ConstantsCoreVO.IS_MACOS ? "$FLEX_HOME/bin:" : "!FLEX_HOME!;";
				isValidToExecute = true;
			}
			
			// do not proceed if no path to set
			if (!isValidToExecute)
			{
				if (externalCallCompletionHandler != null) externalCallCompletionHandler(null);
				return;
			}
			
			setCommand += setPathCommand + (ConstantsCoreVO.IS_MACOS ? "$PATH" : "!PATH!");
			//  + (ConstantsCoreVO.IS_MACOS ? "; echo $JAVA_HOME" : "& echo !JAVA_HOME!")
			// TODO:: TEST LAST COMMAND to REMOVE
			
			if (!ConstantsCoreVO.IS_MACOS)
			{
				setCommand = "cmd /V /C \""+ setCommand +"\"";
				windowsBatchFile = File.applicationStorageDirectory.resolvePath("setLocalEnvironment.bat");
				FileUtils.writeToFileAsync(windowsBatchFile, "@echo off\n"+ setCommand, onBatchFileWriteComplete, onBatchFileWriteError);
			}
			else
			{
				if (externalCallCompletionHandler != null)
				{
					// in case of macOS - instead of retuning any
					// bash script file path return the full command
					// to execute by caller's own nativeProcess process
					externalCallCompletionHandler(setCommand);
				}
				else
				{
					onCommandLineExecutionWith(setCommand);
				}
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
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			
			Alert.show("Local environment set JAVA_HOME (Test)\n"+ data);
		}
	}
}