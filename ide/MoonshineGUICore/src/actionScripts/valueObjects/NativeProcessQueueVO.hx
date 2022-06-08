package actionScripts.valueObjects;

class NativeProcessQueueVO {
	public var com:String;
	public var showInConsole:Bool;
	public var processType:String;
	public var extraArguments:Array<String>;

	public function new(com:String, showInConsole:Bool, processType:String = null, ...args:String) {
		this.com = com;
		this.showInConsole = showInConsole;
		this.processType = processType;

		extraArguments = args.toArray();
	}
}