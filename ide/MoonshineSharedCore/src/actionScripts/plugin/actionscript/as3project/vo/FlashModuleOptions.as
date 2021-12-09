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
package actionScripts.plugin.actionscript.as3project.vo
{
    import mx.collections.ArrayCollection;
    
    import spark.components.Alert;
    
    import actionScripts.events.ASModulesEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IModulesFinder;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.settings.ModuleListSetting;
    import actionScripts.plugin.actionscript.as3project.settings.PathListItemVO;
    import actionScripts.plugin.settings.event.LinkOnlySettingsEvent;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.LinkOnlySetting;
    import actionScripts.plugin.settings.vo.LinkOnlySettingVO;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.FlashModuleVO;

	public class FlashModuleOptions 
	{
		private static const ADD_MODULE:String = "Add Module";
		private static const SEARCH_MODULES:String = "Search";
		
		public var modulePaths:ArrayCollection = new ArrayCollection;
		public var projectFolderLocation:FileLocation;
		public var sourceFolderLocation:FileLocation;

		private var model:IDEModel = IDEModel.getInstance();
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var linkOnlySetting:LinkOnlySetting;
		private var modulesFinder:IModulesFinder;
		private var searchLinkOnlyVO:LinkOnlySettingVO;
		private var moduleSettings:ModuleListSetting;
		
		public function FlashModuleOptions(folder:FileLocation, sourceFolder:FileLocation)
		{
			projectFolderLocation = folder;
			sourceFolderLocation = sourceFolder;
			
			dispatcher.addEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent, false, 0, true);
		}
		
		public function getSettings():Vector.<ISetting>
		{
			var settings:Vector.<ISetting> = new Vector.<ISetting>();
			
			searchLinkOnlyVO = new LinkOnlySettingVO(SEARCH_MODULES);
			linkOnlySetting = new LinkOnlySetting(new <LinkOnlySettingVO>[
				new LinkOnlySettingVO(ADD_MODULE),
				searchLinkOnlyVO
			]);
			linkOnlySetting.addEventListener(LinkOnlySettingsEvent.EVENT_LINK_CLICKED, onLinkOnlyItemClicked, false, 0, true);
			settings.push(linkOnlySetting);
			
			settings.push(
				new StaticLabelSetting("Select modules to compile during a project build.", 14, 0x686868),
				moduleSettings = new ModuleListSetting(this, "modulePaths", "Modules Paths", projectFolderLocation, true, false, true)
				);
			
			return settings;
		}
		
		public function cancelledSettings():void
		{
			if (linkOnlySetting)
			{
				linkOnlySetting.removeEventListener(LinkOnlySettingsEvent.EVENT_LINK_CLICKED, onLinkOnlyItemClicked);
			}
			
			if (modulesFinder)
			{
				modulesFinder.dispose();
			}
			
			moduleSettings = null;
			searchLinkOnlyVO = null;
			modulesFinder = null;
			linkOnlySetting = null;
		}
		
		public function parse(modules:XMLList):void 
		{
			var tmpModule:FlashModuleVO;
			modulePaths = new ArrayCollection();
			for each (var module:XML in modules.module)
			{
				tmpModule = new FlashModuleVO(
					projectFolderLocation.resolvePath(module.@sourcePath)
				);
				
				if ("@compile" in module)
				{
					tmpModule.isSelected = String(module.@compile) == "true" ? true : false;
				}
				
				modulePaths.addItem(tmpModule);
			}
		}
		
		public function toXML():XML
		{
			var modules:XML = <modules/>;
			for each (var module:FlashModuleVO in modulePaths)
			{
				modules.appendChild(SerializeUtil.serializeObjectPairs({
					sourcePath: getProjectRelativePath(module.sourcePath),
					compile: module.isSelected.toString()
				}, <module/>));
			}
			
			return modules;
		}
		
		public function onRemoveModuleEvent(fw:FileWrapper, project:AS3ProjectVO):void
		{
			var modulesToRemove:Array = [];
			if (fw.file.fileBridge.isDirectory)
			{
				modulePaths.source.forEach(function(element:FlashModuleVO, index:int, arr:Array):void
				{
					if (element.sourcePath.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
					{
						modulesToRemove.push(element);
					}
				});
				
				for (var i:int; i < modulesToRemove.length; i++)
				{
					modulePaths.removeItem(modulesToRemove[i]);
				}
			}
			else
			{
				modulePaths.source.some(function(element:FlashModuleVO, index:int, arr:Array):Boolean
				{
					if (element.sourcePath.fileBridge.nativePath == fw.file.fileBridge.nativePath)
					{
						modulesToRemove = [element];
						modulePaths.removeItem(element);
						return true;
					}
					return false;
				});
			}
			
			if (modulesToRemove.length != 0)
			{
				updateModulesInSettings(modulesToRemove, true);
				project.saveSettings();
			}
		}
		
		private function onAddModuleEvent(event:ASModulesEvent):void
		{
			var tmpModule:FlashModuleVO = new FlashModuleVO(event.moduleFilePath);
			modulePaths.addItem(tmpModule);
			event.project.saveSettings();
			
			updateModulesInSettings([tmpModule]);
		}
		
		private function getProjectRelativePath(value:FileLocation):String
		{
			return projectFolderLocation.fileBridge.getRelativePath(value, true);
		}
		
		private function onLinkOnlyItemClicked(event:LinkOnlySettingsEvent):void
		{
			if (event.value.label == ADD_MODULE)
			{
				onModuleAddRequest();
			}
			else if (event.value.label == SEARCH_MODULES)
			{
				searchLinkOnlyVO.isBusy = true;
				onModulesSearchRequest();
			}
		}
		
		private function onModuleAddRequest():void
		{
			if (model.fileCore.nativePath.indexOf(projectFolderLocation.fileBridge.nativePath + projectFolderLocation.fileBridge.separator) != -1)
			{
				model.fileCore.browseForOpen("Select MXML Module", onModuleBrowsed, null, ["*.mxml"]);
			}
			else
			{
				model.fileCore.browseForOpen("Select MXML Module", onModuleBrowsed, null, ["*.mxml"], projectFolderLocation.fileBridge.nativePath);
			}
		}
		
		private function onModulesSearchRequest():void
		{
			modulesFinder ||= model.flexCore.getModulesFinder();
			modulesFinder.search(projectFolderLocation, sourceFolderLocation, onModuleSearchProcessExit);
		}
		
		private function onModuleBrowsed(file:Object):void
		{
			// test a few things before adding
			// the selected file to module list
			// 1. inside source-folder
			// 2. not a duplicated item
			// 3. is <s:Module file
			
			var sourcePath:String = sourceFolderLocation ? sourceFolderLocation.fileBridge.nativePath : projectFolderLocation.fileBridge.nativePath;
			if (file.nativePath.indexOf(sourcePath + model.fileCore.separator) == -1)
			{
				Alert.show("Module file needs to be inside the target Project/Source directory.", "Error!");
				return;
			}
			
			var isPathAlreadyAdded:Boolean = moduleSettings.isPathExists(file.nativePath);
			if (isPathAlreadyAdded)
			{
				Alert.show("Module file is already added.", "Note!");
				return;
			}
			
			var fileContent:String = model.fileCore.read() as String;
			if (fileContent.search("<s:Module ") == -1)
			{
				Alert.show("Selected file is not a valid Module file.", "Error!");
				return;
			}
			
			moduleSettings.addModules([
				new FlashModuleVO(new FileLocation(file.nativePath))
			]);
		}
		
		private function onModuleSearchProcessExit(modules:Array, isError:Boolean=false):void
		{
			if (!moduleSettings) return;
			
			if (!isError && modules)
			{
				var isExist:Boolean;
				var tmpModule:FlashModuleVO;
				var tmpModuleFile:FileLocation;
				var newCount:int = 0;
				var tmpModules:Array = [];
				modules.forEach(function(pathValue:String, index:int, arr:Array):void
				{
					// in case of osx grep call it returns only
					// relative path. we need an extra work to 
					// get a full path so we can use in next steps
					if (ConstantsCoreVO.IS_MACOS)
					{
						tmpModuleFile = projectFolderLocation.fileBridge.resolvePath(pathValue);
						pathValue = tmpModuleFile.fileBridge.nativePath;
					}
					
					isExist = moduleSettings.paths.source.some(function(moduleObj:PathListItemVO, index:int, arr:Array):Boolean
					{
						return (moduleObj.file.fileBridge.nativePath == pathValue);
					});
					
					if (!isExist)
					{
						tmpModule = new FlashModuleVO(tmpModuleFile || new FileLocation(pathValue));
						modulePaths.addItem(tmpModule);
						tmpModules.push(
							tmpModule
						);
						newCount++;
					}
				});
				
				Alert.show("Added "+ newCount +" new module(s) under:\n"+ projectFolderLocation.fileBridge.nativePath, "Note!");
				if (tmpModules.length > 0) 
				{
					moduleSettings.addModules(tmpModules);
					
					var tmpProject:AS3ProjectVO = UtilsCore.getProjectByPath(projectFolderLocation.fileBridge.nativePath) as AS3ProjectVO;
					if (tmpProject) tmpProject.saveSettings();
				}
			}
			else if (!isError)
			{
				Alert.show("No module found under:\n"+ projectFolderLocation.fileBridge.nativePath, "Note!");
			}
			
			searchLinkOnlyVO.isBusy = false;
		}
		
		private function updateModulesInSettings(modules:Array, isRemove:Boolean=false):void
		{
			if (!moduleSettings) return;
			
			if (isRemove)
			{
				moduleSettings.removeModules(modules);
			}
			else
			{
				moduleSettings.addModules(modules);
			}
		}
    }
}