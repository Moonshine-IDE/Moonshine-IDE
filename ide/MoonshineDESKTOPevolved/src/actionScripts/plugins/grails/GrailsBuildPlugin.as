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
	import actionScripts.events.DebugActionEvent;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;

	import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    
    import actionScripts.events.ApplicationEvent;
    import actionScripts.events.CustomCommandsEvent;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.SettingsEvent;
    import actionScripts.events.ShowSettingsEvent;
    import actionScripts.events.StatusBarEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.ICustomCommandRunProvider;
    import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
    import actionScripts.plugin.actionscript.as3project.vo.GrailsBuildOptions;
    import actionScripts.plugin.build.vo.BuildActionType;
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.plugin.core.compiler.GrailsBuildEvent;
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
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
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;

    public class GrailsBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider, ICustomCommandRunProvider
    {
		private var pathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
		private var runCommandType:String;
		private var isDebugging:Boolean;
		private var isStopAppExecuted:Boolean;
		
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
            return "Grails Build Plugin.";
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
			dispatcher.addEventListener(GradleBuildEvent.RUN_COMMAND, startGradleConsoleBuildHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

			dispatcher.removeEventListener(GrailsBuildEvent.BUILD_AND_RUN, grailsBuildAndRunHandler);
			dispatcher.removeEventListener(GrailsBuildEvent.BUILD_RELEASE, grailsBuildReleaseHandler);
			dispatcher.removeEventListener(GrailsBuildEvent.RUN_COMMAND, startConsoleBuildHandler);
			dispatcher.removeEventListener(GradleBuildEvent.RUN_COMMAND, startGradleConsoleBuildHandler);
        }
		
		private function grailsBuildAndRunHandler(event:Event):void
		{
			this.startDebug(new <String>[[UtilsCore.getGrailsBinPath(), "run-app"].join(" ")], model.activeProject.folderLocation);
		}
		
		private function grailsBuildReleaseHandler(event:Event):void
		{
			this.start(new <String>[[UtilsCore.getGrailsBinPath(), "war"].join(" ")], model.activeProject.folderLocation);
		}

		private function grailsStopApp():void
		{
			this.startDebug(new <String>[[UtilsCore.getGrailsBinPath(), "stop-app"].join(" ")], model.activeProject.folderLocation);
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

		override public function start(args:Vector.<String>, buildDirectory:*, customSDKs:EnvironmentUtilsCusomSDKsVO=null):void
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
			
			isDebugging = false;
            warning("Starting Grails build...");

			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
			envCustomJava.jdkPath = ((model.activeProject as IJavaProject).jdkType == JavaTypes.JAVA_8) ?
					model.java8Path.fileBridge.nativePath : model.javaPathForTypeAhead.fileBridge.nativePath;

			super.start(args, buildDirectory, envCustomJava);
			
            print("Grails build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building ", true));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
				dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);
            }
		}

		public function startDebug(args:Vector.<String>, buildDirectory:*):void
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

			if (!ConsoleBuildPluginBase.checkRequireJava())
			{
				clearOutput();
				error("Error: "+ model.activeProject.name +" configures to build with JDK version is not present.");
				return;
			}

			isDebugging = true;
            warning("Starting Grails build...");

			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
			envCustomJava.jdkPath = ((model.activeProject as IJavaProject).jdkType == JavaTypes.JAVA_8) ?
					model.java8Path.fileBridge.nativePath : model.javaPathForTypeAhead.fileBridge.nativePath;

			super.start(args, buildDirectory, envCustomJava);
			
            print("Grails build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_STARTED, project.projectName, "Running ", true));
                dispatcher.addEventListener(DebugActionEvent.DEBUG_STOP, onProjectBuildTerminate);
				dispatcher.addEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);
            }
		}
		
		override protected function startConsoleBuildHandler(event:Event):void
		{
			super.startConsoleBuildHandler(event);
			
			runCommandType = BuildActionType.BUILD_TYPE_GRAILS;
			dispatcher.dispatchEvent(new CustomCommandsEvent(
				CustomCommandsEvent.OPEN_CUSTOM_COMMANDS_ON_SDK,
				"grails",
				model.activeProject["grailsBuildOptions"].buildActions,
				this,
				model.activeProject["grailsBuildOptions"].selectedCommand
				));
		}
		
		protected function startGradleConsoleBuildHandler(event:Event):void
		{
			runCommandType = BuildActionType.BUILD_TYPE_GRADLE;
			dispatcher.dispatchEvent(new CustomCommandsEvent(
				CustomCommandsEvent.OPEN_CUSTOM_COMMANDS_ON_SDK,
				"gradle",
				model.activeProject["gradleBuildOptions"].buildActions,
				this,
				model.activeProject["gradleBuildOptions"].selectedCommand
			));
		}
		
		public function runOrUpdate(command:BuildActionVO):void
		{
			var hasChanges:Boolean;
			
			switch (runCommandType)
			{
				case BuildActionType.BUILD_TYPE_GRAILS:
					var grailsBuildOptions:GrailsBuildOptions = (model.activeProject as GrailsProjectVO).grailsBuildOptions;
					if (grailsBuildOptions.buildActions.indexOf(command) == -1)
					{
						hasChanges = true;
						grailsBuildOptions.buildActions.push(command);
					}
					grailsBuildOptions.commandLine = command.action;
					break;
				case BuildActionType.BUILD_TYPE_GRADLE:
					var gradleBuildOptions:GradleBuildOptions = (model.activeProject as GrailsProjectVO).gradleBuildOptions;
					if (gradleBuildOptions.buildActions.indexOf(command) == -1)
					{
						hasChanges = true;
						gradleBuildOptions.buildActions.push(command);
					}
					gradleBuildOptions.commandLine = command.action;
					break;
			}
			
			this.isProjectHasInvalidPaths = false;
			var arguments:Array = this.getCommandLine();
			prepareStart(arguments, model.activeProject.folderLocation, runCommandType);
			
			// save the modified/updated list
			if (hasChanges)
			{
				(model.activeProject as GrailsProjectVO).saveSettings();
			}
		}
		
		private function getCommandLine():Array
		{
			switch (runCommandType)
			{
				case BuildActionType.BUILD_TYPE_GRAILS:
					return model.activeProject["grailsBuildOptions"].getCommandLine();
				case BuildActionType.BUILD_TYPE_GRADLE:
					return model.activeProject["gradleBuildOptions"].getCommandLine();
			}
			
			return [];
		}
		
		protected function prepareStart(arguments:Array, buildDirectory:FileLocation, commandType:String=BuildActionType.BUILD_TYPE_GRAILS):void
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
				var executable:String = (commandType == BuildActionType.BUILD_TYPE_GRAILS) ? 
					EnvironmentExecPaths.GRAILS_ENVIRON_EXEC_PATH : EnvironmentExecPaths.GRADLE_ENVIRON_EXEC_PATH;
				var commandLine:String = arguments.join(" ");
				var fullCommandLine:String = [executable, commandLine].join(" ");
				
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

			dispatcher.removeEventListener(DebugActionEvent.DEBUG_STOP, onProjectBuildTerminate);
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
			dispatcher.removeEventListener(ApplicationEvent.APPLICATION_EXIT, onApplicationExit);
            if(isDebugging)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_DEBUG_ENDED));
			}
			else
			{
            	dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			}
			isDebugging = false;

			if (!isStopAppExecuted)
			{
				isStopAppExecuted = true;
				grailsStopApp();
			}
			else
			{
				isStopAppExecuted = false;
			}
        }

        private function onProjectBuildTerminate(event:Event):void
        {
            stop();
        }

        private function onApplicationExit(event:ApplicationEvent):void
        {
			//if anything is still running, stop it before we exit to avoid
			//orphaned processes
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_TERMINATE));
		}
	}
}