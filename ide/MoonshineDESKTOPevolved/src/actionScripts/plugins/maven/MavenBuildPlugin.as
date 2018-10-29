package actionScripts.plugins.maven
{
    import actionScripts.events.ConsoleBuildEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.build.ConsoleBuildPluginBase;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.Settings;

    public class MavenBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
        public static const START_MAVEN_BUILD:String = "startMavenBuild";
        public static const STOP_MAVEN_BUILD:String = "stopMavenBuild";

        public function MavenBuildPlugin()
        {
            super();
        }

        override public function get name():String
        {
            return "Maven Build Setup";
        }

        override public function get author():String
        {
            return "Moonshine Project Team";
        }

        override public function get description():String
        {
            return "Apache Maven® Build Plugin. Esc exits.";
        }

        private var _mavenPath:String;

        public function get mavenPath():String
        {
            return _mavenPath;
        }

        public function set mavenPath(value:String):void
        {
            if (_mavenPath != value)
            {
                _mavenPath = value;

                model.mavenPath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
            return Vector.<ISetting>([
                new PathSetting(this, 'mavenPath', 'Maven Home', true, mavenPath)
            ]);
        }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(START_MAVEN_BUILD, startConsoleBuildHandler);
            dispatcher.addEventListener(STOP_MAVEN_BUILD, stopConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(START_MAVEN_BUILD, startConsoleBuildHandler);
            dispatcher.removeEventListener(STOP_MAVEN_BUILD, stopConsoleBuildHandler);
        }

        override protected function startConsoleBuildHandler(event:ConsoleBuildEvent):void
        {
            super.startConsoleBuildHandler(event);

            var args:Vector.<String> = getConstantArguments();
            args.push(event.arguments);

            start(args, event.buildDirectory);
        }

        override protected function stopConsoleBuildHandler(event:ConsoleBuildEvent):void
        {
            super.stopConsoleBuildHandler(event);

            stop();
        }

        private function getMavenBinPath():String
        {
            var mavenLocation:FileLocation = new FileLocation(mavenPath);
            var mavenBin:String = "bin/";

            if (Settings.os == "win")
            {
                return mavenLocation.resolvePath(mavenBin + "mvn.bat").fileBridge.nativePath;
            }
            else
            {
                return UtilsCore.convertString(mavenLocation.resolvePath(mavenBin + "mvn").fileBridge.nativePath);
            }
        }

        private function getConstantArguments():Vector.<String>
        {
            var args:Vector.<String> = new Vector.<String>();
            if (Settings.os == "win")
            {
                args.push("/C");
            }
            else
            {
                args.push("-c");
            }

            args.push(getMavenBinPath());
            args.push("mvn");

            return args;
        }
    }
}
