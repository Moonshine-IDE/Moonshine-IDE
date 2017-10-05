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
package actionScripts.plugin.project
{
	import flash.events.Event;

	import __AS3__.vec.Vector;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RefreshTreeEvent;
	import actionScripts.events.ShowSettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.ui.LayoutModifier;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.valueObjects.ProjectVO;
	
	import components.views.project.OpenResourceView;
	import components.views.project.TreeView;
	
	public class ProjectPlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		public static const EVENT_PROJECT_SETTINGS:String = "projectSettingsEvent";
		public static const EVENT_SHOW_OPEN_RESOURCE:String = "showOpenResource";
		
		override public function get name():String 	{return "Project Plugin";}
		override public function get author():String 		{return "Moonshine Project Team";}
		override public function get description():String 	{return "Provides project settings.";}
		
		private var treeView:TreeView;
		private var openResourceView:OpenResourceView;
		
		public function ProjectPlugin()
		{
			treeView = new TreeView();
			treeView.projects = model.projects;
		}
		
		override public function activate():void
		{
			super.activate(); 
			_activated = true;
			
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleAddProject);
			dispatcher.addEventListener(ProjectEvent.REMOVE_PROJECT, handleRemoveProject);
			
			dispatcher.addEventListener(ProjectEvent.SHOW_PROJECT_VIEW, handleShowProjectView);
			dispatcher.addEventListener(ProjectEvent.HIDE_PROJECT_VIEW, handleHideProjectView);
			
			dispatcher.addEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);
			
			dispatcher.addEventListener(ShowSettingsEvent.EVENT_SHOW_SETTINGS, handleShowSettings);		
			dispatcher.addEventListener(EVENT_PROJECT_SETTINGS, handleMenuShowSettings);
			
			dispatcher.addEventListener(RefreshTreeEvent.EVENT_REFRESH, handleTreeRefresh);
		}
		override public function deactivate():void
		{
			super.deactivate();
			_activated = false;			
			
			dispatcher.removeEventListener(EVENT_SHOW_OPEN_RESOURCE, handleShowOpenResource);
		}
		
		public function getSettingsList():Vector.<ISetting>	
		{
			return new Vector.<ISetting>();
		}
		
		private function showProjectPanel():void
		{
			if (!treeView.stage) 
			{
				LayoutModifier.attachSidebarSections(treeView);
			}
		}
		
		private function openProject(root:FileLocation, projectFile:String):void
		{
			var p:ProjectVO = new ProjectVO(root);
			
			model.activeProject = p;
			model.projects.addItem(p);
		}
		
		private function handleShowSettings(event:ShowSettingsEvent):void
		{
			showSettings(event.project);
		}
		
		private function handleMenuShowSettings(event:Event):void
		{
			var project:ProjectVO = IDEModel.getInstance().activeProject;
			if (project)
			{
				showSettings(IDEModel.getInstance().activeProject);
			} 
		}
		
		private function showSettings(project:ProjectVO):void
		{
			// Don't spawn two identical settings views.
			for (var i:int = 0; i < model.editors.length; i++)
			{
				var view:SettingsView = model.editors as SettingsView;
				if (view && view.associatedData == project)
				{
					model.activeEditor = view;
					return;
				}
			}
			
			// Create settings view & fetch project settings
			var settingsView:SettingsView = new SettingsView();
			settingsView.Width = 230;	
			var settingsLabel:String = project.folderLocation.fileBridge.name + " settings"; 
			settingsView.addCategory(settingsLabel);
			
			var categories:Vector.<SettingsWrapper> = project.getSettings();
			for each (var category:SettingsWrapper in categories)
			{
				settingsView.addSetting(category, settingsLabel);
			}
			
			settingsView.label = settingsLabel;
			settingsView.associatedData = project;
			
			// Listen for save/cancel
			settingsView.addEventListener(SettingsView.EVENT_SAVE, settingsSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, settingsClose);
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
		}
		
		private function settingsClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;
			
			// Close the tab
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, settings)
			);
			
			settings.removeEventListener(SettingsView.EVENT_CLOSE, settingsClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, settingsSave);
		}
		
		private function settingsSave(event:Event):void
		{
			var view:SettingsView = event.target as SettingsView;
			
			if (view && view.associatedData is ProjectVO)
			{
				var pvo:ProjectVO = view.associatedData as ProjectVO;
				
				if (model.projects.getItemIndex(pvo) == -1)
				{
					// Newly created project, add it to project explorer & show it
					model.projects.addItem(pvo);
					IDEModel.getInstance().activeProject = pvo;
					showProjectPanel();
					
					dispatcher.dispatchEvent( 
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, view) 
					);
				}
				else
				{
					// Save
					pvo.saveSettings();
				}
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SAVE_PROJECT_SETTINGS, pvo));
			}
		}
		
		private function handleAddProject(event:ProjectEvent):void
		{
			showProjectPanel();
			// Is file in an already opened project?
			for each (var p:ProjectVO in model.projects)	
			{
				if (event.project.folderLocation.fileBridge.nativePath == p.folderLocation.fileBridge.nativePath)
				{
					return;
				}
			}
			
			if (model.projects.getItemIndex(event.project) == -1)
			{
				model.projects.addItemAt(event.project, 0);
				model.activeProject = event.project;
			}
			
			
		}
		
		private function handleRemoveProject(event:ProjectEvent):void
		{
			var idx:int = model.projects.getItemIndex(event.project);
			if (idx > -1)
			{
				model.projects.removeItemAt(idx);
			}
			
			// Close all files for project
			for (var i:int = 0; i < model.editors.length; i++)
			{
				var ed:BasicTextEditor = model.editors[i] as BasicTextEditor;
				if (ed && ed.currentFile && ed.currentFile.fileBridge.nativePath.indexOf(event.project.folderLocation.fileBridge.nativePath) == 0)
				{
					dispatcher.dispatchEvent(
						new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, ed)
					);
				}
			}
			
			if (model.activeProject == event.project)
			{
				if (model.projects.length) model.activeProject = model.projects[0];
				else model.activeProject = null;
			}
		}
		
		private function handleShowOpenResource(event:Event):void
		{
			if (!openResourceView)
			{
				openResourceView = new OpenResourceView();
			}
			
			// If it's not showing, spin it into view
			if (!openResourceView.stage)
			{
				openResourceView.setFileList(treeView.projectFolders);
				model.mainView.rotatePanel(treeView, openResourceView);
				
				openResourceView.setFocus();
			}
				// Otherwise spin it out of view
			else
			{
				model.mainView.rotatePanel(openResourceView, treeView);
			}
		}
		
		private function handleShowProjectView(event:Event):void
		{
			showProjectPanel();
		}
		
		private function handleHideProjectView(event:ProjectEvent):void
		{
			
		}
		
		private function handleTreeRefresh(event:RefreshTreeEvent):void
		{
			treeView.refresh(event.dir);
		}
	}
}