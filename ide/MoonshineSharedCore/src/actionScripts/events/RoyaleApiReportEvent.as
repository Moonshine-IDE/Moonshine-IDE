package actionScripts.events
{
    import actionScripts.valueObjects.RoyaleApiReportVO;

    import flash.events.Event;

    public class RoyaleApiReportEvent extends Event
    {
        public static const LAUNCH_REPORT_CONFIGURATION:String = "launchReportConfiguration";
        public static const LAUNCH_REPORT_GENERATION:String = "launchReportGeneration";

        public function RoyaleApiReportEvent(type:String, reportConfiguration:RoyaleApiReportVO = null)
        {
            super(type, false, false);

            _reportConfiguration = reportConfiguration;
        }

        private var _reportConfiguration:RoyaleApiReportVO;

        public function get reportConfiguration():RoyaleApiReportVO
        {
            return _reportConfiguration;
        }

        override public function clone():Event
        {
            return new RoyaleApiReportEvent(type);
        }
    }
}
