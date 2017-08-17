package actionScripts.events
{
	import actionScripts.valueObjects.Diagnostic;

	import flash.events.Event;

	public class DiagnosticsEvent extends Event
	{
		public static const EVENT_SHOW_DIAGNOSTICS:String = "newShowDiagnostics";

		public var path:String;
		public var diagnostics:Vector.<Diagnostic>;

		public function DiagnosticsEvent(type:String, uri:String, diagnostics:Vector.<Diagnostic>)
		{
			super(type, false, false);
			this.path = uri;
			this.diagnostics = diagnostics;
		}
	}
}
