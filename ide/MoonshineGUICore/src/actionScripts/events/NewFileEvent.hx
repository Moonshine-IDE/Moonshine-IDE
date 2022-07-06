package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class NewFileEvent extends Event {
	public static final EVENT_NEW_FILE:String = "newFileEvent";
	public static final EVENT_NEW_VISUAL_EDITOR_FILE:String = "newVisualEditorFileEvent";
	public static final EVENT_NEW_FOLDER:String = "EVENT_NEW_FOLDER";
	public static final EVENT_ANT_BIN_URL_SET:String = "EVENT_ANT_BIN_URL_SET";
	public static final EVENT_FILE_RENAMED:String = "EVENT_FILE_RENAMED";
	public static final EVENT_PROJECT_SELECTED:String = "EVENT_PROJECT_SELECTED";
	public static final EVENT_FILE_SELECTED:String = "EVENT_FILE_SELECTED";
	public static final EVENT_FILE_CREATED:String = "EVENT_FILE_CREATED";
	public static final EVENT_PROJECT_RENAME:String = "EVENT_PROJECT_RENAME";

	public var filePath:String;
	public var fileName:String;
	public var fileExtension:String;
	public var fromTemplate:FileLocation;
	public var insideLocation:FileWrapper;
	public var newFileCreated:FileLocation;
	public var extraParameters:Array<String>;
	public var isFolder:Bool;
	public var isOpenAfterCreate:Bool = true;

	public var ofProject:ProjectVO;

	public function new(type:String, filePath:String = null, fromTemplate:FileLocation = null, insideLocation:FileWrapper = null, ...param:String) {
		this.filePath = filePath;
		this.fromTemplate = fromTemplate;
		this.insideLocation = insideLocation;
		this.extraParameters = param;

		super(type, false, true);
	}
}