////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, thisEvent.oldName +": Rename in process..."));
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
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, thisEvent.fw.file.fileBridge.name +": Renamed successfully."));
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, thisEvent.fw));
		}
		
		private function onSaveFault(message:String):void
		{
			thisEvent.fw.isWorking = false;
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, thisEvent.oldName +": Error while rename!"));
			
			// restore old name value
			thisEvent.fw.file.fileBridge.name = thisEvent.oldName;
			
			// update tree list
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, thisEvent.fw));
			
			thisEvent = null;
			loader = null;
		}
	}
}