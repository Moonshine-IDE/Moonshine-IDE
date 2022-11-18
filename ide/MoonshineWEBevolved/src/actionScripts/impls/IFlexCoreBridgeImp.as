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
package actionScripts.impls
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.IVisualElement;
	import mx.managers.PopUpManager;

	import actionScripts.controllers.DataAgent;
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.ChangeLineEncodingEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFlexCoreBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.interfaces.IModulesFinder;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.importer.FlashDevelopImporter;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.actionscript.as3project.vo.MXMLProjectVO;
	import actionScripts.plugin.actionscript.mxmlc.MXMLCPlugin;
	import actionScripts.plugin.console.ConsolePlugin;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.core.compiler.ProjectActionEvent;
	import actionScripts.plugin.findResources.FindResourcesPlugin;
	import actionScripts.plugin.findreplace.FindReplacePlugin;
	import actionScripts.plugin.help.HelpPlugin;
	import actionScripts.plugin.project.ProjectPlugin;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.plugin.settings.SettingsPlugin;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.splashscreen.SplashScreenPlugin;
	import actionScripts.plugin.syntax.AS3SyntaxPlugin;
	import actionScripts.plugin.syntax.CSSSyntaxPlugin;
	import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
	import actionScripts.plugin.syntax.JSSyntaxPlugin;
	import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
	import actionScripts.plugin.syntax.XMLSyntaxPlugin;
	import actionScripts.plugin.templating.TemplatingPlugin;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.URLDescriptorVO;
	import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;

	import components.popup.Authentication;
	import components.popup.AuthenticationPopUp;

	public class IFlexCoreBridgeImp implements IFlexCoreBridge
	{
		public var activeType:uint = AS3ProjectPlugin.AS3PROJ_AS_AIR;

		private var authPopup: AuthenticationPopUp;
		private var isActionProject:Boolean;
		private var loader:DataAgent;
		private var templateLookup:Object = {};

		//--------------------------------------------------------------------------
		//
		//  INTERFACE METHODS
		//
		//--------------------------------------------------------------------------

		public function parseFlashDevelop(project:AS3ProjectVO=null, file:FileLocation=null, projectName:String=null):AS3ProjectVO
		{
			return FlashDevelopImporter.parse(project);
		}
		public function convertFlashDevelopToDomino(file:FileLocation=null):void
		{

		}

		public function parseFlashBuilder(file:FileLocation):AS3ProjectVO
		{
			return null;
		}

		public function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):void
		{

		}

		public function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):void
		{

		}

		public function testFlashDevelop(file:Object):FileLocation
		{
			return null;
		}

		public function testFlashBuilder(file:Object):FileLocation
		{
			return null;
		}

		public function updateFlashPlayerTrustContent(value:FileLocation):void
		{

		}

		public function getSDKInstallerView():IFlexDisplayObject
		{
			return null;
		}

		public function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void
		{

		}

		public function reAdjustApplicationSize(width:Number=NaN, height:Number=NaN):void
		{

		}

		public function createProject(event:NewProjectEvent):void
		{

		}

		public function importArchiveProject():void
		{

		}

		public function getComponentByType(type:String):Object
		{
			return null;
		}

		public function createAS3Project(event:NewProjectEvent):void
		{
			authPopup = new AuthenticationPopUp();
			PopUpManager.addPopUp(authPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
			PopUpManager.centerPopUp(authPopup);
			authPopup.addEventListener(Authentication.SUCCESS,authSuccessHandler);
			authPopup.addEventListener(Authentication.CANCEL,authCancelHandler);

			function authSuccessHandler(evt:Event):void
			{
				var project:Object = new Object();

				if(event.projectFileEnding == "Actionscript Project (SWF, Desktop)")
				{
					project.projectName = "NewActionScript";
					project.ProjectType = "ActionScript";
				}
				else if(event.projectFileEnding == "Flex Browser Project (SWF)")
				{
					project.projectName = "TestWeb";
					project.ProjectType = "FlexWeb";
				}
				else if(event.projectFileEnding == "Flex Desktop Project (MacOS, Windows)")
				{
					project.projectName = "TestAIR";
					project.ProjectType = "FlexAIR";
				}
				else if(event.projectFileEnding == "Flex Mobile Project (iOS, Android)")
				{
					project.projectName = "TestMobile";
					project.ProjectType = "FlexMobile";
				}
				else if(event.projectFileEnding == "HaXe SWF Project")
				{
					project.projectName = "TestHaxeProject";
					project.ProjectType = "HaxeSWF";
				}
				else if(event.projectFileEnding == "Flex Browser Project (FlexJS)")
				{
					project.projectName = "TestFlexJSProject";
					project.ProjectType = "FlexJS";
				}

				var settingsView:SettingsView = new SettingsView();
				settingsView.Width = 230;
				settingsView.defaultSaveLabel = "Create";

				settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
				settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);

				settingsView.addCategory("");

				// Remove spaces from project name
				project.projectName = project.projectName.replace(/ /g, "");

				var settings:SettingsWrapper = new SettingsWrapper("Name & Location", Vector.<ISetting>([
					new StaticLabelSetting("New " + event.projectFileEnding),
					new StringSetting(project, 'projectName', 'Project Name', 'a-zA-Z0-9._') // No space input either plx
				]));

				if (event.projectFileEnding.indexOf("Actionscript Project") != -1)
				{
					var nvps:Vector.<NameValuePair> = Vector.<NameValuePair>([
						new NameValuePair("AIR", AS3ProjectPlugin.AS3PROJ_AS_AIR),
						new NameValuePair("Web", AS3ProjectPlugin.AS3PROJ_AS_WEB)
					]);
					isActionProject = true;
					settings.getSettingsList().push(new MultiOptionSetting(this, "activeType", "Select Project Type", nvps));
				}
				else
				{
					isActionProject = false;
				}

				settingsView.addSetting(settings, "");

				settingsView.label = "New Project";
				settingsView.associatedData = project;

				authCancelHandler(null);

				GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(settingsView)
				);
			}

			function authCancelHandler(evt:Event):void
			{
				authPopup.removeEventListener(Authentication.SUCCESS,authSuccessHandler);
				authPopup.removeEventListener(Authentication.CANCEL,authCancelHandler);
				PopUpManager.removePopUp(authPopup);
				authPopup = null;
			}
		}

		public function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Boolean=false):void
		{
			loader = new DataAgent(URLDescriptorVO.PROJECT_REMOVE, onProjectRemoveSuccess, onProjectRemoveFault, {projectName:projectWrapper.name});

			/*
			 * @local
			 * we need to reuse owner method parameters
			 */
			function onProjectRemoveSuccess(value:Object, message:String=null):void
			{
				onProjectRemoveFault(null);
				finishHandler(projectWrapper);
			}
			function onProjectRemoveFault(message:String):void
			{
				loader = null;
			}
		}

		public function getCorePlugins():Array
		{
			return [SettingsPlugin,
				ProjectPlugin,
				FindReplacePlugin,
				RecentlyOpenedPlugin,
				HelpPlugin,
				TemplatingPlugin,
				ConsolePlugin
				];
		}

		public function getDefaultPlugins():Array
		{
			return [MXMLCPlugin,
				AS3ProjectPlugin,
				AS3SyntaxPlugin,
				CSSSyntaxPlugin,
				HTMLSyntaxPlugin,
				JSSyntaxPlugin,
				MXMLSyntaxPlugin,
				XMLSyntaxPlugin,
				SplashScreenPlugin
				];
		}

		public function getPluginsNotToShowInSettings():Array
		{
			return [HelpPlugin, ProjectPlugin, FindReplacePlugin, AS3ProjectPlugin, RecentlyOpenedPlugin, TemplatingPlugin, MXMLCPlugin];
		}

		public function getQuitMenuItem():MenuItem
		{
			return null;
		}

		public function getSettingsMenuItem():MenuItem
		{
			return (new MenuItem("Settings",null, null, SettingsEvent.EVENT_OPEN_SETTINGS, ",", [Keyboard.COMMAND], ',', [Keyboard.CONTROL]));
		}

		public function getAboutMenuItem():MenuItem
		{
			return (new MenuItem("About", null, null, MenuPlugin.EVENT_ABOUT));
			//return null;
		}

		public function getTourDeView():IPanelWindow
		{
			return null;
		}

		public function getTourDeEditor(swfSource:String):BasicTextEditor
		{
			return null;
		}

		public function getNewAntBuild():IFlexDisplayObject
		{
			return null;
		}

		public function getWindowsMenu():Vector.<MenuItem>
		{
			return (Vector.<MenuItem>([
				new MenuItem("File", [
					new MenuItem("New"),
					new MenuItem(null),
					new MenuItem("Save",null, null, MenuPlugin.MENU_SAVE_EVENT,
						's', [Keyboard.COMMAND],
						's', [Keyboard.CONTROL]),
					new MenuItem("Save As...",null, null, MenuPlugin.MENU_SAVE_AS_EVENT,
						's', [Keyboard.COMMAND, Keyboard.SHIFT],
						's', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem("Close", null, null, CloseTabEvent.EVENT_CLOSE_TAB,
						'w', [Keyboard.COMMAND],
						'w', [Keyboard.CONTROL]),
					new MenuItem(null),
					new MenuItem("Line Endings", [
						new MenuItem("Windows (CRLF - \\r\\n)", null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN),
						new MenuItem("UNIX (LF - \\n)", null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX),
						new MenuItem("OS9 (CR - \\r)", null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
					])
				]),
				new MenuItem("Edit", [
					new MenuItem("Find", null, null, FindReplacePlugin.EVENT_FIND_NEXT,
					'f', [Keyboard.COMMAND],
					'f', [Keyboard.CONTROL]),
					new MenuItem("Find previous", null, null, FindReplacePlugin.EVENT_FIND_PREV,
						'f', [Keyboard.COMMAND, Keyboard.SHIFT],
						'f', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(null),
					new MenuItem("Find Resource", null, null, FindResourcesPlugin.EVENT_FIND_RESOURCES,
						'r', [Keyboard.COMMAND, Keyboard.SHIFT],
						'r', [Keyboard.COMMAND, Keyboard.SHIFT])
				]),
				new MenuItem("View",[
					new MenuItem('Project view', null, null, ProjectEvent.SHOW_PROJECT_VIEW)
				]),
				new MenuItem("Project",[
					new MenuItem("Open/Import Flex Project", null, null, ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT),
					new MenuItem(null),
					new MenuItem("Build Project", null, null, ActionScriptBuildEvent.BUILD,
						'b', [Keyboard.COMMAND],
						'b', [Keyboard.CONTROL]),
					new MenuItem("Clean Project", null, null, ProjectActionEvent.CLEAN_PROJECT)

				]),
				new MenuItem("Help",[
					new MenuItem('About', null, null, MenuPlugin.EVENT_ABOUT)])
			]));
		}

		public function getHTMLView(url:String):DisplayObject
		{
			return null;
		}

		public function getAccessManagerPopup():IFlexDisplayObject
		{
			return null;
		}

		public function getSoftwareInformationView():IVisualElement
		{
			return null;
		}

		public function getJavaPath(completionHandler:Function):void
		{

		}

		public function exitApplication():void
		{
		}

		public function removeExAttributesTo(path:String):void
		{
		}

		public function startTypeAheadWithJavaPath(path:String):void
		{

		}

		public function getExternalEditors():ArrayCollection
		{
			return null;
		}

		public function get runtimeVersion():String
		{
			return "0";
		}

		public function get version():String
		{
			return IDEModel.getInstance().version;
		}

		public function get defaultInstallationPathSDKs():String
		{
			return null;
		}

		public function get vagrantMenuOptions():Array
		{
			return null;
		}

		public function setMSDKILocalPathConfig():void
		{
		}

		public function isValidExecutableBy(type:String, originPath:String, validationPath:Array=null):Boolean
		{
			return false;
		}

		public function updateToCurrentEnvironmentVariable():void
		{

		}

		public function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDKs:EnvironmentUtilsCusomSDKsVO=null, withCommands:Array=null):void
		{

		}

		public function generateTabularRoyaleProject():void
		{

		}

		public function generateCRUDJavaAgents():void
		{

		}

		public function generateJavaAgentsVisualEditor(components:Array):void
		{
		
		}

		public function getModulesFinder():IModulesFinder
		{
			return null;
		}

		public function getJavaVersion(javaPath:String=null, onComplete:Function=null):void
		{

		}

		public function checkRequireJava(project:ProjectVO=null):Boolean
		{
			return false;
		}

		public function searchAntFile(insideProject:ProjectVO):ArrayCollection
		{
			return (new ArrayCollection());
		}
		
		public function getTerminalThemeList():Array
		{
			return null;
		}
		
		public function getDominoFormBuilderWrapper(file:FileLocation, project:OnDiskProjectVO=null):IContentWindow
		{
			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE LISTENERS
		//
		//--------------------------------------------------------------------------

		private function createClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;

			settings.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, createSave);

			delete templateLookup[settings.associatedData];

			GlobalEventDispatcher.getInstance().dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.target as DisplayObject)
			);
		}

		private function createSave(event:Event):void
		{
			//call Bing service fro create Project
			var view:SettingsView = event.target as SettingsView;
			var projectData:Object = view.associatedData as Object;
			var projectSubType: String;

			// determines air project
			if (isActionProject)
			{
				if (activeType == AS3ProjectPlugin.AS3PROJ_AS_AIR) projectSubType = "air";
				else if (activeType == AS3ProjectPlugin.AS3PROJ_AS_WEB) projectSubType = "web";
			}

			loader = new DataAgent(URLDescriptorVO.CREATE_NEW_PROJECT, onProjectCreationSuccess, onSaveFault, {projectName:projectData.projectName, projectType:projectData.ProjectType, projectSubType: projectSubType});

			// Close settings view
			createClose(event);

			function onProjectCreationSuccess(value:Object, message:String=null):void
			{
				// call get project list service from server
				var jsonObj:Object = JSON.parse(String(value));
				if (!jsonObj ) return;

				if(jsonObj.CreateActionExcuteStatus=="Success")
				{
					var activeProj:MXMLProjectVO = new MXMLProjectVO(URLDescriptorVO.PROJECT_DIR + jsonObj.ProjectPath, projectData.projectName);
					activeProj.projectName = projectData.projectName;
					activeProj.projectRemotePath = jsonObj.ProjectPath;
					IDEModel.getInstance().activeProject = activeProj;
					loader = null;

					GlobalEventDispatcher.getInstance().dispatchEvent(
						new ProjectEvent(ProjectEvent.ADD_PROJECT, activeProj)
					);
				}
				else
				{
					//Message for create project error
				}
			}

			function onSaveFault(message:String):void
			{
				loader = null;
			}
		}
	}
}
