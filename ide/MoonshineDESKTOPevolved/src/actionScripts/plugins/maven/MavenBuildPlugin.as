package actionScripts.plugins.maven
{
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.ShowSettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.build.ConsoleBuildPluginBase;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.Settings;

    import flash.events.Event;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.IDataInput;

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

        override public function start(args:Vector.<String>, buildDirectory:*):void
        {
            if (!mavenPath)
            {
                error("Specify path to Maven folder.");
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.maven::MavenBuildPlugin"));
                return;
            }

            clearOutput();

            print("Maven path: %s", mavenPath);
            print("Maven build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            super.start(args, buildDirectory);

            var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
            if (as3Project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, as3Project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            }
        }

        override protected function startConsoleBuildHandler(event:Event):void
        {
            super.startConsoleBuildHandler(event);

            var args:Vector.<String> = getConstantArguments();
            var arguments:Array = [];
            var buildDirectory:FileLocation;

            var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;
            if (as3Project)
            {
                arguments = as3Project.mavenBuildOptions.getCommandLine();
                if (arguments.length > 0)
                {
                    args.push(arguments.join(" "));
                }

                if (as3Project.mavenBuildOptions.mavenBuildPath)
                {
                    buildDirectory = new FileLocation(as3Project.mavenBuildOptions.mavenBuildPath);
                }
            }

            if (!buildDirectory)
            {
                warning("Maven build directory has not been specified");
                dispatcher.dispatchEvent(new ShowSettingsEvent(as3Project, "Maven Build"));
                return;
            }

            if (arguments.length == 0)
            {
                warning("Specify Maven commands (Ex. clean install)");
                dispatcher.dispatchEvent(new ShowSettingsEvent(as3Project, "Maven Build"));
                return;
            }

            start(args, buildDirectory);
        }

        override protected function stopConsoleBuildHandler(event:Event):void
        {
            super.stopConsoleBuildHandler(event);

            stop();
        }

        override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
        {
            var output:IDataInput = nativeProcess.standardOutput;
            var data:String = output.readUTFBytes(output.bytesAvailable);

            if (data.match(/\[ERROR\]/))
            {
                error("%s", data);
            }
            else if (data.match(/\[WARNING\]/))
            {
                warning("%s", data);
            }
            else
            {
                print("%s", data);
            }
        }

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);

            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
        }

        private function getMavenBinPath():String
        {
            var mavenLocation:FileLocation = new FileLocation(mavenPath);
            var mavenBin:String = "bin/";

            if (Settings.os == "win")
            {
                return mavenLocation.resolvePath(mavenBin + "mvn.cmd").fileBridge.nativePath;
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

            return args;
        }
    }
}
