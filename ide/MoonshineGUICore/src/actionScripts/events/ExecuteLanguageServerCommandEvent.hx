package actionScripts.events;

import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class ExecuteLanguageServerCommandEvent extends Event {
	public static final EVENT_EXECUTE_COMMAND:String = "executeCommand";

	public var project:ProjectVO;
	public var command:String;
	public var arguments:Array<String>;
	public var result:Dynamic;

	public function new(type:String, project:ProjectVO, command:String, args:Array<String> = null) {
		this.project = project;
		this.command = command;
		this.arguments = args;
		super(type, false, true);
	}
}