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
package actionScripts.plugins.menu
{
	import flash.events.Event;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.core.compiler.FlashModuleBuildEvent;
	import actionScripts.plugin.core.compiler.JavaScriptBuildEvent;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	
	public class MultiMenuEventsNotifierPlugin extends PluginBase
	{
		override public function get name():String			{ return "MultiMenuEventsNotifierPlugin"; }
		
		override public function activate():void 
		{
			if (activated) return;
			
			super.activate();
			
			dispatcher.addEventListener(ProjectActionEvent.BUILD, onProjectBuild, false, 0, true);
			dispatcher.addEventListener(ProjectActionEvent.BUILD_AND_RUN, onProjectBuildAndRun, false, 0, true);
			dispatcher.addEventListener(ProjectActionEvent.BUILD_RELEASE, onProjectBuildAndRelease, false, 0, true);
			dispatcher.addEventListener(ProjectActionEvent.BUILD_AND_DEBUG, onProjectBuildDebug, false, 0, true);
		}
		
		private function onProjectBuild(event:Event):void
		{
			if (!model.activeProject)
			{
				return;
			}
			
			if (isMenuOfProjectType(ProjectMenuTypes.JS_ROYALE, model.activeProject.menuType))
			{
				buildRoyale();
			}
			else if (model.activeProject is AS3ProjectVO)
			{
				buildAS3Project();
			}
		}
		
		private function onProjectBuildAndRun(event:Event):void
		{
			if (!model.activeProject)
			{
				return;
			}
			
			if (isMenuOfProjectType(ProjectMenuTypes.JS_ROYALE, model.activeProject.menuType))
			{
				buildAndRunRoyale();
			}
			else if (model.activeProject is AS3ProjectVO)
			{
				buildAndRunAS3Project();
			}
		}
		
		private function onProjectBuildAndRelease(event:Event):void
		{
			if (!model.activeProject)
			{
				return;
			}
			
			if (isMenuOfProjectType(ProjectMenuTypes.JS_ROYALE, model.activeProject.menuType))
			{
				buildAndReleaseRoyale();
			}
			else if (model.activeProject is AS3ProjectVO)
			{
				buildAndReleaseAS3Project();
			}
		}
		
		private function onProjectBuildDebug(event:Event):void
		{
			if (!model.activeProject)
			{
				return;
			}
			
			if (isMenuOfProjectType(ProjectMenuTypes.JS_ROYALE, model.activeProject.menuType))
			{
				debugRoyale();
			}
			else
			{
				if ((model.activeProject is AS3ProjectVO) && hasModules())
				{
					dispatcher.dispatchEvent(new Event(FlashModuleBuildEvent.BUILD_AND_DEBUG));
					return;
				}
				
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_AND_DEBUG));
			}
		}
		
		private function isMenuOfProjectType(type:String, value:String):Boolean
		{
			var tmpSplit:Array = value.split(",");
			var isFound:Boolean = tmpSplit.some(function(element:String, index:int, arr:Array):Boolean
			{
				if (element == type)
				{
					return true;
				}
				return false;
			});
			
			return isFound;
		}
		
		protected function buildRoyale():void
		{
			var targetPlatform:String = (model.activeProject as AS3ProjectVO).buildOptions.targetPlatform;
			if (targetPlatform.toLowerCase() == "js")
			{
				dispatcher.dispatchEvent(new Event(JavaScriptBuildEvent.BUILD));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD));
			}
		}
		
		protected function buildAndRunRoyale():void
		{
			var targetPlatform:String = (model.activeProject as AS3ProjectVO).buildOptions.targetPlatform;
			if (targetPlatform.toLowerCase() == "js")
			{
				dispatcher.dispatchEvent(new Event(JavaScriptBuildEvent.BUILD_AND_RUN));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_AND_RUN));
			}
		}
		
		protected function buildAndReleaseRoyale():void
		{
			var targetPlatform:String = (model.activeProject as AS3ProjectVO).buildOptions.targetPlatform;
			if (targetPlatform.toLowerCase() == "js")
			{
				dispatcher.dispatchEvent(new Event(JavaScriptBuildEvent.BUILD_RELEASE));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_RELEASE));
			}
		}
		
		protected function debugRoyale():void
		{
			var targetPlatform:String = (model.activeProject as AS3ProjectVO).buildOptions.targetPlatform;
			if (targetPlatform.toLowerCase() == "js")
			{
				dispatcher.dispatchEvent(new Event(JavaScriptBuildEvent.BUILD_AND_DEBUG));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_AND_DEBUG));
			}
		}
		
		protected function buildAS3Project():void
		{
			if (hasModules())
			{
				dispatcher.dispatchEvent(new Event(FlashModuleBuildEvent.BUILD));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD));
			}
		}
		
		protected function buildAndRunAS3Project():void
		{
			if (hasModules())
			{
				dispatcher.dispatchEvent(new Event(FlashModuleBuildEvent.BUILD_AND_RUN));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_AND_RUN));
			}
		}
		
		protected function buildAndReleaseAS3Project():void
		{
			if (hasModules())
			{
				dispatcher.dispatchEvent(new Event(FlashModuleBuildEvent.BUILD_RELEASE));
			}
			else
			{
				dispatcher.dispatchEvent(new Event(ActionScriptBuildEvent.BUILD_RELEASE));
			}
		}
		
		private function hasModules():Boolean
		{
			return ((model.activeProject as AS3ProjectVO).flashModuleOptions.modulePaths.length > 0);
		}
	}
}