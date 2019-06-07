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
package actionScripts.plugins.grails
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.ShowSettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.compiler.GrailsBuildEvent;
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
    import actionScripts.valueObjects.EnvironmentExecPaths;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    public class GrailsBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private var pathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
		
        public function GrailsBuildPlugin()
        {
            super();
        }
		
		override protected function onProjectPathsValidated(paths:Array):void
		{
			if (paths)
			{
				isProjectHasInvalidPaths = true;
				error("Following path(s) are invalid or does not exists:\n"+ paths.join("\n"));
			}
		}

        override public function get name():String
        {
            return "Grails Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";
        }

        override public function get description():String
        {
            return "Grails Build Plugin. Esc exits.";
        }

        public function get grailsPath():String
        {
            return model ? model.grailsPath : null;
        }

        public function set grailsPath(value:String):void
        {
            if (model.grailsPath != value)
            {
                model.grailsPath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'grailsPath', 'Grails Home', true, grailsPath);
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
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_GRAILS);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_GRAILS, pathSetting.stringValue, tmpComponent.pathValidation);
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

			dispatcher.addEventListener(GrailsBuildEvent.BUILD_AND_RUN, grailsBuildAndRunHandler);
			dispatcher.addEventListener(GrailsBuildEvent.BUILD_RELEASE, grailsBuildReleaseHandler);
			dispatcher.addEventListener(GrailsBuildEvent.RUN_COMMAND, startConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(GrailsBuildEvent.BUILD_AND_RUN, grailsBuildAndRunHandler);
			dispatcher.removeEventListener(GrailsBuildEvent.BUILD_RELEASE, grailsBuildReleaseHandler);
			dispatcher.removeEventListener(GrailsBuildEvent.RUN_COMMAND, startConsoleBuildHandler);
        }
		
		private function grailsBuildAndRunHandler(event:Event):void
		{
			this.start(new <String>[[UtilsCore.getGrailsBinPath(), "run-app"].join(" ")], model.activeProject.folderLocation);
		}
		
		private function grailsBuildReleaseHandler(event:Event):void
		{
			this.start(new <String>[[UtilsCore.getGrailsBinPath(), "war"].join(" ")], model.activeProject.folderLocation);
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

		override public function start(args:Vector.<String>, buildDirectory:*):void
		{
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!grailsPath)
            {
                error("Specify path to Grails folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.grails::GrailsBuildPlugin"));
                return;
            }
			
            warning("Starting Grails build...");

			super.start(args, buildDirectory);
			
            print("Grails build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            }
		}
		
		override protected function startConsoleBuildHandler(event:Event):void
		{
			super.startConsoleBuildHandler(event);
			
			this.isProjectHasInvalidPaths = false;
			var arguments:Array = this.getCommandLine(event);
			prepareStart(arguments, model.activeProject.folderLocation);
		}
		
		private function getCommandLine(event:Event):Array
		{
			var project:ProjectVO = model.activeProject;
			if (project)
			{
				return project["grailsBuildOptions"].getCommandLine();
			}
			
			return [];
		}
		
		protected function prepareStart(arguments:Array, buildDirectory:FileLocation):void
		{
			if (!buildDirectory || !buildDirectory.fileBridge.exists)
			{
				warning("Grails build directory has not been specified or is invalid.");
				dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Grails Build"));
				return;
			}
			
			if (arguments.length == 0)
			{
				warning("Specify Grails commands (Ex. clean install)");
				dispatcher.dispatchEvent(new ShowSettingsEvent(model.activeProject, "Grails Build"));
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
				var commandLine:String = arguments.join(" ");
				var fullCommandLine:String = [EnvironmentExecPaths.GRAILS_ENVIRON_EXEC_PATH, commandLine].join(" ");
				
				args.push(fullCommandLine);
			}
			
			start(args, buildDirectory);
		}

        override protected function onNativeProcessIOError(event:IOErrorEvent):void
        {
            super.onNativeProcessIOError(event);
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        override protected function onNativeProcessStandardErrorData(event:ProgressEvent):void
        {
			super.onNativeProcessStandardErrorData(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
		}

        override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
        {
            super.onNativeProcessExit(event);

			if(isNaN(event.exitCode))
			{
				warning("Grails build has been terminated.");
			}
			else if(event.exitCode != 0)
			{
				warning("Grails build has been terminated with exit code: " + event.exitCode);
			}
			else
			{
				success("Grails build has completed successfully.");
			}


			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
        }
	}
}