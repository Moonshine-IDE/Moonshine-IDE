package actionScripts.utils
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.IDataInput;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.valueObjects.WorkerNativeProcessResult;

	import flash.utils.setTimeout;

	public class WorkerListOfNativeProcess
	{
		public var worker:MoonshineWorker;
		public var subscriberUdid:String;
		
		private var customProcess:NativeProcess;
		private var customInfo:NativeProcessStartupInfo;
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var pendingQueue:Array = [];
		private var isErrorClose:Boolean;
		private var presentRunningQueue:Object;
		private var currentWorkingDirectory:File;
		
		public function WorkerListOfNativeProcess()
		{
		}
		
		public function runProcesses(processDescriptor:Object):void
		{
			if (customProcess && customProcess.running)
			{
				pendingQueue.push(processDescriptor);
				return;
			}
			
			if (customProcess)
			{
				stopShell();
			}
			customInfo = renewProcessInfo();
			
			queue = processDescriptor.queue;
			if (processDescriptor.workingDirectory != null) currentWorkingDirectory = new File(processDescriptor.workingDirectory);
			
			flush();
		}
		
		private function renewProcessInfo():NativeProcessStartupInfo
		{
			customInfo = new NativeProcessStartupInfo();
			customInfo.executable = !MoonshineWorker.IS_MACOS ? new File("c:\\Windows\\System32\\cmd.exe") : new File("/bin/bash");
			
			return customInfo;
		}
		
		private function flush():void
		{
			if (queue.length == 0)
			{
				stopShell();
				cleanUpShell();
				worker.workerToMain.send({
					event:WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED, 
					value:null, 
					subscriberUdid:subscriberUdid
				});
				
				if (pendingQueue.length != 0)
				{
					runProcesses(pendingQueue.shift());
				}
				return;
			}
			
			if (queue[0].showInConsole) 
				worker.workerToMain.send({
					event:WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT, 
					value:"Sending to command: "+ queue[0].com, 
					subscriberUdid:subscriberUdid
				});
			
			var tmpArr:Array = queue[0].com.split("&&");
			
			if (!MoonshineWorker.IS_MACOS)
			{
				tmpArr.unshift("/c");
			}
			else
			{
				tmpArr.unshift("-c");
			}
			customInfo.arguments = Vector.<String>(tmpArr);
			customInfo.workingDirectory = currentWorkingDirectory;
			
			presentRunningQueue = queue.shift(); /** type of NativeProcessQueueVO **/
			worker.workerToMain.send({
				event:WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK, 
				value:presentRunningQueue, 
				subscriberUdid:subscriberUdid
			});
			
			if (customProcess) cleanUpShell();
			startShell();
			customProcess.start(customInfo);
		}
		
		private function startShell():void
		{
			customProcess = new NativeProcess();
			customProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);

			// @note
			// for some strange reason all the standard output turns to standard error output by git command line.
			// to have them dictate and continue the native process (without terminating by assuming as an error)
			// let's listen standard errors to shellData method only
			customProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);

			customProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.addEventListener(NativeProcessExitEvent.EXIT, shellExit);
		}

		private function stopShell():void
		{
			if (!customProcess)
			{
				return;
			}

			if (customProcess.running)
			{
				customProcess.exit();
			}

			presentRunningQueue = null;
			isErrorClose = false;
		}

		private function cleanUpShell():void
		{
			customProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, shellData);
			customProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, shellData);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, shellError);
			customProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, shellError);
			customProcess.removeEventListener(NativeProcessExitEvent.EXIT, shellExit);
			customProcess = null;
		}

		private function shellError(e:ProgressEvent):void 
		{
			if (customProcess)
			{
				var output:IDataInput = customProcess.standardError;
				var data:String = output.readUTFBytes(output.bytesAvailable).toLowerCase();
				
				var syntaxMatch:Array;
				var generalMatch:Array;
				var initMatch:Array;
				var hideDebug:Boolean;
				
				syntaxMatch = data.match(/(.*?)\((\d*)\): col: (\d*) error: (.*).*/);
				if (syntaxMatch) {
					var pathStr:String = syntaxMatch[1];
					var lineNum:int = syntaxMatch[2];
					var colNum:int = syntaxMatch[3];
					var errorStr:String = syntaxMatch[4];
				}
				
				generalMatch = data.match(/(.*?): error: (.*).*/);
				if (!syntaxMatch && generalMatch)
				{ 
					pathStr = generalMatch[1];
					errorStr  = generalMatch[2];
					pathStr = pathStr.substr(pathStr.lastIndexOf("/")+1);
					worker.workerToMain.send({
						event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT, 
						value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, data), 
						subscriberUdid:subscriberUdid
					});
					hideDebug = true;
				}
				
				if (!hideDebug) worker.workerToMain.send({
					event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT, 
					value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, data), 
					subscriberUdid:subscriberUdid
				});
				isErrorClose = true;
				//Native process need time to properly exited
				stopShell();
			}
		}
		
		private function shellExit(e:NativeProcessExitEvent):void 
		{
			if (customProcess) 
			{
				worker.workerToMain.send({
					event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
					value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE, null, presentRunningQueue),
					subscriberUdid:subscriberUdid
				});
				
				flush();
			}
		}
		
		private function shellData(e:ProgressEvent):void 
		{
			var output:IDataInput = (customProcess.standardOutput.bytesAvailable != 0) ? customProcess.standardOutput : customProcess.standardError;
			var data:String = output.readUTFBytes(output.bytesAvailable);
			var match:Array;
			var isFatal:Boolean;
			
			match = data.match(/fatal: .*/);
			if (match)
			{
				isFatal = true;
				worker.workerToMain.send({
					event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT, 
					value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_DATA, data, presentRunningQueue), 
					subscriberUdid:subscriberUdid
				});
			}
			
			if (!match) match = data.toLowerCase().match(/(.*?)error: (.*).*/);
			if (!match) match = data.toLowerCase().match(/'git' is not recognized as an internal or external command/);
			
			if (match)
			{
				if (!isFatal)
				{
					worker.workerToMain.send({
						event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
						value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_ERROR, data, presentRunningQueue),
						subscriberUdid:subscriberUdid
					});
				}

				//Native process need time to properly exited
				setTimeout(stopShell, 200);
				return;
			}

			if (!isFatal)
			{
				worker.workerToMain.send({
					event:WorkerEvent.RUN_NATIVEPROCESS_OUTPUT,
					value:new WorkerNativeProcessResult(WorkerNativeProcessResult.OUTPUT_TYPE_DATA, data, presentRunningQueue),
					subscriberUdid:subscriberUdid
				});
			}
		}
	}
}