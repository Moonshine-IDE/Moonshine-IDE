package actionScripts.events
{
    import flash.events.Event;

    public class RoyaleApiReportEvent extends Event
    {
        public static const LAUNCH_REPORT_CONFIGURATION:String = "launchReportConfiguration";

        public function RoyaleApiReportEvent(type:String)
        {
            super(type, false, false);
        }

        override public function clone():Event
        {
            return new RoyaleApiReportEvent(type);
        }
    }
}
