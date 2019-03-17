// ActionScript file
////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
	
	public class SaveFilesPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String { return "General"; }
		override public function get author():String { return "Moonshine Project Team"; }
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
				new PathSetting(this, "workspacePath", "Moonshine Workspace", true),
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