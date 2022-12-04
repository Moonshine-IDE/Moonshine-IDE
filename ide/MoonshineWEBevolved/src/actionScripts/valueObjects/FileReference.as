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
package actionScripts.valueObjects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import spark.components.Image;
	
	import actionScripts.controllers.DataAgent;

	[Bindable] public class FileReference extends EventDispatcher
	{
		private var _exists: Boolean;
		private var _icon: Image;
		private var _isDirectory: Boolean;
		private var _isHidden: Boolean;
		private var _isPackaged: Boolean;
		private var _nativePath: String;
		private var _nativeURL: String;
		private var _creationDate: Date;
		private var _creator: String;
		private var _data: Object;
		private var _extension: String;
		private var _modificationDate: Date;
		private var _name: String;
		private var _type: String;
		
		public function FileReference(filePathInString:String=null)
		{
			nativePath = filePathInString;
		}
		
		public function getDirectoryListing():Array
		{
			return null;
		}
		
		public function get exists():Boolean
		{
			return _exists;
		}
		public function set exists(value:Boolean):void
		{
			_exists = value;
		}
		
		public function get icon():Image
		{
			return _icon;
		}
		public function set icon(value:Image):void
		{
			_icon = value;
		}
		
		public function get isDirectory():Boolean
		{
			return _isDirectory;
		}
		public function set isDirectory(value:Boolean):void
		{
			_isDirectory = value;
		}
		
		public function get isHidden():Boolean
		{
			return _isHidden;
		}
		public function set isHidden(value:Boolean):void
		{
			_isHidden = value;
		}
		
		public function get isPackaged():Boolean
		{
			return _isPackaged;
		}
		public function set isPackaged(value:Boolean):void
		{
			_isPackaged = value;
		}
		
		public function get nativePath():String
		{
			return _nativePath;
		}
		public function set nativePath(value:String):void
		{
			_nativePath = value;
		}
		
		public function get nativeURL():String
		{
			return _nativeURL;
		}
		public function set nativeURL(value:String):void
		{
			_nativeURL = value;
		}
		
		public function get creator():String
		{
			return _creator;
		}
		public function set creator(value:String):void
		{
			_creator = value;
		}
		
		public function get extension():String
		{
			return _extension;
		}
		public function set extension(value:String):void
		{
			_extension = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get type():String
		{
			return _type;
		}
		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function get creationDate():Date
		{
			return _creationDate;
		}
		public function set creationDate(value:Date):void
		{
			_creationDate = value;
		}
		
		public function get modificationDate():Date
		{
			return _modificationDate;
		}
		public function set modificationDate(value:Date):void
		{
			_modificationDate = value;
		}
		
		public function get data():Object
		{
			return _data;
		}
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		public function deleteFileOrDirectory():void
		{
			var tmpLoader: DataAgent = new DataAgent(URLDescriptorVO.FILE_REMOVE, onSuccessDelete, onFault, {path:nativePath}, DataAgent.POSTEVENT);
		}
		
		private function onSuccessDelete(value:Object, message:String=null):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onFault(message:String=null):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}