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
package actionScripts.plugins.as3project.mxmlc
{
	import flash.events.Event;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.compiler.FlashModuleBuildEvent;
	import actionScripts.valueObjects.FlashModuleVO;
	import actionScripts.valueObjects.ProjectVO;

	public class MXMLCFlashModulePlugin extends MXMLCPlugin
	{
		override public function get name():String			{ return "MXMLCFlashModulePlugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Handler for Flash Modules Compilations"; }
		
		private var modulesQueue:Array;
		private var compileFunctionForMainApplication:Function;
		private var currentModule:FlashModuleVO;
		private var currentModuleConfigFile:FileLocation;
		private var isMainApplicationCallCompleted:Boolean;
		private var isRunAfterBuild:Boolean;
		private var isDebugAfterBuild:Boolean;
		private var isReleaseAfterBuild:Boolean;
		
		override public function activate():void
		{
			if (activated) return;
			
			super.activate();
			
			dispatcher.addEventListener(FlashModuleBuildEvent.BUILD, onProjectBuild, false, 0, true);
			dispatcher.addEventListener(FlashModuleBuildEvent.BUILD_AND_RUN, onProjectBuildAndRun, false, 0, true);
			dispatcher.addEventListener(FlashModuleBuildEvent.BUILD_RELEASE, onProjectBuildAndRelease, false, 0, true);
			dispatcher.addEventListener(FlashModuleBuildEvent.BUILD_AND_DEBUG, onProjectBuildDebug, false, 0, true);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			
			dispatcher.removeEventListener(FlashModuleBuildEvent.BUILD_AND_RUN, onProjectBuildAndRun);
			dispatcher.removeEventListener(FlashModuleBuildEvent.BUILD_AND_DEBUG, onProjectBuildDebug);
			dispatcher.removeEventListener(FlashModuleBuildEvent.BUILD, onProjectBuild);
			dispatcher.removeEventListener(FlashModuleBuildEvent.BUILD_RELEASE, onProjectBuildAndRelease);
		}
		
		protected function onProjectBuild(event:Event):void
		{
			isRunAfterBuild = false;
			isDebugAfterBuild = false;
			isReleaseAfterBuild = false;
			
			build(event);
		}
		
		protected function onProjectBuildAndRun(event:Event):void
		{
			isRunAfterBuild = true;
			isDebugAfterBuild = false;
			isReleaseAfterBuild = false;
			
			buildAndRun(event);
		}
		
		protected function onProjectBuildAndRelease(event:Event):void
		{
			isRunAfterBuild = false;
			isDebugAfterBuild = false;
			isReleaseAfterBuild = true;
			
			buildRelease(event);
		}
		
		protected function onProjectBuildDebug(event:Event):void
		{
			isRunAfterBuild = true;
			isDebugAfterBuild = true;
			isReleaseAfterBuild = false;
			
			buildAndRun(event);
		}
		
		override protected function compileRegularFlexApplication(pvo:ProjectVO, release:Boolean=false):void
		{
			// we'll compile in conditional ways from here
			if (hasModules(pvo))
			{
				currentProject = pvo;
				compileFunctionForMainApplication = super.compileRegularFlexApplication;
				initializeModuleCompilation();
				return;
			}
			
			super.compileRegularFlexApplication(pvo, release);
		}
		
		protected function initializeModuleCompilation():void
		{
			modulesQueue = (currentProject as AS3ProjectVO).flashModuleOptions.modulePaths.source.filter(function(module:FlashModuleVO, index:int, source:Array):Boolean
			{
				return (module.isSelected == true);
			});
			
			isMainApplicationCallCompleted = false;
			compileModule();
		}
		
		protected function compileModule():void
		{
			if (modulesQueue.length != 0)
			{
				currentModule = modulesQueue.shift() as FlashModuleVO;
				currentModuleConfigFile = (currentProject as AS3ProjectVO).config.writeForFlashModule(currentProject as AS3ProjectVO, currentModule.sourcePath);
				warning("Compiling module: "+ currentModule.sourcePath.fileBridge.nameWithoutExtension);
				compileFunctionForMainApplication(currentProject, release);
			}
			else if (!isMainApplicationCallCompleted)
			{
				dispose();
				isMainApplicationCallCompleted = true;
				warning("Compiling main application");
				compileFunctionForMainApplication(currentProject, release);
			}
		}
		
		override protected function compile(pvo:AS3ProjectVO, release:Boolean=false):String 
		{
			var relativeMainConfigPath:String = pvo.folderLocation.fileBridge.getRelativePath(pvo.config.file);
			var compileStr:String = super.compile(pvo, release);
			
			if (currentModuleConfigFile)
			{
				compileStr = compileStr.replace(
					relativeMainConfigPath, currentProject.folderLocation.fileBridge.getRelativePath(
						currentModuleConfigFile, true
					)
				);
				
				// requires to overcome multi triggers of SWF
				runAfterBuild = false;
				debugAfterBuild = false;
				isReleaseAfterBuild = false;
			}
			else
			{
				runAfterBuild = isRunAfterBuild;
				debugAfterBuild = isDebugAfterBuild;
				release = isReleaseAfterBuild;
			}
			
			return compileStr;
		}
		
		override protected function projectBuildSuccessfully():void
		{
			super.projectBuildSuccessfully();
			compileModule();
		}
		
		private function hasModules(pvo:ProjectVO):Boolean
		{
			return ((pvo as AS3ProjectVO).flashModuleOptions.modulePaths.length > 0);
		}
		
		private function dispose():void
		{
			currentModule = null;
			currentModuleConfigFile = null;
		}
	}
}