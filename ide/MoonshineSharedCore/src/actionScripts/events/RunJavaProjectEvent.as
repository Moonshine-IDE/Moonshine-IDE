package actionScripts.events
{
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;

    import flash.events.Event;

    public class RunJavaProjectEvent extends Event
    {
        public static const RUN_JAVA_PROJECT:String = "runJavaProject";

        private var _project:JavaProjectVO;

        public function RunJavaProjectEvent(type:String, project:JavaProjectVO)
        {
            super(type, false, false);

            _project = project;
        }

        public function get project():JavaProjectVO
        {
            return _project;
        }
    }
}
