package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import openfl.events.Event;

class ASModulesEvent extends Event {
	public static final EVENT_ADD_MODULE:String = "addModuleEvent";
	public static final EVENT_REMOVE_MODULE:String = "removeModuleEvent";

	public var moduleFilePath:FileLocation;
	public var project:AS3ProjectVO;

	public function new(type:String, moduleFilePath:FileLocation, project:AS3ProjectVO) {
		super(type, false, true);
		this.moduleFilePath = moduleFilePath;
		this.project = project;
	}
}