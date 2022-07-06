package actionScripts.events;

import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class DiagnosticsEvent extends Event {
	public static final EVENT_SHOW_DIAGNOSTICS:String = "newShowDiagnostics";

	public var uri:String;
	public var project:ProjectVO;
	public var diagnostics:Array<Dynamic>;

	public function new(type:String, uri:String, project:ProjectVO, diagnostics:Array<Dynamic>) {
		super(type, false, false);
		this.uri = uri;
		this.project = project;
		this.diagnostics = diagnostics;
	}
}