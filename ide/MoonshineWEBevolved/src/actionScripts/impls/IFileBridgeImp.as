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
package actionScripts.impls
{
	import spark.components.Image;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.valueObjects.FileReference;
	import flash.utils.ByteArray;
	
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
		
		public function get isBrowsed():Boolean
		{
			return false;
		}
		
		CONFIG::OSX
		{
			public function getSSBInterface():IScopeBookmarkInterface
			{
				return null;
			}
		}
		
		public function isPathExists(value:String):Boolean
		{
			return false;
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
		
		public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null, startFromLocation:String=null):void
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
		
		public function copyTo(value:FileLocation, overwrite:Boolean = false):void
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
		
		public function browseForSave(selected:Function, canceled:Function=null, title:String=null, startFromLocation:String=null):void
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
		
		public function resolveDocumentDirectoryPath(pathWith:String=null):FileLocation
		{
			return null;
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
		
		public function resolveTemporaryDirectoryPath(pathWith:String=null):FileLocation
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
		
		public function readAsyncWithListener(onComplete:Function, onError:Function=null, fileToRead:Object=null):void
		{
		
		}
		
		public function deleteFile():void
		{
			_file.deleteFileOrDirectory();
		}
		
		public function deleteFileAsync():void
		{
			_file.deleteFileOrDirectory();
		}
		
		public function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null, startFromLocation:String=null):void
		{
			
		}
		
		public function moveToTrashAsync():void
		{
			
		}
		
		public function openWithDefaultApplication():void
		{
			
		}
		
		public function getFileByPath(value:String):Object
		{
			return (new FileReference(value));
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
		
		public function get nameWithoutExtension():String
		{
			return null;
		}
		
		public function get userDirectory():Object
		{
			return null;
		}
		
		public function get desktopDirectory():Object
		{
			return null;
		}
		
		public function get documentsDirectory():Object
		{
			return null;
		}
		
		public function get readByteArray():ByteArray
		{
			return null;
		}
		
		public function checkFileExistenceAndReport(showAlert:Boolean=true):Boolean
		{
			// this method has different importance and
			// working in desktop project
			return _file.exists;
		}
		
		public function copyInto(locationCopyingTo:FileLocation, copyEmptyFolders:Boolean=true):void
		{
			
		}
	}
}