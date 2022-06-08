package actionScripts.valueObjects;

class WorkerNativeProcessResult {
	public static final OUTPUT_TYPE_ERROR:String = "typeError";
	public static final OUTPUT_TYPE_DATA:String = "typeData";
	public static final OUTPUT_TYPE_CLOSE:String = "typeProcessClose";

	public var output:String;
	public var type:String;
	public var queue:Dynamic;

	public function new(type:String, output:String, queue:Dynamic = null /** type of NativeProcessQueueVO **/) {
		this.type = type;
		this.output = output;
		this.queue = queue;
	}
}