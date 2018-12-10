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
    import com.adobe.utils.StringUtil;
    
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.net.SharedObject;
    
    import mx.controls.Alert;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.ProjectEvent;
    import actionScripts.extResources.deng.fzip.fzip.FZipFile;
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
    import actionScripts.utils.Unzip;
	CONFIG::OSX
		{
		import actionScripts.utils.OSXBookmarkerNotifiers;
		}
	
    public class ImportArchiveProject
	{
		private var newProjectNameSetting:StringSetting;
		private var newProjectPathSetting:PathSetting;
		private var archivePathSetting:PathSetting;
		private var cookie:SharedObject;
		private var project:AS3ProjectVO;
		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var unzip:Unzip;
		private var settingsView:SettingsView;
		private var isNameManualChanged:Boolean;
		private var isProjectResidesInSubFolder:String;
		private var originalNameByConfiguration:String;
		private var originalExtensionConfiguration:String;
		
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
		
		private function get isInvalidToSave():Boolean
		{
			if ((!folderPath || StringUtil.trim(folderPath).length == 0) ||
				(!projectName || StringUtil.trim(projectName).length == 0) ||
				(!archivePath || StringUtil.trim(archivePath).length == 0))
			{
				_currentCauseToBeInvalid = "Not enough information.";
				return true;
			}
			return false;
		}
		
		private function testArchivePath():void
		{
			isProjectResidesInSubFolder = null;
			originalNameByConfiguration = null;
			originalExtensionConfiguration = null;
			unzip = new Unzip(new File(archivePath));
			unzip.addEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadSuccess);
			unzip.addEventListener(Unzip.FILE_LOAD_ERROR, onFileLoadError);
			
			/*
			 * @local
			 */
			function onFileLoadSuccess(ev:Event):void
			{
				releaseListeners();
				
				// verify if known project archive as per
				// FlashDevelopImporter.test()
				var tmpFiles:Array = unzip.getFilesList();
				if (tmpFiles)
				{
					var tmpSplit:Array;
					var fileNameOnly:String;
					for each (var file:FZipFile in tmpFiles)
					{
						// we don't provide by easy extension property by the api
						if (!file.isDirectory)
						{
							originalExtensionConfiguration = isAllowedTemplateFile(file.extension);
							if (originalExtensionConfiguration)
							{
								// conventionally the configuration file is suppose to reside
								// to the root of the project folder; thus, following
								// check ensure that if the project resides in some 
								// sub-folder inside the zip; So next Moonshine loads the
								// project by that sub-folder only
								if (file.filename.indexOf("/") != -1)
								{
									tmpSplit = file.filename.split("/");
									fileNameOnly = tmpSplit.pop();
									isProjectResidesInSubFolder = tmpSplit.join("/");
								}
								
								// try to generate the name as extracted from the
								// project configuration file
								if (!tmpSplit)
								{
									tmpSplit = file.filename.split(File.separator);
									fileNameOnly = tmpSplit.pop();
								}
								originalNameByConfiguration = fileNameOnly.substring(0, fileNameOnly.lastIndexOf("."));
								if (!projectName && !isNameManualChanged)
								{
									projectName = newProjectNameSetting.stringValue = originalNameByConfiguration;
									onProjectNameChanged(null, false);
								}
								
								return;
							}
						}
					}
					
					// if came through here, it's not a valid project archive
					Alert.show("No valid Moonshine project found to the archive. Please check.", "Error!");
				}
			}
			function onFileLoadError(ev:Event):void
			{
				releaseListeners();
				Alert.show("Unable to load the archive file.\nPlease check, if the file is valid or exist to the path.", "Error!");
			}
			function releaseListeners():void
			{
				unzip.removeEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadSuccess);
				unzip.removeEventListener(Unzip.FILE_LOAD_ERROR, onFileLoadError);
			}
		}
		
		private function openImportProjectWindow():void
		{
			var lastSelectedProjectPath:String;

			CONFIG::OSX
				{
					if (OSXBookmarkerNotifiers.availableBookmarkedPaths == "") OSXBookmarkerNotifiers.removeFlashCookies();
				}
			
            cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('recentProjectPath'))
			{
				model.recentSaveProjectPath.source = cookie.data.recentProjectPath;
				if (cookie.data.hasOwnProperty('lastSelectedProjectPath')) 
				{
					lastSelectedProjectPath = cookie.data.lastSelectedProjectPath;
					if (!folderPath && lastSelectedProjectPath) 
					{
						folderPath = (model.recentSaveProjectPath.getItemIndex(lastSelectedProjectPath) != -1) ? lastSelectedProjectPath : model.recentSaveProjectPath.source[model.recentSaveProjectPath.length - 1];
					}
				}
			}
			
			settingsView = new SettingsView();
			settingsView.Width = 150;
			settingsView.defaultSaveLabel = "Import";
			settingsView.isNewProjectSettings = true;
			
			settingsView.addCategory("");

			var settings:SettingsWrapper = getProjectSettings();
			settingsView.addEventListener(SettingsView.EVENT_SAVE, createSavePreparation);
			settingsView.addEventListener(SettingsView.EVENT_CLOSE, createClose);
			settingsView.addSetting(settings, "");
			
			settingsView.label = "Import Project";
			newProjectPathSetting.setMessage((folderPath ? folderPath : ".. ") + model.fileCore.separator +" ..");
			
			dispatcher.dispatchEvent(
				new AddTabEvent(settingsView)
			);
		}

        private function isAllowedTemplateFile(projectFileExtension:String):String
        {
            if (projectFileExtension == "as3proj") return "as3proj";
			if (projectFileExtension == "veditorproj") return "veditorproj";
			return null;
        }

		private function getProjectSettings():SettingsWrapper
		{
            newProjectNameSetting = new StringSetting(this, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\'",<.>/?');
			newProjectPathSetting = new PathSetting(this, 'folderPath', 'Target Directory', true, null, false, true);
			archivePathSetting = new PathSetting(this, 'archivePath', 'Archive File', false);
			archivePathSetting.fileFilters = ["*.zip"];
			newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
			newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			archivePathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onArchivePathChanged);

            return new SettingsWrapper("Name & Location", Vector.<ISetting>([
				new StaticLabelSetting('Import an Archive Project'),
				newProjectNameSetting, // No space input either plx
				archivePathSetting,
				newProjectPathSetting,
				new PathSetting(this,'customFlexSDK', 'Apache Flex®, Apache Royale® or Feathers SDK', true, customFlexSDK, true)
			]));
		}
		
		private function checkIfProjectDirectory(value:File):void
		{
			var tmpFile:FileLocation = FlashDevelopImporter.test(value);
			if (!tmpFile) tmpFile = FlashBuilderImporter.test(value);
			
			if (tmpFile) 
			{
				newProjectPathSetting.setMessage((_currentCauseToBeInvalid = "Project can not be created to an existing project directory:\n"+ value.nativePath), AbstractSetting.MESSAGE_CRITICAL);
			}
			else newProjectPathSetting.setMessage(value.nativePath);
			
			if (newProjectPathSetting.stringValue == "") 
			{
				_currentCauseToBeInvalid = 'Unable to access Project Directory:\n'+ value.nativePath +'\nPlease try to create the project again and use the "Change" link to open the target directory again.';
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE LISTENERS
		//
		//--------------------------------------------------------------------------
		
		private function onProjectPathChanged(event:Event, makeNull:Boolean=true):void
		{
			checkIfProjectDirectory((new File(folderPath)).resolvePath(newProjectNameSetting.stringValue));
		}
		
		private function onArchivePathChanged(event:Event, makeNull:Boolean=true):void
		{
			if ((archivePathSetting.stringValue != "") && (archivePath != archivePathSetting.stringValue))
			{
				archivePath = archivePathSetting.stringValue;
				testArchivePath();
			}
		}
		
		private function onProjectNameChanged(event:Event, isManual:Boolean=true):void
		{
			if (folderPath)
			{
				if (isManual) isNameManualChanged = true;
				checkIfProjectDirectory((new File(folderPath)).resolvePath(newProjectNameSetting.stringValue));
			}
		}
		
		private function createClose(event:Event):void
		{
			settingsView.removeEventListener(SettingsView.EVENT_CLOSE, createClose);
			settingsView.removeEventListener(SettingsView.EVENT_SAVE, createSavePreparation);
			if (newProjectPathSetting) 
			{
				newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
				archivePathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onArchivePathChanged);
				newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
			}
			
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, settingsView)
			);
		}
		
		private function throwError():void
		{
			Alert.show(_currentCauseToBeInvalid +" Project creation terminated.", "Error!");
		}
		
		private function createSavePreparation(event:Event):void
		{
			if (isInvalidToSave) 
			{
				throwError();
				return;
			}
			
			// create destination folder by projectName
			var destinationProjectFolder:File = (new File(folderPath)).resolvePath(projectName);
			destinationProjectFolder.createDirectory();
			
			unzip.unzipTo(destinationProjectFolder, onUnzipSuccess);
		}
		
		private function onUnzipSuccess(destination:File):void
		{
			// the condition is to make sure that project by subfolder
			// if the project resides in some subfolder
			var projectActualFolder:File = isProjectResidesInSubFolder ? destination.resolvePath(isProjectResidesInSubFolder) : destination;
			
			// update the configuration file name if a custom name is given
			// so the project loads by the custom name
			if (originalNameByConfiguration != projectName)
			{
				var fromFile:File = projectActualFolder.resolvePath(originalNameByConfiguration +"."+ originalExtensionConfiguration);
				var toFile:File = projectActualFolder.resolvePath(projectName +"."+ originalExtensionConfiguration);
				fromFile.moveTo(toFile, true);
			}
			
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, projectActualFolder));
			// close settings view
			createClose(null);
		}
    }
}