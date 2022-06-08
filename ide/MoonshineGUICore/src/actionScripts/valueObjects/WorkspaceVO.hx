package actionScripts.valueObjects;

class WorkspaceVO {
	public var label:String;
	public var paths:Array<String>;

	public function new(label:String, paths:Array<String>) {
		this.label = label;
		this.paths = paths;
	}
}