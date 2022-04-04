package actionScripts.plugins.maven
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.ShowSettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IJavaProject;
    import actionScripts.plugin.build.MavenBuildStatus;
    import actionScripts.plugin.java.javaproject.vo.JavaTypes;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.HelperUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ComponentTypes;
    import actionScripts.valueObjects.ComponentVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;
    import actionScripts.plugin.console.ConsoleEvent;

    public class MavenBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
        protected var status:int;
        protected var stopWithoutMessage:Boolean;

        protected var buildId:String;
		private var isProjectHasInvalidPaths:Boolean;
		private var pathSetting:PathSetting;

        private static const BUILD_SUCCESS:RegExp = /BUILD SUCCESS/;
        private static const WARNING:RegExp = /\[WARNING\]/;
        private static const BUILD_FAILED:RegExp = /BUILD FAILED/;
        private static const BUILD_FAILURE:RegExp = /BUILD FAILURE/;
        private static const ERROR:RegExp = /\[ERROR\]/;

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
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";
        }

        override public function get description():String
        {
            return "Apache Maven® Build Plugin.";
        }

        public function get mavenPath():String
        {
            return model ? model.mavenPath : null;
        }

        public function set mavenPath(value:String):void
        {
            if (model.mavenPath != value)
            {
                model.mavenPath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'mavenPath', 'Maven Home', true, mavenPath);
			pathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected, false, 0, true);
			
            return Vector.<ISetting>([
				pathSetting
            ]);
        }
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onSDKPathSelected);
				pathSetting = null;
			}
		}
		
		private function onSDKPathSelected(event:Event):void
		{
			if (!pathSetting.stringValue) return;
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_MAVEN);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_MAVEN, pathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					pathSetting.setMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
				else
				{
					pathSetting.setMessage(null);
				}
			}
		}

        override public function activate():void
        {
            super.activate();

           // dispatcher.addEventListener(MavenBuildEvent.INSTALL_MAVEN_BUILD, startConsoleBuildHandlerInstall);
            dispatcher.addEventListener(MavenBuildEvent.START_MAVEN_BUILD, startConsoleBuildHandler);
            dispatcher.addEventListener(MavenBuildEvent.STOP_MAVEN_BUILD, stopConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();
           // dispatcher.removeEventListener(MavenBuildEvent.INSTALL_MAVEN_BUILD, startConsoleBuildHandlerInstall);
            dispatcher.removeEventListener(MavenBuildEvent.START_MAVEN_BUILD, startConsoleBuildHandler);
            dispatcher.removeEventListener(MavenBuildEvent.STOP_MAVEN_BUILD, stopConsoleBuildHandler);
        }
		
		override protected function onProjectPathsValidated(paths:Array):void
		{
			if (paths)
			{
				isProjectHasInvalidPaths = true;
				error("Following path(s) are invalid or does not exists:\n"+ paths.join("\n"));
			}
		}

        override public function start(args:Vector.<String>, buildDirectory:*, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
        {
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!mavenPath)
            {
                error("Specify path to Maven folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.maven::MavenBuildPlugin"));
                return;
            }

            warning("Starting Maven build...");
			
			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
            if ((model.activeProject is IJavaProject) &&
                    (model.activeProject as IJavaProject).jdkType == JavaTypes.JAVA_8)
            {
                envCustomJava.jdkPath = model.java8Path.fileBridge.nativePath;
            }
            else if ((model.activeProject is AS3ProjectVO) &&
                    (model.activeProject as AS3ProjectVO).isDominoVisualEditorProject)
            {
                envCustomJava.jdkPath = model.java8Path.fileBridge.nativePath;
            }
            else if (model.javaPathForTypeAhead)
            {
               envCustomJava.jdkPath = model.javaPathForTypeAhead.fileBridge.nativePath;
            }
            else
            {
                error("Invalid path to Java Development Kit.");
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
                return;
            }

            super.start(args, buildDirectory, envCustomJava);
            status = MavenBuildStatus.STARTED;

            print("Maven path: %s", mavenPath);
            print("Maven build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            }
        }

        override public function stop(forceStop:Boolean = false):void
        {
            super.stop(forceStop);

            status = MavenBuildStatus.STOPPED;
        }

        override public function complete():void
        {
            nativeProcess.exit();
            running = false;

            status = MavenBuildStatus.COMPLETE;
        }

        protected function prepareStart(buildId:String, preArguments:Array, arguments:Array, buildDirectory:FileLocation):void
        {
            dispatcher.dispatchEvent(new ConsoleEvent(ConsoleEvent.SHOW_CONSOLE));

            if (!buildDirectory || !buildDirectory.fileBridge.exists)
            {
                warning("Maven build directory has not been specified or is invalid.");
                dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Maven Build"));
                return;
            }

            if (arguments.length == 0)
            {
                warning("Specify Maven commands (Ex. clean install)");
                dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Maven Build"));
                return;
            }
			
			if (!ConsoleBuildPluginBase.checkRequireJava())
			{
				clearOutput();
				error("Error: "+ model.activeProject.name +" configures to build with JDK version is not present.");
				return;
			}
			
			checkProjectForInvalidPaths(model.activeProject);
			if (isProjectHasInvalidPaths)
			{
				return;
			}

            var args:Vector.<String> = this.getConstantArguments();
            if (arguments.length > 0)
            {
                var preArgs:String = preArguments.length > 0 ?
                        preArguments.join(" && ").concat(" && ")
                        : "";
                var commandLine:String = arguments.join(" ");
                var fullCommandLine:String = preArgs.concat(UtilsCore.getMavenBinPath(), " ", commandLine);

                args.push(fullCommandLine);
            }

            start(args, buildDirectory);
        }

        override protected function startConsoleBuildHandler(event:Event):void
        {
            super.startConsoleBuildHandler(event);

			this.isProjectHasInvalidPaths = false;
            this.status = 0;
            this.buildId = this.getBuildId(event);
            var preArguments:Array = this.getPreCommandLine(event);
            var arguments:Array = this.getCommandLine(event);
            var buildDirectory:FileLocation = this.getBuildDirectory(event);

            prepareStart(this.buildId, preArguments, arguments, buildDirectory);
        }

        // public function startConsoleBuildHandlerInstall (event:Event):void
        // {
        //     super.startConsoleBuildHandler(event);

		// 	this.isProjectHasInvalidPaths = false;
        //     this.status = 0;
        //     this.buildId = this.getBuildId(event);
        //     var preArguments:Array =this.getPreCommandLine(event);
        //     var arguments:Array = ["clean install"];
        //     var buildDirectory:FileLocation = this.getBuildDirectory(event);

        //     prepareStart(this.buildId, preArguments, arguments, buildDirectory);
        // }

        override protected function stopConsoleBuildHandler(event:Event):void
        {
            super.stopConsoleBuildHandler(event);

            stop(true);
        }

        override protected function onNativeProcessStandardOutputData(event:ProgressEvent):void
        {
            var data:String = getDataFromBytes(nativeProcess.standardOutput);
            processOutput(data);
        }

        override protected function onNativeProcessIOError(event:IOErrorEvent):void
        {
            super.onNativeProcessIOError(event);

            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
            var data:String = getDataFromBytes(nativeProcess.standardError);
            processOutput(data);

            if (status == MavenBuildStatus.COMPLETE)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
                this.status = 0;
                running = false;
            }
        }

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);

            if (!stopWithoutMessage)
            {
                var info:String = isNaN(event.exitCode) ?
                        "Maven build has been terminated." :
                        "Maven build has been terminated with exit code: " + event.exitCode;

                warning(info);
            }

            stopWithoutMessage = false;
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

            if (status == MavenBuildStatus.COMPLETE)
            {
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
                this.status = 0;
            }
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
            dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_TERMINATED, this.buildId, MavenBuildStatus.STOPPED));
        }

        protected function processOutput(data:String):void
        {
            if (buildFailed(data) || data.match(ERROR))
            {
                error("%s", data);
            }
            else if (data.match(WARNING))
            {
                warning("%s", data);
            }
            else
            {
                print("%s", data);
                buildSuccess(data);
            }
        }

        protected function buildFailed(data:String):Boolean
        {
            var hasBuildFailed:Boolean = false;

            if (data.match(BUILD_FAILURE))
            {
                deferredStop();
                hasBuildFailed = true;
            }
            else if (data.match(BUILD_FAILED))
            {
                stop();
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
                hasBuildFailed = true;
            }

            return hasBuildFailed;
        }

        protected function buildSuccess(data:String):void
        {
            if (data.match(BUILD_SUCCESS))
            {
                stopWithoutMessage = true;
                complete();
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

            return args;
        }

        private function getBuildId(event:Event):String
        {
            var mavenBuildEvent:MavenBuildEvent = event as MavenBuildEvent;
            if (mavenBuildEvent)
            {
                return mavenBuildEvent.buildId;
            }

            return null;
        }

        private function getPreCommandLine(event:Event):Array
        {
            var mavenBuildEvent:MavenBuildEvent = event as MavenBuildEvent;
            if (mavenBuildEvent)
            {
                return mavenBuildEvent.preCommands;
            }

            return [];
        }

        private function getCommandLine(event:Event):Array
        {
            var mavenBuildEvent:MavenBuildEvent = event as MavenBuildEvent;
            if (mavenBuildEvent)
            {
                return mavenBuildEvent.commands;
            }

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                return project["mavenBuildOptions"].getCommandLine();
            }

            return [];
        }

        private function getBuildDirectory(event:Event):FileLocation
        {
            var mavenBuildEvent:MavenBuildEvent = event as MavenBuildEvent;
            if (mavenBuildEvent)
            {
                return new FileLocation(mavenBuildEvent.buildDirectory);
            }

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                if (project["mavenBuildOptions"].buildPath)
                {
                    return new FileLocation(project["mavenBuildOptions"].buildPath);
                }
            }

            return null;
        }

        private function deferredStop():void
        {
            var stopDelay:uint = setTimeout(function():void {
                stop();
                dispatcher.dispatchEvent(new MavenBuildEvent(MavenBuildEvent.MAVEN_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
                clearTimeout(stopDelay);
            }, 800);
        }
    }
}
