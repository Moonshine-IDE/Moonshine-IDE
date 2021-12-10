package actionScripts.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	[Event(name=EVENT_PARSE_COMPLETED, type="flash.events.Event")]
	public class FileSystemParser extends EventDispatcher implements IWorkerSubscriber
	{
		public static const EVENT_PARSE_COMPLETED:String = "ParseCompleted";
		
		private static const PARSE_FILES_ON_PATH:String = "parseFilesOnPath";
		
		private var subscribeIdToWorker:String;
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var readableExtensions:Array;
		private var filesTreeByDirectory:Dictionary = new Dictionary();
		private var allOutput:String = "";
		private var fileSeparator:String;
		private var newLineCharacter:String = ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n";
		
		private var _projectPath:String;
		public function get projectPath():String
		{
			return _projectPath;
		}

		private var _filePath:String;
		public function get filePath():String
		{
			return _filePath;
		}
		
		private var _fileName:String;
		public function get fileName():String
		{
			return _fileName;
		}
		
		private var _resultsStringFormat:String = "";
		public function get resultsStringFormat():String
		{
			return _resultsStringFormat;
		}

		public function get resultsArrayFormat():Array
		{
			return _resultsStringFormat.split(newLineCharacter);
		}
		
		public function FileSystemParser() 
		{	
			fileSeparator = IDEModel.getInstance().fileCore.separator;
			subscribeIdToWorker = UIDUtil.createUID();
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
		}
		
		public function parseFilesPaths(fromPath:String, withName:String, readableExtensions:Array=null):void
		{
			var tempDirectory:FileLocation = IDEModel.getInstance().fileCore.resolveTemporaryDirectoryPath("moonshine");
			if (!tempDirectory.fileBridge.exists)
			{
				tempDirectory.fileBridge.createDirectory();
			}

			withName ||= "FileSystemParser";

			this.readableExtensions = readableExtensions;
			this._projectPath = fromPath;
			this._fileName = withName;
			this._filePath = tempDirectory.fileBridge.resolvePath(this._fileName +".txt").fileBridge.nativePath;

			var tmpExtensions:String = "";
			if (readableExtensions)
			{
				if (ConstantsCoreVO.IS_MACOS)
				{
					tmpExtensions = " -regex '.*\\.("+ readableExtensions.join("|") +")'";
				}
				else
				{
					for each (var ext:String in readableExtensions)
					{
						tmpExtensions += "*."+ ext +" ";
					}
				}
			}

			// @example
			// macOS: find -E $'folderPath' -regex '.*\.(mxml|xml)' -type f
			// windows: dir /a-d /b /s *.mxml *.xml
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ?
					"find -E $'"+ UtilsCore.getEncodedForShell(fromPath) +"'"+ tmpExtensions +" -type f > '"+ _filePath +"'" :
					"dir /a-d /b /s "+ tmpExtensions +" > "+ UtilsCore.getEncodedForShell(_filePath),
				false,
				PARSE_FILES_ON_PATH)
			);
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:fromPath}, subscribeIdToWorker);
		}
		
		public function unsubscribeFromWorker():void
		{
			worker.unSubscribeComponent(subscribeIdToWorker);
			worker = null;
			queue = null;
		}
		
		public function onWorkerValueIncoming(value:Object):void
		{
			var tmpValue:Object = value.value;
			switch (value.event)
			{
				case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
					if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_DATA) shellData(tmpValue);
					else if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE) shellExit(tmpValue);
					else shellError(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
					if (queue.length != 0) queue.shift();
					shellTick(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					listOfProcessEnded();
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					//debug("%s", value.value);
					break;
			}
		}
		
		protected function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		protected function listOfProcessEnded():void
		{
			unsubscribeFromWorker();
			
			// read the file content
			IDEModel.getInstance().fileCore.readAsyncWithListener(
				onReadCompletes, 
				onReadError, 
				new FileLocation(filePath)
			);
			
			/*
			* @local
			*/
			function onReadCompletes(output:String):void
			{
				if (output)
				{
					_resultsStringFormat += (ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n") + output;
				}
				dispatchEvent(new Event(EVENT_PARSE_COMPLETED));
			}
			function onReadError(value:String):void
			{
				dispatchEvent(new Event(EVENT_PARSE_COMPLETED));
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value, false, false, ConsoleOutputEvent.TYPE_ERROR)
				);
			}
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			unsubscribeFromWorker();
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value.output, false, false, ConsoleOutputEvent.TYPE_ERROR)
			);
		}
		
		protected function shellExit(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			trace("Shell Exits");
		}
		
		protected function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
		}
		
		protected function shellData(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			if (value.output.match(/fatal: .*/))
			{
				shellError(value);
			}
			else
			{
				//trace(value.output);
				//_resultsStringFormat += value.output.replace(/^[ \n|\r\n]/gm, newLineCharacter); // remove all the blank lines
				//allOutput += StringUtil.trim(value.output);
				//parsedFiles = parsedFiles.concat(value.output.split("\r\n"));
			}
		}
	}
}