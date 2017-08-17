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