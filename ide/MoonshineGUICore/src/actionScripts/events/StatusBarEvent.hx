package actionScripts.events;

import openfl.events.Event;

class StatusBarEvent extends Event {
	public static final PROJECT_BUILD_STARTED:String = "PROJECT_BUILD_STARTED";
	public static final PROJECT_BUILD_ENDED:String = "PROJECT_BUILD_ENDED";
	public static final PROJECT_DEBUG_STARTED:String = "PROJECT_DEBUG_STARTED";
	public static final PROJECT_DEBUG_ENDED:String = "PROJECT_DEBUG_ENDED";
	public static final PROJECT_BUILD_TERMINATE:String = "PROJECT_BUILD_TERMINATE";

	public static final LANGUAGE_SERVER_STATUS:String = "LANGUAGE_SERVER_STATUS";

	public var projectName:String;
	public var notificationSuffix:String;
	public var isShowStopButton:Bool;

	public function new(type:String, projectName:String = null, notificationSuffix:String = null, isShowStopButton:Bool = true) {
		this.projectName = projectName;
		this.notificationSuffix = notificationSuffix;
		this.isShowStopButton = isShowStopButton;

		super(type, true, false);
	}
}