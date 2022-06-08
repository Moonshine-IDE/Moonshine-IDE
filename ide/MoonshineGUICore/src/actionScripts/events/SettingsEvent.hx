package actionScripts.events;

import openfl.events.Event;

class SettingsEvent extends Event {
	public static final EVENT_OPEN_SETTINGS:String = "openSettingsEvent";
	public static final EVENT_SETTINGS_SAVED:String = "savedSettingsEvent";
	public static final EVENT_REFRESH_CURRENT_SETTINGS:String = "refreshCurrentSettingsEvent";

	public var openSettingsByQualifiedClassName:String;

	public function new(type:String, openSettingsByQualifiedClassName:String = null) {
		this.openSettingsByQualifiedClassName = openSettingsByQualifiedClassName;

		super(type, false, false);
	}
}