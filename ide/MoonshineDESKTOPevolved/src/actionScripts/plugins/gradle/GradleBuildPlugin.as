////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.gradle
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.ShowSettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.build.MavenBuildStatus;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.GradleBuildUtil;
    import actionScripts.utils.HelperUtils;
    import actionScripts.valueObjects.ComponentTypes;
    import actionScripts.valueObjects.ComponentVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.EnvironmentExecPaths;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    public class GradleBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
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
            return "Apache Gradle® Build Plugin.";
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
			onSettingsClose();
			pathSetting = new PathSetting(this, 'gradlePath', 'Gradle Home', true, gradlePath);
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
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GRADLE);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_GRADLE, pathSetting.stringValue, tmpComponent.pathValidation);
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

            dispatcher.addEventListener(GradleBuildEvent.START_GRADLE_BUILD, startConsoleBuildHandler);
            dispatcher.addEventListener(GradleBuildEvent.STOP_GRADLE_BUILD, stopConsoleBuildHandler);
			dispatcher.addEventListener(GradleBuildEvent.STOP_GRADLE_DAEMON, stopGradleDaemon);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(GradleBuildEvent.START_GRADLE_BUILD, startConsoleBuildHandler);
            dispatcher.removeEventListener(GradleBuildEvent.STOP_GRADLE_BUILD, stopConsoleBuildHandler);
			dispatcher.removeEventListener(GradleBuildEvent.STOP_GRADLE_DAEMON, stopGradleDaemon);
        }
		
		override protected function onProjectPathsValidated(paths:Array):void
		{
			if (paths)
			{
				isProjectHasInvalidPaths = true;
				error("Following path(s) are invalid or does not exists:\n"+ paths.join("\n"));
			}
		}

        override public function start(args:Vector.<String>, buildDirectory:*):void
        {
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!gradlePath)
            {
                error("Specify path to Gradle folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.gradle::GradleBuildPlugin"));
                return;
            }

            warning("Starting Gradle build...");

            super.start(args, buildDirectory);
            status = MavenBuildStatus.STARTED;

            print("Gradle path: %s", gradlePath);
            print("Gradle build directory: %s", buildDirectory.fileBridge.nativePath);
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
            if (!buildDirectory || !buildDirectory.fileBridge.exists)
            {
                warning("Gradle build directory has not been specified or is invalid.");
                dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Gradle Build"));
                return;
            }

            if (arguments.length == 0)
            {
                warning("Specify Gradle commands (Ex. clean install)");
                dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Gradle Build"));
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
                var fullCommandLine:String = preArgs.concat(EnvironmentExecPaths.GRADLE_ENVIRON_EXEC_PATH, " ", commandLine);

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
                        "Gradle build has been terminated." :
                        "Gradle build has been terminated with exit code: " + event.exitCode;

                warning(info);
            }

            stopWithoutMessage = false;
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);

            if (status == MavenBuildStatus.COMPLETE)
            {
                dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.GRADLE_BUILD_COMPLETE, this.buildId, MavenBuildStatus.COMPLETE));
                this.status = 0;
            }
			else if (status == int.MAX_VALUE)
			{
				model.gradlePath = null;
				stopGradleDaemon(null);
			}
        }
		
		private function stopGradleDaemon(event:Event):void
		{
			if (model.gradlePath && GradleBuildUtil.IS_GRADLE_STARTED)
			{
				status = int.MAX_VALUE;
				super.start(Vector.<String>([EnvironmentExecPaths.GRADLE_ENVIRON_EXEC_PATH +" --stop"]), null);
			}
			else
			{
				dispatcher.dispatchEvent(new Event(GradleBuildEvent.GRADLE_DAEMON_CLOSED));
			}
		}

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
            dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.GRADLE_BUILD_TERMINATED, this.buildId, MavenBuildStatus.STOPPED));
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
                dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.GRADLE_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
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
            var gradleBuildEvent:GradleBuildEvent = event as GradleBuildEvent;
            if (gradleBuildEvent)
            {
                return gradleBuildEvent.buildId;
            }

            return null;
        }

        private function getPreCommandLine(event:Event):Array
        {
            var gradleBuildEvent:GradleBuildEvent = event as GradleBuildEvent;
            if (gradleBuildEvent)
            {
                return gradleBuildEvent.preCommands;
            }

            return [];
        }

        private function getCommandLine(event:Event):Array
        {
            var gradleBuildEvent:GradleBuildEvent = event as GradleBuildEvent;
            if (gradleBuildEvent)
            {
                return gradleBuildEvent.commands;
            }

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                return project["gradleBuildOptions"].getCommandLine();
            }

            return [];
        }

        private function getBuildDirectory(event:Event):FileLocation
        {
            var gradleBuildEvent:GradleBuildEvent = event as GradleBuildEvent;
            if (gradleBuildEvent)
            {
                return new FileLocation(gradleBuildEvent.buildDirectory);
            }

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                if (project["gradleBuildOptions"].buildPath)
                {
                    return new FileLocation(project["gradleBuildOptions"].buildPath);
                }
            }

            return null;
        }

        private function deferredStop():void
        {
            var stopDelay:uint = setTimeout(function():void {
                stop();
                dispatcher.dispatchEvent(new GradleBuildEvent(GradleBuildEvent.GRADLE_BUILD_FAILED, this.buildId, MavenBuildStatus.FAILED));
                clearTimeout(stopDelay);
            }, 800);
        }
    }
}
