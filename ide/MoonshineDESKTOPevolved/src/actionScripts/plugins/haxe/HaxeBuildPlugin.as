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
package actionScripts.plugins.haxe
{
    import actionScripts.interfaces.ICustomCommandRunProvider;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugins.build.ConsoleBuildPluginBase;
    import actionScripts.utils.HelperUtils;
    import actionScripts.valueObjects.ComponentTypes;
    import actionScripts.valueObjects.ComponentVO;
    import actionScripts.valueObjects.ConstantsCoreVO;

    import flash.events.Event;

    public class HaxeBuildPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
    {
		private var haxePathSetting:PathSetting;
		private var nodePathSetting:PathSetting;
		private var isProjectHasInvalidPaths:Boolean;
		private var runCommandType:String;
		
        public function HaxeBuildPlugin()
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
            return "Haxe Build Setup";
        }

        override public function get author():String
        {
            return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team";
        }

        override public function get description():String
        {
            return "Haxe Build Plugin. Esc exits.";
        }

        public function get haxePath():String
        {
            return model ? model.haxePath : null;
        }

        public function set haxePath(value:String):void
        {
            if (model.haxePath != value)
            {
                model.haxePath = value;
            }
        }

        public function get nodePath():String
        {
            return model ? model.nodePath : null;
        }

        public function set nodePath(value:String):void
        {
            if (model.nodePath != value)
            {
                model.nodePath = value;
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			haxePathSetting = new PathSetting(this, 'haxePath', 'Haxe Home', true, haxePath);
			haxePathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onHaxeSDKPathSelected, false, 0, true);
            
			nodePathSetting = new PathSetting(this, 'nodePath', 'Node.js Home', true, nodePath);
			nodePathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onNodePathSelected, false, 0, true);
			
			return Vector.<ISetting>([
				haxePathSetting,
                nodePathSetting
			]);
        }
		
		override public function onSettingsClose():void
		{
			if (haxePathSetting)
			{
				haxePathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onHaxeSDKPathSelected);
				haxePathSetting = null;
			}
		}
		
		private function onHaxeSDKPathSelected(event:Event):void
		{
			if (!haxePathSetting.stringValue) return;
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_HAXE);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_HAXE, haxePathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					haxePathSetting.setMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
				else
				{
					haxePathSetting.setMessage(null);
				}
			}
		}
		
		private function onNodePathSelected(event:Event):void
		{
			if (!nodePathSetting.stringValue) return;
			var tmpComponent:ComponentVO = HelperUtils.getComponentByType(ComponentTypes.TYPE_NODE);
			if (tmpComponent)
			{
				var isValidSDKPath:Boolean = HelperUtils.isValidSDKDirectoryBy(ComponentTypes.TYPE_NODE, nodePathSetting.stringValue, tmpComponent.pathValidation);
				if (!isValidSDKPath)
				{
					nodePathSetting.setMessage("Invalid path: Path must contain "+ tmpComponent.pathValidation +".", AbstractSetting.MESSAGE_CRITICAL);
				}
				else
				{
					nodePathSetting.setMessage(null);
				}
			}
		}

        override public function activate():void
        {
            super.activate();

			/*dispatcher.addEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.addEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);*/
        }

        override public function deactivate():void
        {
            super.deactivate();

			/*dispatcher.removeEventListener(HaxeBuildEvent.BUILD_AND_RUN, haxeBuildAndRunHandler);
			dispatcher.removeEventListener(HaxeBuildEvent.BUILD_RELEASE, haxeBuildReleaseHandler);*/
        }
		
		/*private function haxeBuildAndRunHandler(event:Event):void
		{
			this.start(new <String>[[UtilsCore.getHaxeBinPath()].join(" ")], model.activeProject.folderLocation);
		}
		
		private function haxeBuildReleaseHandler(event:Event):void
		{
			this.start(new <String>[[UtilsCore.getHaxeBinPath()].join(" ")], model.activeProject.folderLocation);
		}

		override public function start(args:Vector.<String>, buildDirectory:*):void
		{
            if (nativeProcess.running && running)
            {
                warning("Build is running. Wait for finish...");
                return;
            }

            if (!haxePath)
            {
                error("Specify path to Haxe folder.");
                stop(true);
                dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.haxe::HaxeBuildPlugin"));
                return;
            }
			
            warning("Starting Haxe build...");

			super.start(args, buildDirectory);
			
            print("Haxe build directory: %s", buildDirectory.fileBridge.nativePath);
            print("Command: %s", args.join(" "));

            var project:ProjectVO = model.activeProject;
            if (project)
            {
                dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, project.projectName, "Building "));
                dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            }
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
				warning("Haxe build has been terminated.");
			}
			else if(event.exitCode != 0)
			{
				warning("Haxe build has been terminated with exit code: " + event.exitCode);
			}
			else
			{
				success("Haxe build has completed successfully.");
			}


			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onProjectBuildTerminate);
            dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
        }

        private function onProjectBuildTerminate(event:StatusBarEvent):void
        {
            stop();
        }*/
	}
}