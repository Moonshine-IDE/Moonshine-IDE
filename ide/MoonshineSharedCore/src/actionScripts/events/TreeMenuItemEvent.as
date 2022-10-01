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
package actionScripts.events
{
	import flash.events.Event;
	
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.valueObjects.FileWrapper;

	public class TreeMenuItemEvent extends Event
	{
		public static const RIGHT_CLICK_ITEM_SELECTED:String = "menuItemSelectedEvent";
		public static const EDIT_CANCEL:String = "editCancel";
		public static const EDIT_END:String = "editEnd";
		public static const NEW_FILE_CREATED:String = "NEW_FILE_CREATED";
		public static const FILE_DELETED:String = "FILE_DELETED";
		public static const FILE_RENAMED:String = "FILE_RENAMED";
		public static const NEW_FILES_FOLDERS_COPIED:String = "NEW_FILE_FOLDER_COPIED";
		
		public var menuLabel:String;
		public var data:FileWrapper;
		public var renderer:FTETreeItemRenderer;
		public var extra:*;
		public var showAlert:Boolean;
		
		public function TreeMenuItemEvent(type:String, menuLabel:String, data:FileWrapper, showAlert:Boolean=true)
		{
			this.menuLabel = menuLabel;
			this.data = data;
			this.showAlert = showAlert;
			
			super(type, true, false);
		}
		
	}
}