// ActionScript file
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
package actionScripts.plugin.actionscript.as3project.files
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ButtonSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class SaveFilesPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String { return "General"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "General options to Moonshine"; }
		
		public var resetLabel:String = "Reset to Default";
		
		private var _workspacePath:String;
		private var _isSaveFiles:Boolean = false;
		private var _openPreviouslyOpenedProjects:Boolean;
		private var _openPreviouslyOpenedProjectBranches:Boolean;
		private var _openPreviouslyOpenedFiles:Boolean;
		private var _showHiddenPaths:Boolean;

		public function SaveFilesPlugin()
		{
			super();

			openPreviouslyOpenedProjects = true;
			openPreviouslyOpenedFiles = true;
			openPreviouslyOpenedProjectBranches = true;
		}
		
		public function get isSaveFiles():Boolean
		{
			return _isSaveFiles;
		}
		public function set isSaveFiles(value:Boolean):void
		{
			_isSaveFiles = value;
			model.saveFilesBeforeBuild = value;
		}
		
		public function get workspacePath():String
		{
			return _workspacePath;
		}

		public function set workspacePath(value:String):void
		{
			_workspacePath = value;
			OSXBookmarkerNotifiers.workspaceLocation = value ? new FileLocation(_workspacePath) : null;
		}

		public function get openPreviouslyOpenedProjects():Boolean
		{
			return _openPreviouslyOpenedProjects;
		}

		public function set openPreviouslyOpenedProjects(value:Boolean):void
		{
            _openPreviouslyOpenedProjects = value;
            model.openPreviouslyOpenedProjects = value;
		}

        public function get openPreviouslyOpenedProjectBranches():Boolean
        {
            return _openPreviouslyOpenedProjectBranches;
        }

        public function set openPreviouslyOpenedProjectBranches(value:Boolean):void
        {
            _openPreviouslyOpenedProjectBranches = value;
			model.openPreviouslyOpenedProjectBranches = value;
        }

        public function get openPreviouslyOpenedFiles():Boolean
        {
            return _openPreviouslyOpenedFiles;
        }

        public function set openPreviouslyOpenedFiles(value:Boolean):void
        {
            _openPreviouslyOpenedFiles = value;
            model.openPreviouslyOpenedFiles = value;
        }

        public function get confirmApplicationExit():Boolean
        {
            return model.confirmApplicationExit;
        }

        public function set confirmApplicationExit(value:Boolean):void
        {
			model.confirmApplicationExit = value;
        }

        public function get showHiddenPaths():Boolean
        {
            return model.showHiddenPaths;
        }

        public function set showHiddenPaths(value:Boolean):void
        {
            _showHiddenPaths = value;
            model.showHiddenPaths = value;
        }

		override public function activate():void 
		{
			super.activate();
			dispatcher.addEventListener(ActionScriptBuildEvent.SAVE_BEFORE_BUILD, saveBeforeBuild);
			//dispatcher.addEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
			dispatcher.addEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			dispatcher.removeEventListener(ActionScriptBuildEvent.SAVE_BEFORE_BUILD, saveBeforeBuild);
			//dispatcher.removeEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
			dispatcher.removeEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
		}
		
		override public function resetSettings():void
		{
			workspacePath = null;
			isSaveFiles = false;
			OSXBookmarkerNotifiers.isWorkspaceAcknowledged = false;
			model.saveFilesBeforeBuild = false;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			// update local path
			if (OSXBookmarkerNotifiers.workspaceLocation && OSXBookmarkerNotifiers.workspaceLocation.fileBridge.exists) workspacePath = OSXBookmarkerNotifiers.workspaceLocation.fileBridge.nativePath;
			
			return Vector.<ISetting>([
				new PathSetting(this, "workspacePath", ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Workspace", true),
				new BooleanSetting(this, "isSaveFiles", "Save automatically before Build"),
				new BooleanSetting(this, "showHiddenPaths", "Show hidden files/folders"),
				new BooleanSetting(this, "confirmApplicationExit", "Confirm application exit"),
				new BooleanSetting(this, "openPreviouslyOpenedProjects", "Open previously opened projects on startup"),
				new BooleanSetting(this, "openPreviouslyOpenedFiles", "Open previously opened files for project"),
				new BooleanSetting(this, "openPreviouslyOpenedProjectBranches", "Open previously opened project branches"),
				new ButtonSetting(this, "resetLabel", "Reset all Settings (Hard)", "resetApplication", ButtonSetting.STYLE_DANGER)
			])
		}
		
		private function saveBeforeBuild(e:Event):void
		{
			isSaveFiles = true;// DO not show prompt again
		}
		
		private function setWorkspace(event:Event):void
		{
			OSXBookmarkerNotifiers.defineWorkspace();
		}
		
		private function openAccessManager(event:Event):void
		{
			OSXBookmarkerNotifiers.checkAccessDependencies(model.projects, "Access Manager", true);
		}
		
		private function onResetHandler(event:CloseEvent):void
		{
			Alert.yesLabel = "Yes";
			Alert.buttonWidth = 65;
			if (event.detail == Alert.YES)
			{
				if (model.activeEditor)
				{
					dispatcher.dispatchEvent(new GeneralEvent(GeneralEvent.RESET_ALL_SETTINGS));
					dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, model.activeEditor as DisplayObject));
				}
			}
		}

        public function resetApplication():void
        {
            Alert.yesLabel = "Reset everything";
            Alert.buttonWidth = 120;
            Alert.show("Are you sure you want to reset all Moonshine settings?", "Warning!", Alert.YES|Alert.CANCEL, FlexGlobals.topLevelApplication as Sprite, onResetHandler, null, Alert.CANCEL);
        }
    }
}