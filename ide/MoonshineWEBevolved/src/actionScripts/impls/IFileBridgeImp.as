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
package actionScripts.impls
{
	import spark.components.Image;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.valueObjects.FileReference;
	
	CONFIG::OSX
	{
		import actionScripts.interfaces.IScopeBookmarkInterface;
	}
	
	/**
	 * IFileBridgeImp
	 *
	 * @date 11.17.2015
	 * @version 1.0
	 */
	public class IFileBridgeImp implements IFileBridge
	{
		private var _file: FileReference = new FileReference();
		
		CONFIG::OSX
		{
			public function getSSBInterface():IScopeBookmarkInterface
			{
				return null;
			}
		}
		
		public function getDirectoryListing():Array
		{
			return _file.getDirectoryListing();
		}
		
		public function deleteFileOrDirectory():void
		{
			_file.deleteFileOrDirectory();
		}
		
		public function onSuccessDelete(value:Object, message:String=null):void
		{
			//TODO: implement function
		}
		
		public function onFault(message:String=null):void
		{
			//TODO: implement function
		}
		
		public function canonicalize():void
		{
			//TODO: implement function
		}
		
		public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null):void
		{
			//TODO: implement function
		}
		
		public function createFile(forceIsDirectory:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function createDirectory():void
		{
			//TODO: implement function
		}
		
		public function copyTo(value:FileLocation):void
		{
			//TODO: implement function
		}
		
		public function copyFileTemplate(dst:FileLocation, data:Object=null):void
		{
			//TODO: implement function
		}
		
		public function getRelativePath(ref:FileLocation, useDotDot:Boolean=false):String
		{
			//TODO: implement function
			return null;
		}
		
		public function load():void
		{
			//TODO: implement function
		}
		
		public function save(content:Object):void
		{
			//TODO: implement function
		}
		
		public function browseForSave(selected:Function, canceled:Function, title:String=null):void
		{
			//TODO: implement function
		}
		
		public function moveTo(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function moveToAsync(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function deleteDirectory(deleteDirectoryContents:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void
		{
			//TODO: implement function
		}
		
		public function resolveUserDirectoryPath(pathWith:String=null):FileLocation
		{
			return null;
		}
		
		public function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileLocation
		{
			//TODO: implement function
			return null;
		}
		
		public function resolveApplicationDirectoryPath(pathWith:String=null):FileLocation
		{
			return null;
		}
		
		public function resolvePath(path:String, toRelativePath:String=null):FileLocation
		{
			//TODO: implement function
			return (new FileLocation(path));
		}
		
		public function read():Object
		{
			return null;
		}
		
		public function readAsync(provider:Object, fieldTypeReadObject:*, fieldTypeProvider:*, fieldInProvider:String=null, fieldInReadObject:String=null):void
		{
			
		}
		
		public function deleteFile():void
		{
			_file.deleteFileOrDirectory();
		}
		
		public function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null):void
		{
			
		}
		
		public function moveToTrashAsync():void
		{
			
		}
		
		public function get url():String
		{
			//TODO: implement function
			return null;
		}
		
		public function set url(value:String):void
		{
		}
		
		public function get separator():String
		{
			//TODO: implement function
			return null;
		}
		
		public function get getFile():Object
		{
			//TODO: implement function
			return _file;
		}
		
		public function get parent():FileLocation
		{
			//TODO: implement function
			return null;
		}
		
		public function get exists():Boolean
		{
			return _file.exists;
		}
		
		public function set exists(value:Boolean):void
		{
			_file.exists = value;
		}
		
		public function get icon():Object
		{
			return _file.icon;
		}
		
		public function set icon(value:Object):void
		{
			_file.icon = value as Image;
		}
		
		public function get isDirectory():Boolean
		{
			return _file.isDirectory;
		}
		
		public function set isDirectory(value:Boolean):void
		{
			_file.isDirectory = value;
		}
		
		public function get isHidden():Boolean
		{
			return _file.isHidden;
		}
		
		public function set isHidden(value:Boolean):void
		{
			_file.isHidden = value;
		}
		
		public function get isPackaged():Boolean
		{
			return _file.isPackaged;
		}
		
		public function set isPackaged(value:Boolean):void
		{
			_file.isPackaged = value;
		}
		
		public function get nativePath():String
		{
			return _file.nativePath;
		}
		
		public function set nativePath(value:String):void
		{
			_file.nativePath = value;
		}
		
		public function get nativeURL():String
		{
			return _file.nativeURL;
		}
		
		public function set nativeURL(value:String):void
		{
			_file.nativeURL = value;
		}
		
		public function get creator():String
		{
			return _file.creator;
		}
		
		public function set creator(value:String):void
		{
			_file.creator = value;
		}
		
		public function get extension():String
		{
			return _file.extension;
		}
		
		public function set extension(value:String):void
		{
			_file.extension = value;
		}
		
		public function get name():String
		{
			return _file.name;
		}
		
		public function set name(value:String):void
		{
			_file.name = value;
		}
		
		public function get type():String
		{
			return _file.type;
		}
		
		public function set type(value:String):void
		{
			_file.type = value;
		}
		
		public function get creationDate():Date
		{
			return _file.creationDate;
		}
		
		public function set creationDate(value:Date):void
		{
			_file.creationDate = value;
		}
		
		public function get modificationDate():Date
		{
			return _file.modificationDate;
		}
		
		public function set modificationDate(value:Date):void
		{
			_file.modificationDate = value;
		}
		
		public function get data():Object
		{
			return _file.data;
		}
		
		public function set data(value:Object):void
		{
			_file.data = value;
		}
	}
}