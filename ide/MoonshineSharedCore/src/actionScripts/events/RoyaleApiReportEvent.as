package actionScripts.events
{
    import actionScripts.valueObjects.RoyaleApiReportVO;

    import flash.events.Event;

    public class RoyaleApiReportEvent extends Event
    {
        public static const LAUNCH_REPORT_CONFIGURATION:String = "launchReportConfiguration";
        public static const LAUNCH_REPORT_GENERATION:String = "launchReportGeneration";
        public static const REPORT_GENERATION_COMPLETED:String = "reportGenerationCompleted";
        public static const DO_NOT_SHOW_PROMPT_API_REPORT:String = "doNotShowPromptApiReport";

        public function RoyaleApiReportEvent(type:String, reportConfiguration:RoyaleApiReportVO = null, doNotShowApiPromptReport:Boolean = false)
        {
            super(type, false, false);

            _reportConfiguration = reportConfiguration;
            _doNotShowApiPromptReport = doNotShowApiPromptReport;
        }

        private var _reportConfiguration:RoyaleApiReportVO;

        public function get reportConfiguration():RoyaleApiReportVO
        {
            return _reportConfiguration;
        }

        private var _doNotShowApiPromptReport:Boolean;

        public function get doNotShowApiPromptReport():Boolean
        {
            return _doNotShowApiPromptReport;
        }

        override public function clone():Event
        {
            return new RoyaleApiReportEvent(type);
        }
    }
}
