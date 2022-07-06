package actionScripts.events;

import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import openfl.events.Event;

class RunJavaProjectEvent extends Event {
	public static final RUN_JAVA_PROJECT:String = "runJavaProject";

	private var _project:JavaProjectVO;

	public var project(get, never):JavaProjectVO;

	public function new(type:String, project:JavaProjectVO) {
		super(type, false, false);

		_project = project;
	}

	public function get_project():JavaProjectVO {
		return _project;
	}
}