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
package actionScripts.plugin.actionscript.as3project.save
{
	import flash.events.Event;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	
	public class SaveFilesPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		override public function get name():String { return "General"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "General options to Moonshine"; }
		
		private var _workspacePath:String;
		private var _isSaveFiles:Boolean = false;

		public function SaveFilesPlugin()
		{
			super();
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
			OSXBookmarkerNotifiers.workspaceLocation = new FileLocation(_workspacePath);
		}
		
		override public function activate():void 
		{
			super.activate();
			dispatcher.addEventListener(CompilerEventBase.SAVE_BEFORE_BUILD, saveBeforeBuild);
			//dispatcher.addEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
			dispatcher.addEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
		}
		
		override public function deactivate():void 
		{
			super.deactivate();
			dispatcher.removeEventListener(CompilerEventBase.SAVE_BEFORE_BUILD, saveBeforeBuild);
			//dispatcher.removeEventListener(ProjectEvent.SET_WORKSPACE, setWorkspace);
			dispatcher.removeEventListener(ProjectEvent.ACCESS_MANAGER, openAccessManager);
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			// update local path
			if (OSXBookmarkerNotifiers.workspaceLocation && OSXBookmarkerNotifiers.workspaceLocation.fileBridge.exists) workspacePath = OSXBookmarkerNotifiers.workspaceLocation.fileBridge.nativePath;
			
			return Vector.<ISetting>([
				new PathSetting(this, "workspacePath", "Moonshine Workspace", true),
				new BooleanSetting(this,'isSaveFiles', 'Save automatically Before Build')
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
	}
}