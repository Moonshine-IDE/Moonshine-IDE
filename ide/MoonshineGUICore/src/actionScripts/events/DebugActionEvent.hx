package actionScripts.events;

import openfl.events.Event;

class DebugActionEvent extends Event {
	public static final DEBUG_STEP_INTO:String = "debugStepInto";
	public static final DEBUG_STEP_OUT:String = "debugStepOut";
	public static final DEBUG_STEP_OVER:String = "debugStepOver";
	public static final DEBUG_RESUME:String = "debugResume";
	public static final DEBUG_PAUSE:String = "debugPause";
	public static final DEBUG_STOP:String = "debugStop";

	public var threadId:Int;

	public function new(type:String, threadId:Int = -1) {
		super(type, false, false);
		this.threadId = threadId;
	}
}