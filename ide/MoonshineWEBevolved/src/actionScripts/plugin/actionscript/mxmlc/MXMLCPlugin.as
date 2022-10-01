////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.actionscript.mxmlc
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.URLDescriptorVO;
	
	import components.popup.SelectOpenedProject;
	import components.views.project.TreeView;
	
	public class MXMLCPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String			{ return "MXMLC Compiler Plugin"; }
		override public function get author():String		{ return "Miha Lunar & Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.mxmlc'); }
		
		public var defaultFlexSDK:String
		public var incrementalCompile:Boolean = true;
		protected var runAfterBuild:Boolean;
		
		private var cmdFile:FileLocation;
		private var loader: DataAgent;
		private var	tempObj:Object;
		private var selectProjectPopup:SelectOpenedProject;
		
		public function get flexSDK():FileLocation
		{
			return currentSDK;
		}
		
		private var exiting:Boolean = false;
		
		private var targets:Dictionary;
		
		private var currentSDK:FileLocation = flexSDK;
		
		/** Project currently under compilation */
		private var currentProject:ProjectVO;
		private var queue:Vector.<String> = new Vector.<String>();
		private var errors:String = "";
		
		private var _instance:MXMLCPlugin;
		
		public function MXMLCPlugin() 
		{
		}
		
		override public function activate():void 
		{
			super.activate();
			
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_RUN, buildAndRun);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_AND_DEBUG, buildAndRun);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD, build);
			dispatcher.addEventListener(ActionScriptBuildEvent.BUILD_RELEASE, buildRelease);
			
			tempObj = new Object();
			tempObj.callback = buildCommand;
			tempObj.commandDesc = "You use the application compiler to compile SWF files from your ActionScript and MXML source files.  To invoke the application compiler with Flex SDK, you use the mxmlc command-line utility You use the application compiler to compile SWF files from your ActionScript and MXML source files.  To invoke the application compiler with Flex SDK, you use the mxmlc command-line utility";
			registerCommand('build',tempObj);
			
			tempObj = new Object();
			tempObj.callback = runCommand;
			tempObj.commandDesc = "Run Flex application";
			registerCommand('run',tempObj);
			
			tempObj = new Object();
			tempObj.callback = releaseCommand;
			tempObj.commandDesc = "Release Flex application";
			registerCommand('release',tempObj);
			
			reset();
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			
			reset();
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new PathSetting(this,'defaultFlexSDK', 'Default Flex SDK', true),
				new BooleanSetting(this,'incrementalCompile', 'Incremental Compilation')
			])
		}
		
		private function buildCommand(args:Array):void
		{
			build(null, false);
		}
		
		private function runCommand(args:Array):void
		{
			build(null, true);
		}
		
		private function releaseCommand(args:Array):void
		{
			build(null, false, true);
		}
		
		private function reset():void 
		{
			targets = new Dictionary();
		}
		
		private function buildAndRun(e:Event):void
		{
			build(e, true);	
		}
		
		private function buildRelease(e:Event):void
		{
			build(e, false, true);
		}
		
		private function build(e:Event, runAfterBuild:Boolean=false, release:Boolean=false):void 
		{
			// check if there is multiple projects were opened in tree view
			if (model.projects.length > 1)
			{
				// check if user has selection/select any particular project or not
				if (model.mainView.isProjectViewAdded)
				{
					var tmpTreeView:TreeView = model.mainView.getTreeViewPanel();
					var projectReference:AS3ProjectVO = tmpTreeView.getProjectBySelection() as AS3ProjectVO;
					if (projectReference)
					{
						proceedWithBuild(projectReference as ProjectVO);
						return;
					}
				}
				
				// if above is false
				selectProjectPopup = new SelectOpenedProject();
				PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(selectProjectPopup);
				selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
			}
			else if (model.projects.length != 0)
			{
				proceedWithBuild(model.projects[0] as ProjectVO);
			}
			
			/*
			 * @local
			 */
			function onProjectSelected(event:Event):void
			{
				proceedWithBuild(selectProjectPopup.selectedProject);
				onProjectSelectionCancelled(null);
			}
			
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
			
			/*
			* runs the build process
			*/
			function proceedWithBuild(activeProject:ProjectVO):void
			{
				this.runAfterBuild = runAfterBuild;
				
				// Don't compile if there is no project. Don't warn since other compilers might take the job.
				if (!activeProject) return  
				compile(activeProject, release);
			}
		}

		private function compile(pvo:ProjectVO, release:Boolean=false):void 
		{
			//clearOutput();
			dispatcher.dispatchEvent(new MXMLCPluginEvent(ActionScriptBuildEvent.PREBUILD, currentSDK));
			
			currentProject = pvo;
			if (!loader)
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, "Building project: "+ currentProject.name +". Invoking compiler on remote server..."));
				loader = new DataAgent(URLDescriptorVO.PROJECT_COMPILE+"?projectName="+currentProject.name, onBuildCompleted, onFault);
			}
			else
			{
				Alert.show("Build is in progress. You can follow the status on the console.");
			}
		}
		
		private function onBuildCompleted(value:Object, message:String=null):void
		{
			// probable termination
			if (!value) return;
			var jsonObj:Object = JSON.parse(String(value));
			
			ConsoleOutputter.DEBUG = true;
			debug("Compiler output: %s", jsonObj.output);
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, "Result: "+ jsonObj.result +" in "+ (int(jsonObj.totalTime)/60000).toFixed(2) +" Minutes."));
			
			loader = null;
		}
		
		
		private function onFault(message:String):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, "Server error while build!"));
			loader = null;
		}
	}
}