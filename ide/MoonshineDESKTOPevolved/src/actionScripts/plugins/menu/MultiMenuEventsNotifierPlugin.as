////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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