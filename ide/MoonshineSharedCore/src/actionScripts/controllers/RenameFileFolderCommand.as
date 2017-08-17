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
package actionScripts.controllers
{
	import flash.events.Event;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RenameFileFolderEvent;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.valueObjects.URLDescriptorVO;
	
	public class RenameFileFolderCommand implements ICommand
	{
		private var thisEvent:RenameFileFolderEvent;
		private var loader:DataAgent;
		
		public function execute(event:Event):void
		{
			thisEvent = event as RenameFileFolderEvent;
			
			thisEvent.fw.isWorking = true;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(thisEvent.oldName +": Rename in process..."));
			loader = new DataAgent(URLDescriptorVO.FILE_RENAME, onRenameSuccess, onSaveFault, {path:thisEvent.fw.file.fileBridge.nativePath, newName:thisEvent.fw.file.fileBridge.name});
		}
		
		private function onRenameSuccess(value:Object, message:String=null):void
		{
			thisEvent.fw.isWorking = false;
			
			var jsonObj:Object = JSON.parse(String(value));
			if (!jsonObj || jsonObj.nativePath == "") return;
			
			// create new object to update in tree view
			thisEvent.fw.file.fileBridge.nativePath = jsonObj.nativePath;
			thisEvent.fw.file.fileBridge.extension = jsonObj.extension;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(thisEvent.fw.file.fileBridge.name +": Renamed successfully."));
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, thisEvent.fw));
		}
		
		private function onSaveFault(message:String):void
		{
			thisEvent.fw.isWorking = false;
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(thisEvent.oldName +": Error while rename!"));
			
			// restore old name value
			thisEvent.fw.file.fileBridge.name = thisEvent.oldName;
			
			// update tree list
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, thisEvent.fw));
			
			thisEvent = null;
			loader = null;
		}
	}
}