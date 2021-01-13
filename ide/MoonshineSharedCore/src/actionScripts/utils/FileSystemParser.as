package actionScripts.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	[Event(name="ParseCompleted", type="flash.events.Event")]
	public class FileSystemParser extends EventDispatcher implements IWorkerSubscriber
	{
		private static const PARSE_FILES_ON_PATH:String = "parseFilesOnPath";
		private static const subscribeIdToWorker:String = UIDUtil.createUID();
		
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var collection:IList;
		private var readableExtensions:Array;
		private var filesTreeByDirectory:Dictionary = new Dictionary();
		private var allOutput:String = "";
		private var fileSeparator:String;
		private var stringVar:String;
		private var project:ProjectVO;
		
		public function FileSystemParser() 
		{	
			fileSeparator = IDEModel.getInstance().fileCore.separator;
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
		}
		
		public function parseFilesPaths(fromPath:String, stringVar:String, project:ProjectVO, readableExtensions:Array=null):void
		{
			//this.collection = collection;
			this.readableExtensions = readableExtensions;
			this.stringVar = stringVar;
			this.project = project;
			
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ? 
					"find $'"+ UtilsCore.getEncodedForShell(fromPath) : 
					UtilsCore.getEncodedForShell("dir /a-d /b /s"), 
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
			trace("--------------------- ", project[stringVar]);
			/*parsedFiles.forEach(function(path:String, index:int, arr:Array):void
			{
				if (!collection) collection = new ArrayList();
				collection.addItem(new ResourceVO(path));
			});*/
			unsubscribeFromWorker();
			dispatchEvent(new Event("ParseCompleted"));
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			trace("File System Parsing Error: ", value.output);
			unsubscribeFromWorker();
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
				project[stringVar] += value.output.replace(/^[ \r\n]/gm, "\r\n"); // remove all the blank lines
				//allOutput += StringUtil.trim(value.output);
				//parsedFiles = parsedFiles.concat(value.output.split("\r\n"));
			}
		}
	}
}