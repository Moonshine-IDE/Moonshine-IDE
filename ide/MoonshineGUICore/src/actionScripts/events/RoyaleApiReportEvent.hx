package actionScripts.events;

import actionScripts.valueObjects.RoyaleApiReportVO;
import flash.events.Event;

class RoyaleApiReportEvent extends Event {
	public static final LAUNCH_REPORT_CONFIGURATION:String = "launchReportConfiguration";
	public static final LAUNCH_REPORT_GENERATION:String = "launchReportGeneration";
	public static final REPORT_GENERATION_COMPLETED:String = "reportGenerationCompleted";
	public static final DO_NOT_SHOW_PROMPT_API_REPORT:String = "doNotShowPromptApiReport";

	public function new(type:String, reportConfiguration:RoyaleApiReportVO = null, doNotShowApiPromptReport:Bool = false) {
		super(type, false, false);

		_reportConfiguration = reportConfiguration;
		_doNotShowApiPromptReport = doNotShowApiPromptReport;
	}

	private var _reportConfiguration:RoyaleApiReportVO;

	public var reportConfiguration(get, never):RoyaleApiReportVO;

	private function get_reportConfiguration():RoyaleApiReportVO
		return _reportConfiguration;

	private var _doNotShowApiPromptReport:Bool;

	public var doNotShowApiPromptReport(get, never):Bool;

	private function get_doNotShowApiPromptReport():Bool
		return _doNotShowApiPromptReport;

	override public function clone():Event {
		return new RoyaleApiReportEvent(type);
	}
}