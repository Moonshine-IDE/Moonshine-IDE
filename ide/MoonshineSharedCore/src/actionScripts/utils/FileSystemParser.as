package actionScripts.utils
{
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.WorkerEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEWorker;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.NativeProcessQueueVO;
	import actionScripts.valueObjects.ResourceVO;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	public class FileSystemParser implements IWorkerSubscriber
	{
		private static const PARSE_FILES_ON_PATH:String = "parseFilesOnPath";
		private static const subscribeIdToWorker:String = UIDUtil.createUID();
		
		private static var instance:FileSystemParser;
		
		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var collection:IList;
		private var readableExtensions:Array;
		private var parsedFiles:Array;
		
		public static function getInstance():FileSystemParser 
		{	
			if (!instance) 
			{
				instance = new FileSystemParser();
				instance.worker.subscribeAsIndividualComponent(subscribeIdToWorker, instance);
				instance.worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
			}
			
			return instance;
		}
		
		public function parseFilesPaths(fromPath:String, collection:IList, readableExtensions:Array=null):void
		{
			this.collection = collection;
			this.readableExtensions = readableExtensions;
			this.parsedFiles = [];
			
			queue = new Vector.<Object>();
			addToQueue(new NativeProcessQueueVO(
				ConstantsCoreVO.IS_MACOS ? 
					"find $'"+ UtilsCore.getEncodedForShell(fromPath) : 
					"dir /a-d /b /s", 
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
			parsedFiles.forEach(function(path:String, index:int, arr:Array):void
			{
				if (!collection) collection = new ArrayList();
				collection.addItem(new ResourceVO(path));
			});
			trace("ello");
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			trace("File System Parsing Error: ", value.output);
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
				value.output = value.output.replace(/\s\n/g, "\n"); // remove all the blank lines
				parsedFiles = value.output.split("\n");
			}
		}
	}
}