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
    import flash.events.Event;
    
    import mx.collections.ArrayCollection;
    
    import spark.components.Alert;
    
    import actionScripts.events.ASModulesEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.SettingsEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IModulesFinder;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.LinkOnlySetting;
    import actionScripts.plugin.settings.vo.LinkOnlySettingVO;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.FlashModuleVO;

	public class FlashModuleOptions 
	{
		private static const EVENT_ADD_MODULE:String = "addModuleEvent";
		private static const EVENT_SEARCH_MODULES:String = "searchModulesEvent";
		
		public var modulePaths:ArrayCollection = new ArrayCollection;
		public var projectFolderLocation:FileLocation;
		public var sourceFolderLocation:FileLocation;

		private var moduleSelectionsUntilSave:Array;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var selectionIndex:Array;
		private var linkOnlySetting:LinkOnlySetting;
		private var modulesFinder:IModulesFinder;
		private var settings:Vector.<ISetting>;
		private var modulesPendingToBeAdded:Array;
		
		public function FlashModuleOptions(folder:FileLocation, sourceFolder:FileLocation)
		{
			projectFolderLocation = folder;
			sourceFolderLocation = sourceFolder;
			
			dispatcher.addEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent, false, 0, true);
		}
		
		public function getSettings():Vector.<ISetting>
		{
			modulesPendingToBeAdded = [];
			settings = new Vector.<ISetting>();
			
			linkOnlySetting = new LinkOnlySetting(new <LinkOnlySettingVO>[
				new LinkOnlySettingVO("Add Module", EVENT_ADD_MODULE),
				new LinkOnlySettingVO("Search", EVENT_SEARCH_MODULES)
			]);
			linkOnlySetting.addEventListener(EVENT_ADD_MODULE, onModuleAddRequest, false, 0, true);
			linkOnlySetting.addEventListener(EVENT_SEARCH_MODULES, onModulesSearchRequest, false, 0, true);
			settings.push(linkOnlySetting);
			
			settings.push(
				new StaticLabelSetting("Select modules to compile during a project build.", 14, 0x686868)
				);
			
			// for some strange reason doing registerClassAlias
			// to FileLocation always returns wrong results.
			// this should be doing for now
			var tmpRelativePath:String;
			moduleSelectionsUntilSave = modulePaths.source.map(function(element:FlashModuleVO, index:int, arr:Array):Object
			{
				tmpRelativePath = getProjectRelativePath(element.sourcePath);

				var tmpObject:Object = {sourcePath: tmpRelativePath, module:element, isSelected: element.isSelected};
				settings.push(
					new BooleanSetting(tmpObject, "isSelected", tmpRelativePath)
				);
				return tmpObject;
			});
			
			return settings;
		}
		
		public function cancelledSettings():void
		{
			if (linkOnlySetting)
			{
				linkOnlySetting.removeEventListener(EVENT_ADD_MODULE, onModuleAddRequest);
				linkOnlySetting.removeEventListener(EVENT_SEARCH_MODULES, onModulesSearchRequest);
			}
			
			if (modulesFinder)
			{
				modulesFinder.dispose();
			}
			
			modulesFinder = null;
			linkOnlySetting = null;
			moduleSelectionsUntilSave = null;
			modulesPendingToBeAdded = null;
			settings = null;
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
			if (modulesPendingToBeAdded && modulesPendingToBeAdded.length > 0)
			{
				modulePaths = new ArrayCollection(modulePaths.source.concat(modulesPendingToBeAdded));
			}
			
			// triggers during project configuration saves
			if (moduleSelectionsUntilSave)
			{
				moduleSelectionsUntilSave.forEach(function(element:Object, index:int, arr:Array):void
				{
					modulePaths[index].isSelected = element.isSelected;
				});
			}
			
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
			if (fw.file.fileBridge.isDirectory)
			{
				var modulesToRemove:Array = [];
				if (moduleSelectionsUntilSave)
				{
					moduleSelectionsUntilSave.forEach(function(element:Object, index:int, arr:Array):void
					{
						if ((element.module as FlashModuleVO).sourcePath.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
						{
							modulesToRemove.push({module: element.module, moduleSelectionsUntilSaveObj: element});
						}
					});
				}
				else
				{
					modulePaths.source.forEach(function(element:FlashModuleVO, index:int, arr:Array):void
					{
						if (element.sourcePath.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
						{
							modulesToRemove.push({module: element, moduleSelectionsUntilSaveObj: null});
						}
					});
				}
				
				for (var i:int; i < modulesToRemove.length; i++)
				{
					modulePaths.removeItem(modulesToRemove[i].module);
					if (moduleSelectionsUntilSave) 
					{
						moduleSelectionsUntilSave.splice(modulesToRemove.indexOf(modulesToRemove[i].moduleSelectionsUntilSaveObj), 1);
						if (modulesPendingToBeAdded)
						{
							var pendingIndex:int =  modulesPendingToBeAdded.indexOf(modulesToRemove[i].module);
							if (pendingIndex != -1) 
							{
								modulesPendingToBeAdded.splice(pendingIndex, 1);
							}
						}
					}
				}
				
				updateModulesInSettings([modulesToRemove], true);
			}
			else
			{
				modulePaths.source.some(function(element:FlashModuleVO, index:int, arr:Array):Boolean
				{
					if (element.sourcePath.fileBridge.nativePath == fw.file.fileBridge.nativePath)
					{
						modulePaths.removeItem(element);
						return true;
					}
					return false;
				});
				
				if (moduleSelectionsUntilSave)
				{
					moduleSelectionsUntilSave.some(function(element:Object, index:int, arr:Array):Boolean
					{
						if ((element.module as FlashModuleVO).sourcePath.fileBridge.nativePath == fw.file.fileBridge.nativePath)
						{
							moduleSelectionsUntilSave.splice(index, 1);
							if (modulesPendingToBeAdded)
							{
								var pendingIndex:int =  modulesPendingToBeAdded.indexOf(element.module);
								if (pendingIndex != -1) 
								{
									modulesPendingToBeAdded.splice(pendingIndex, 1);
								}
							}
							updateModulesInSettings([element.module], true);
							return true;
						}
						return false;
					});
				}
				
			}
			
			project.saveSettings();
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
		
		private function onModuleAddRequest(event:Event):void
		{
			
		}
		
		private function onModulesSearchRequest(event:Event):void
		{
			modulesFinder ||= IDEModel.getInstance().flexCore.getModulesFinder();
			modulesFinder.search(projectFolderLocation, sourceFolderLocation, onModuleSearchProcessExit);
		}
		
		private function onModuleSearchProcessExit(modules:Array, isError:Boolean=false):void
		{
			if (!isError && modules)
			{
				var isExist:Boolean;
				var tmpModule:FlashModuleVO;
				var tmpModuleFile:FileLocation;
				var newCount:int = 0;
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
					
					isExist = moduleSelectionsUntilSave.some(function(moduleObj:Object, index:int, arr:Array):Boolean
					{
						return ((moduleObj.module as FlashModuleVO).sourcePath.fileBridge.nativePath == pathValue);
					});
					
					if (!isExist)
					{
						tmpModule = new FlashModuleVO(
							tmpModuleFile || new FileLocation(pathValue)
						);
						modulesPendingToBeAdded.push(tmpModule);
						
						var tmpObject:Object = {sourcePath: getProjectRelativePath(tmpModule.sourcePath), 
							module: tmpModule,
							isSelected: tmpModule.isSelected};
						settings.push(
							new BooleanSetting(tmpObject, "isSelected", tmpObject.sourcePath)
						);
						moduleSelectionsUntilSave.push(tmpObject);
						newCount++;
					}
				});
				
				Alert.show("Found "+ newCount +" new module(s) under:\n"+ projectFolderLocation.fileBridge.nativePath, "Note!");
				dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
			}
			else if (!isError)
			{
				Alert.show("No module found under:\n"+ projectFolderLocation.fileBridge.nativePath, "Note!");
			}
		}
		
		private function updateModulesInSettings(modules:Array, isRemove:Boolean=false):void
		{
			if (!settings) return;
			
			if (isRemove)
			{
				modules.forEach(function(module:FlashModuleVO, index:int, arr:Array):void
				{
					for (var i:int; i < settings.length; i++)
					{
						if ((settings[i] is BooleanSetting) && ((settings[i] as BooleanSetting).provider.module == module))
						{
							settings.splice(i, 1);
							break;
						}
					}
				});
			}
			else
			{
				modules.forEach(function(module:FlashModuleVO, index:int, arr:Array):void
				{
					modulesPendingToBeAdded.push(module);
					
					var tmpObject:Object = {sourcePath: getProjectRelativePath(module.sourcePath), 
						module: module,
						isSelected: module.isSelected};
					settings.push(
						new BooleanSetting(tmpObject, "isSelected", tmpObject.sourcePath)
					);
					moduleSelectionsUntilSave.push(tmpObject);
				});
			}
			
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_REFRESH_CURRENT_SETTINGS));
		}
    }
}