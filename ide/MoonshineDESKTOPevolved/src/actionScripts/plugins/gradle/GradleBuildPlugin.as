package actionScripts.plugins.gradle
{
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.valueObjects.ConstantsCoreVO;

    public class GradleBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
        protected var status:int;
        protected var stopWithoutMessage:Boolean;

        protected var buildId:String;
		private var isProjectHasInvalidPaths:Boolean;

        private static const BUILD_SUCCESS:RegExp = /BUILD SUCCESS/;
        private static const WARNING:RegExp = /\[WARNING\]/;
        private static const BUILD_FAILED:RegExp = /BUILD FAILED/;
        private static const BUILD_FAILURE:RegExp = /BUILD FAILURE/;
        private static const ERROR:RegExp = /\[ERROR\]/;

        public function GradleBuildPlugin()
        {
            super();
        }

        override public function get name():String
        {
            return "Gradle Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

        override public function get description():String
        {
            return "Apache Gradle® Build Plugin. Esc exits.";
        }

        public function get gradlePath():String
        {
            return model ? model.gradlePath : null;
        }

        public function set gradlePath(value:String):void
        {
            if (model.gradlePath != value)
            {
                model.gradlePath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
            return Vector.<ISetting>([
                new PathSetting(this, 'gradlePath', 'Gradle Home', true, gradlePath)
            ]);
        }

        override public function activate():void
        {
            super.activate();

            /*dispatcher.addEventListener(GradleBuildEvent.START_GRADLE_BUILD, startConsoleBuildHandler);
            dispatcher.addEventListener(GradleBuildEvent.STOP_GRADLE_BUILD, stopConsoleBuildHandler);*/
        }

        override public function deactivate():void
        {
            super.deactivate();

            /*dispatcher.removeEventListener(GradleBuildEvent.START_GRADLE_BUILD, startConsoleBuildHandler);
            dispatcher.removeEventListener(GradleBuildEvent.STOP_GRADLE_BUILD, stopConsoleBuildHandler);*/
        }
    }
}
