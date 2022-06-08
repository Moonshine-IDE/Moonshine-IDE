package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;
import openfl.events.Event;

class OpenFileEvent extends Event {
	public static final OPEN_FILE:String = "openFileEvent";
	public static final TRACE_LINE:String = "traceLineEvent";
	public static final JUMP_TO_SEARCH_LINE:String = "jumpToLineEvent";

	public var files:Array<FileLocation>;
	public var atLine:Int;
	public var atChar:Int = -1;
	public var wrappers:Array<FileWrapper>;
	public var openAsTourDe:Bool;
	public var tourDeSWFSource:String;

	public var independentOpenFile:Bool; // when arbitrary file opened off-Moonshine, or drag Int off-Moonshine

	public function new(type:String, files:Array<FileLocation> = null, atLine:Int = -1, wrappers:Array<FileWrapper> = null, ...param:Any) {
		try {
			if (files != null)
				this.files = files;
			if (wrappers != null)
				this.wrappers = wrappers;
		} catch (e) {
			trace("Error:: Unrecognized 'Open' object type.");
		}

		this.atLine = atLine;
		if (param != null && param.length > 0) {
			this.openAsTourDe = param[0];
			if (this.openAsTourDe)
				this.tourDeSWFSource = param[1];
		}

		super(type, false, true);
	}
}