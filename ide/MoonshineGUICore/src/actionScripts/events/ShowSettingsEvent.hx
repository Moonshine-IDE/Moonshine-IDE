package actionScripts.events;

import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class ShowSettingsEvent extends Event {
	public static final EVENT_SHOW_SETTINGS:String = "showSettingsEvent";

	public var project:ProjectVO;
	public var jumpToSection:String;

	public function new(project:ProjectVO, jumpToSection:String = null) {
		this.project = project;
		this.jumpToSection = jumpToSection;

		super(EVENT_SHOW_SETTINGS, false, true);
	}
}