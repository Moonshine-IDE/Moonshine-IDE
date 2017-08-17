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
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	CONFIG::OSX
	{
		// ** IMPORTANT **
		// DO NOT DELETE THE IMPORT EVEN IF 
		// IT'S SHOWING WARNING AS NON-USED CLASS
		import net.prominic.SecurityScopeBookmark.Main;
	}
	
	import org.as3commons.asblocks.utils.FileUtil;
	import actionScripts.interfaces.IScopeBookmarkInterface;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import flash.events.IOErrorEvent;
	
	/**
	 * IFileBridgeImp
	 *
	 * @date 10.28.2015
	 * @version 1.0
	 */
	public class IFileBridgeImp implements IFileBridge
	{
		private var _file: File = new File();
		
		CONFIG::OSX
		{
			private var _ssb:Main = new Main();
		
			public function getSSBInterface():IScopeBookmarkInterface
			{
				return _ssb;
			}
		}
		
		public function getDirectoryListing():Array
		{
			return _file.getDirectoryListing();
		}
		
		public function deleteFileOrDirectory():void
		{
		}
		
		public function canonicalize():void
		{
			_file.canonicalize();
		}
		
		public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null):void
		{
			if (ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_DEVELOPMENT_MODE)
			{
				var selectedPathValue: String;
				var relativePathToOpen: String = "";
				try
				{
					if (_file && exists) relativePathToOpen = "file://"+ _file.nativePath;
				} catch (e:Error)
				{}
				CONFIG::OSX
				{
					selectedPathValue = _ssb.addNewPath(relativePathToOpen, true);
				}

				if (selectedPathValue) 
				{
					if (selectedPathValue == "null") 
					{
						if (cancelListener != null) cancelListener();
						return;
					}
					
					// update the path to bookmarked list
					var tmpArr:Array = OSXBookmarkerNotifiers.availableBookmarkedPaths.split(",");
					if (tmpArr.indexOf(selectedPathValue) == -1) OSXBookmarkerNotifiers.availableBookmarkedPaths += ","+ selectedPathValue;
					
					selectListner(new File(selectedPathValue));
				}
				else if (cancelListener != null) cancelListener();
			}
			else
			{
				_file.addEventListener(Event.SELECT, onSelectHandler);
				_file.addEventListener(Event.CANCEL, onCancelHandler);
				_file.browseForDirectory(title);
			}
			
			/*
			 *@local
			 */
			function onSelectHandler(event:Event):void
			{
				onCancelHandler(event);
				selectListner(event.target as File);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}
		
		public function onSuccessDelete(value:Object, message:String=null):void
		{
		}
		
		public function onFault(message:String=null):void
		{
		}
		
		public function createDirectory():void
		{
			_file.createDirectory();
		}
		
		public function getRelativePath(ref:FileLocation, useDotDot:Boolean=false):String
		{
			if (ref.fileBridge.nativePath == FileUtil.separator) return ref.fileBridge.nativePath;
			return _file.getRelativePath(ref.fileBridge.getFile as File, useDotDot);
		}
		
		public function copyTo(value:FileLocation):void
		{
			_file.copyTo(value.fileBridge.getFile as File);
		}
		
		public function moveToTrashAsync():void
		{
			_file.moveToTrashAsync();
		}
		
		public function load():void
		{
			_file.load();
		}
		
		public function copyFileTemplate(dst:FileLocation, data:Object=null):void
		{
			var content:String;
			var r:FileStream = new FileStream();
			r.open(_file, FileMode.READ);
			content = r.readUTFBytes(_file.size);
			r.close();
			
			content = replace(content, data);
			
			var w:FileStream = new FileStream();
			w.open(dst.fileBridge.getFile as File, FileMode.WRITE);
			w.writeUTFBytes(content);
			w.close();
		}
		
		public function createFile(forceIsDirectory:Boolean=false):void
		{
			FileUtil.createFile(_file, forceIsDirectory);
		}
		
		public function save(content:Object):void
		{
			var fs:FileStream = new FileStream();
			fs.open(_file, FileMode.WRITE);
			fs.writeUTFBytes(String(content));
			fs.close();
		}
		
		public function browseForSave(selected:Function, canceled:Function, title:String=null):void
		{
			_file.addEventListener(Event.SELECT, selected);
			_file.addEventListener(Event.CANCEL, canceled);
			_file.browseForSave(title ? title : "");
		}
		
		public function moveTo(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			_file.moveTo(newLocation.fileBridge.getFile as File, overwrite);
		}
		
		public function moveToAsync(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			_file.moveToAsync(newLocation.fileBridge.getFile as File, overwrite);
		}
		
		public function deleteDirectory(deleteDirectoryContents:Boolean=false):void
		{
			_file.deleteDirectory(deleteDirectoryContents);
		}
		
		public function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void
		{
			_file.deleteDirectoryAsync(deleteDirectoryContents);
		}
		
		public function resolveUserDirectoryPath(pathWith:String=null):FileLocation
		{
			if (!pathWith) return (new FileLocation(File.userDirectory.nativePath));
			return (new FileLocation(File.userDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileLocation
		{
			if (!pathWith) return (new FileLocation(File.applicationStorageDirectory.nativePath));
			return (new FileLocation(File.applicationStorageDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolveApplicationDirectoryPath(pathWith:String=null):FileLocation
		{
			if (!pathWith) return (new FileLocation(File.applicationDirectory.nativePath));
			return (new FileLocation(File.applicationDirectory.resolvePath(pathWith).nativePath));
		}
		
		public function resolvePath(path:String, toRelativePath:String=null):FileLocation
		{
			var tmpFile:File = toRelativePath ? new File(toRelativePath).resolvePath(path) : _file.resolvePath(path);
			return (new FileLocation(tmpFile.nativePath));
		}
		
		public function read():Object
		{
			var saveData:Object;
			try
			{
				var stream:FileStream = new FileStream();
				stream.open(_file, FileMode.READ);
				saveData = stream.readUTFBytes(stream.bytesAvailable);
				stream.close();
			}
			catch (e:Error)
			{}
			
			return saveData;
		}
		
		public function readAsync(provider:Object, fieldTypeReadObject:*, fieldTypeProvider:*, fieldInProvider:String=null, fieldInReadObject:String=null):void
		{
			var stream:FileStream = new FileStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR, onReadIO);
			stream.addEventListener(Event.COMPLETE, onReadComplete);
			stream.openAsync(_file, FileMode.READ);
			
			/*
			 * @local
			 */
			function onReadComplete(event:Event):void
			{
				var readObj:Object = fieldTypeReadObject(event.target.readUTFBytes(event.target.bytesAvailable));
				if (fieldInProvider) provider[fieldInProvider] = fieldInReadObject ? fieldTypeProvider(readObj[fieldInReadObject]) : fieldTypeProvider(readObj);
				else provider = fieldInReadObject ? fieldTypeProvider(readObj[fieldInReadObject]) : fieldTypeProvider(readObj);
				
				event.target.close();
				event.target.removeEventListener(IOErrorEvent.IO_ERROR, onReadIO);
				event.target.removeEventListener(Event.COMPLETE, onReadComplete);
			}
			function onReadIO(event:IOErrorEvent):void
			{
				//Alert.show(event.toString());
				event.target.close();
				event.target.removeEventListener(IOErrorEvent.IO_ERROR, onReadIO);
				event.target.removeEventListener(Event.COMPLETE, onReadComplete);
			}
		}
		
		public function deleteFile():void
		{
			_file.deleteFile();
		}
		
		public function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null):void
		{
			var filters:Array;
			var filtersForExt:Array = [];
			if (fileFilters)
			{
				filters = new Array();
				//"*.as;*.mxml;*.css;*.txt;*.js;*.xml"
				for each (var i:String in fileFilters)
				{
					filters.push(new FileFilter("Open", i));
					var extSplit:Array = i.split(";");
					for each (var j:String in extSplit)
					{
						filtersForExt.push(j.split(".")[1]);
					}
				}
			}
			
			if (ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_DEVELOPMENT_MODE)
			{
				var selectedPathValue: String;
				var relativePathToOpen: String = "";
				try
				{
					if (_file && exists) relativePathToOpen = "file://"+ _file.nativePath;
				} catch (e:Error)
				{}
				CONFIG::OSX
				{
					selectedPathValue = _ssb.addNewPath(relativePathToOpen, false, (filtersForExt.length > 0) ? filtersForExt.join(",") : "");
				}
					
				if (selectedPathValue)
				{
					if (selectedPathValue == "null") 
					{
						if (cancelListener != null) cancelListener();
						return;
					}
					
					selectListner(new File(selectedPathValue));
				}
				else if (cancelListener != null) cancelListener();
			}
			else
			{
				_file.addEventListener(Event.SELECT, onSelectHandler);
				_file.addEventListener(Event.CANCEL, onCancelHandler);
				_file.browseForOpen(title, filters);
			}
			
			/*
			*@local
			*/
			function onSelectHandler(event:Event):void
			{
				onCancelHandler(event);
				selectListner(event.target as File);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}
		
		public function get url():String
		{
			return _file.url;
		}

		public function set url(value:String):void
		{
			_file.url = value;
		}
		
		public function get parent():FileLocation
		{
			return (new FileLocation(_file.parent.nativePath));
		}
		
		public function get separator():String
		{
			return File.separator;
		}
		
		public function get getFile():Object
		{
			return _file;
		}
		
		public function get exists():Boolean
		{
			try
			{
				return _file.exists;
			}
			catch (e:Error)
			{
			}
			
			return false;
		}
		
		public function set exists(value:Boolean):void
		{
		}
		
		public function get icon():Object
		{
			return _file.icon;
		}
		
		public function set icon(value:Object):void
		{
		}
		
		public function get isDirectory():Boolean
		{
			return _file.isDirectory;
		}
		
		public function set isDirectory(value:Boolean):void
		{
		}
		
		public function get isHidden():Boolean
		{
			return _file.isHidden;
		}
		
		public function set isHidden(value:Boolean):void
		{
		}
		
		public function get isPackaged():Boolean
		{
			return _file.isPackage;
		}
		
		public function set isPackaged(value:Boolean):void
		{
		}
		
		public function get nativePath():String
		{
			return _file.nativePath;
		}
		
		public function set nativePath(value:String):void
		{
			try
			{
				_file.nativePath = value;
			}
			catch (e:Error)
			{
				trace(value +": "+ e.message);
			}
		}
		
		public function get nativeURL():String
		{
			return _file.nativePath;
		}
		
		public function set nativeURL(value:String):void
		{
		}
		
		public function get creator():String
		{
			return _file.creator;
		}
		
		public function set creator(value:String):void
		{
		}
		
		public function get extension():String
		{
			return _file.extension;
		}
		
		public function set extension(value:String):void
		{
		}
		
		public function get name():String
		{
			return _file.name;
		}
		
		public function set name(value:String):void
		{
		}
		
		public function get type():String
		{
			return _file.type;
		}
		
		public function set type(value:String):void
		{
		}
		
		public function get creationDate():Date
		{
			if (_file) return _file.creationDate;
			return (new Date());
		}
		
		public function set creationDate(value:Date):void
		{
		}
		
		public function get modificationDate():Date
		{
			return _file.modificationDate;
		}
		
		public function set modificationDate(value:Date):void
		{
		}
		
		public function get data():Object
		{
			return _file.data;
		}
		
		public function set data(value:Object):void
		{
		}
		
		public static function replace(content:String, data:Object):String
		{
			for (var key:String in data)
			{
				var re:RegExp = new RegExp(TextUtil.escapeRegex(key), "g");
				content = content.replace(re, data[key]);
			}
			
			return content;
		}
	}
}