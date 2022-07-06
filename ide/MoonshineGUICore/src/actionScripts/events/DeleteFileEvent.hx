package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.ProjectVO;
import haxe.Constraints.Function;
import openfl.events.Event;

class DeleteFileEvent extends Event {
	public static final EVENT_DELETE_FILE:String = "deleteFileEvent";

	public var file:FileLocation;
	public var wrappers:Array<Dynamic>;
	public var treeViewCompletionHandler:Function;
	public var showAlert:Bool;
	public var projectAssociatedWithFile:ProjectVO;

	// If you don't supply a filewrapper with a version control object it won't be registered with vc
	public function new(file:FileLocation, wrappers:Array<Dynamic> = null, treeViewHandler:Function = null, showAlert:Bool = true,
			projectAssociatedWithFile:ProjectVO = null) {
		this.file = file;
		this.wrappers = wrappers;
		this.showAlert = showAlert;
		this.treeViewCompletionHandler = treeViewHandler;
		this.projectAssociatedWithFile = projectAssociatedWithFile;

		super(EVENT_DELETE_FILE, false, false);
	}
}