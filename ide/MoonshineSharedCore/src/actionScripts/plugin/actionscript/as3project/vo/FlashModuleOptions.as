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
    
    import actionScripts.events.ASModulesEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.FlashModuleVO;

	public class FlashModuleOptions 
	{
		public var modulePaths:ArrayCollection = new ArrayCollection;
		public var projectFolderLocation:FileLocation;

		private var moduleSelectionsUntilSave:Array;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var selectionIndex:Array;
		
		public function FlashModuleOptions(folder:FileLocation)
		{
			projectFolderLocation = folder;
			
			dispatcher.addEventListener(ASModulesEvent.EVENT_ADD_MODULE, onAddModuleEvent, false, 0, true);
		}
		
		public function getSettings():Vector.<ISetting>
		{
			var settings:Vector.<ISetting> = new Vector.<ISetting>();
			
			settings.push(
				new StaticLabelSetting("Select modules to auto-compile during a project build.", 14, 0x686868)
				);
			
			// for some strange reason doing registerClassAlias
			// to FileLocation always returns wrong results.
			// this should be doing for now
			var tmpRelativePath:String;
			moduleSelectionsUntilSave = modulePaths.source.map(function(element:FlashModuleVO, index:int, arr:Array):Object
			{
				tmpRelativePath = getProjectRelativePath(element.sourcePath);

				var tmpObject:Object = {sourcePath: tmpRelativePath, isSelected: element.isSelected};
				settings.push(
					new BooleanSetting(tmpObject, "isSelected", tmpRelativePath)
				);
				return tmpObject;
			});
			
			return settings;
		}
		
		public function cancelledSettings():void
		{
			moduleSelectionsUntilSave = null;
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
			// triggers during project configuration saves
			if (moduleSelectionsUntilSave)
			{
				moduleSelectionsUntilSave.forEach(function(element:Object, index:int, arr:Array):void
				{
					modulePaths[index].isSelected = element.isSelected;
				});
				moduleSelectionsUntilSave = null;
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
				modulePaths.source.forEach(function(element:FlashModuleVO, index:int, arr:Array):void
				{
					if (element.sourcePath.fileBridge.nativePath.indexOf(fw.file.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
					{
						modulesToRemove.push(element);
					}
				});
				
				for (var i:int; i < modulesToRemove.length; i++)
				{
					modulePaths.removeItem(modulesToRemove.shift());
					i--;
				}
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
			}
			
			project.saveSettings();
		}
		
		private function onAddModuleEvent(event:ASModulesEvent):void
		{
			modulePaths.addItem(new FlashModuleVO(event.moduleFilePath));
			event.project.saveSettings();
		}
		
		private function getProjectRelativePath(value:FileLocation):String
		{
			return projectFolderLocation.fileBridge.getRelativePath(value, true);
		}
    }
}