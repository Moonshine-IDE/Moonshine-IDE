package actionScripts.valueObjects
{
	public class WorkerNativeProcessResult
	{
		public static const OUTPUT_TYPE_ERROR:String = "typeError";
		public static const OUTPUT_TYPE_DATA:String = "typeData";
		public static const OUTPUT_TYPE_CLOSE:String = "typeProcessClose";
		
		public var output:String;
		public var type:String;
		public var queue:Object;
		
		public function WorkerNativeProcessResult(type:String, output:String, queue:Object=null /** type of NativeProcessQueueVO **/)
		{
			this.type = type;
			this.output = output;
			this.queue = queue;
		}
	}
}