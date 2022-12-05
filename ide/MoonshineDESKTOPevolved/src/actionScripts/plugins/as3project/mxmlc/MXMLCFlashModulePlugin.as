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
			
			this._activated = true;
			//super.activate();
			
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
			if (!modulesQueue || (compileFunctionForMainApplication == null))
			{
				return;
			}
			
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