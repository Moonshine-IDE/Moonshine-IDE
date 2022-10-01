////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.locator
{
	import flash.events.Event;
	
	import actionScripts.controllers.AddTabCommand;
	import actionScripts.controllers.CloseTabCommand;
	import actionScripts.controllers.DeleteFileCommand;
	import actionScripts.controllers.ICommand;
	import actionScripts.controllers.OpenFileCommand;
	import actionScripts.controllers.OpenLocationCommand;
	import actionScripts.controllers.QuitCommand;
	import actionScripts.controllers.RenameFileFolderCommand;
	import actionScripts.controllers.SaveAsCommand;
	import actionScripts.controllers.SaveFileCommand;
	import actionScripts.controllers.UpdateTabCommand;
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.DeleteFileEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.events.RenameFileFolderEvent;
	import actionScripts.events.UpdateTabEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	
	public class IDEController
	{
		protected var commands:Object = {};

		public function IDEController() 
		{
			init();
		}

		public function init():void 
		{
			setupBindings();
			setupListener();
		}
		
		public function setupBindings():void 
		{	
			commands[CloseTabEvent.EVENT_CLOSE_TAB] = CloseTabCommand;
			commands[CloseTabEvent.EVENT_CLOSE_ALL_TABS] = CloseTabCommand;
			commands[CloseTabEvent.EVENT_CLOSE_ALL_OTHER_TABS] = CloseTabCommand;
			commands[OpenFileEvent.OPEN_FILE] = OpenFileCommand;
			commands[OpenFileEvent.TRACE_LINE] = OpenFileCommand;
			commands[OpenFileEvent.JUMP_TO_SEARCH_LINE] = OpenFileCommand;
			commands[AddTabEvent.EVENT_ADD_TAB] = AddTabCommand;
			commands[OpenLocationEvent.OPEN_LOCATION] = OpenLocationCommand;
			commands[UpdateTabEvent.EVENT_TAB_UPDATED_OUTSIDE] = UpdateTabCommand;
			commands[UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE] = UpdateTabCommand;
			
			commands[MenuPlugin.MENU_SAVE_AS_EVENT] = SaveAsCommand;
			commands[MenuPlugin.MENU_SAVE_EVENT] = SaveFileCommand; 
			commands[MenuPlugin.MENU_QUIT_EVENT] = QuitCommand;
			commands[DeleteFileEvent.EVENT_DELETE_FILE] = DeleteFileCommand;
			commands[RenameFileFolderEvent.RENAME_FILE_FOLDER] = RenameFileFolderCommand;
			
			/*commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN] = 	ChangeLineEndingCommand;
			commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX] =	ChangeLineEndingCommand;
			commands[ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9] =		ChangeLineEndingCommand;*/
		}
		
		public function setupListener():void 
		{
			var ged:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
			for (var eventName:String in commands) 
			{
				ged.addEventListener(eventName, execCommand);
			}
		}
		
		public function execCommand(event:Event):void
		{
			var cmd:ICommand = new commands[event.type]();
			cmd.execute(event);
		}
		
	}
}