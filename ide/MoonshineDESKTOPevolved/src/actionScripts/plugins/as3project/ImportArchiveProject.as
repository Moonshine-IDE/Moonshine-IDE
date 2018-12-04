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
package actionScripts.plugins.as3project
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.net.SharedObject;
    
    import mx.controls.Alert;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.settings.SettingsView;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.plugin.settings.vo.StringSetting;
    import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
    import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.utils.SharedObjectConst;
	
    public class ImportArchiveProject
	{
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var cookie:SharedObject;
		private var project:AS3ProjectVO;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var isInvalidToSave:Boolean;
		
		private var _customFlexSDK:String;
		private var _currentCauseToBeInvalid:String;
		private var _archivePath:String;
		private var _projectName:String;
		private var _folderPath:String;
		
		public function ImportArchiveProject()
		{
			openImportProjectWindow();
		}
		
		public function get projectName():String
		{
			return _projectName;
		}
		public function set projectName(value:String):void
		{
			_projectName = value;
		}
		
		public function get folderPath():String
		{
			return _folderPath;
		}
		public function set folderPath(value:String):void
		{
			_folderPath = value;
		}
		
		public function get archivePath():String
		{
			return _archivePath;
		}
		public function set archivePath(value:String):void
		{
			_archivePath = value;
		}
		
		public function get customFlexSDK():String
		{
			return _customFlexSDK;
		}
		public function set customFlexSDK(value:String):void
		{
			_customFlexSDK = value;
		}
		
		private function openImportProjectWindow():void
		{
			var lastSelectedProjectPath:String;

			CONFIG::OSX
				{
					if (OSXBookmarkerNotifiers.availableBookmarkedPaths == "") OSXBookmarkerNotifiers.removeFlashCookies();
				}
			
            cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			
			var settingsView:SettingsView = new SettingsView();
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = "Import";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");

			var settings:SettingsWrapper = getProjectSettings();
			settingsView.addEventListener(SettingsView.EVENT_SAVE, createSave);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "Import Project";
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
		}

        private function isAllowedTemplateFile(projectFileExtension:String):Boolean
        {
            return projectFileExtension != "as3proj" || projectFileExtension != "veditorproj" || !projectFileExtension;
        }

		private function getProjectSettings():SettingsWrapper
		{
            newProjectNameSetting = new StringSetting(this, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\'",<.>/?');
			newProjectPathSetting = new PathSetting(this, 'folderPath', 'Directory to Save', true, null, false, true);
			newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			
			var archivePathSetting:PathSetting = new PathSetting(this, 'archivePath', 'Archive File to Project', false);
			archivePathSetting.fileFilters = ["*.zip"];

            return new SettingsWrapper("Name & Location", Vector.<ISetting>([
				new StaticLabelSetting('Import an Archive Project'),
				newProjectNameSetting, // No space input either plx
				archivePathSetting,
				newProjectPathSetting,
				new PathSetting(this,'customFlexSDK', 'Apache Flex®, Apache Royale® or Feathers SDK', true, customFlexSDK, true)
			]));
		}
		
		private function checkIfProjectDirectory(value:FileLocation):void
		{
			var tmpFile:FileLocation = FlashDevelopImporter.test(value.fileBridge.getFile as File);
			if (!tmpFile) tmpFile = FlashBuilderImporter.test(value.fileBridge.getFile as File);
			
			if (tmpFile) 
			{
				newProjectPathSetting.setMessage((_currentCauseToBeInvalid = "Project can not be created to an existing project directory:\n"+ value.fileBridge.nativePath), AbstractSetting.MESSAGE_CRITICAL);
			}
			else newProjectPathSetting.setMessage(value.fileBridge.nativePath);
			
			if (newProjectPathSetting.stringValue == "") 
			{
				isInvalidToSave = true;
				_currentCauseToBeInvalid = 'Unable to access Project Directory:\n'+ value.fileBridge.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
			}
			else isInvalidToSave = tmpFile ? true : false;
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE LISTENERS
		//
		//--------------------------------------------------------------------------
		
		private function onProjectPathChanged(event:Event, makeNull:Boolean=true):void
		{
			return; // temp
			
			if (makeNull) project.projectFolder = null;
			project.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
			newProjectPathSetting.label = "Parent Directory";
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function onProjectNameChanged(event:Event):void
		{
			checkIfProjectDirectory(project.folderLocation.resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function createClose(event:Event):void
		{
			var settings:SettingsView = event.target as SettingsView;
			
			settings.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			settings.removeEventListener(SettingsView.EVENT_SAVE, createSave);
			if (newProjectPathSetting) 
			{
				newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
				newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			}
			
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.target as DisplayObject)
			);
		}
		
		private function throwError():void
		{
			Alert.show(_currentCauseToBeInvalid +" Project creation terminated.", "Error!");
		}
		
		private function createSave(event:Event):void
		{
			if (isInvalidToSave) 
			{
				throwError();
				return;
			}
			
			var view:SettingsView = event.target as SettingsView;
			var targetFolder:FileLocation = project.folderLocation;

			// Close settings view
			createClose(event);
		}
    }
}