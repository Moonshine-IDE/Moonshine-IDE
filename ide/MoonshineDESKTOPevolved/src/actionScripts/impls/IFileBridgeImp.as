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
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.utils.FileUtils;
	import actionScripts.locator.IDEModel;
	import mx.controls.Alert;
	import actionScripts.events.GeneralEvent;
	
	/**
	 * IFileBridgeImp
	 *
	 * @date 10.28.2015
	 * @version 1.0
	 */
	public class IFileBridgeImp implements IFileBridge
	{
		private var _file: File = ConstantsCoreVO.LAST_BROWSED_LOCATION ? 
			new File(ConstantsCoreVO.LAST_BROWSED_LOCATION) : 
			File.desktopDirectory;
		
		CONFIG::OSX
		{
			private var _ssb:Main = new Main();
		
			public function getSSBInterface():IScopeBookmarkInterface
			{
				return _ssb;
			}
		}
		
		/**
		 * Creating new File instance everytime
		 * to detect if exists could be expensive
		 */
		public function isPathExists(value:String):Boolean
		{
			return FileUtils.isPathExists(value);
		}
		
		public function getDirectoryListing():Array
		{
			if (!checkFileExistenceAndReport()) return [];
			return _file.getDirectoryListing();
		}
		
		public function deleteFileOrDirectory():void
		{
		}
		
		public function canonicalize():void
		{
			_file.canonicalize();
		}
		
		public function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);

			if (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION)
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
					
					if (isValidFilePath(selectedPathValue))
					{
						// to overcome a macOS bug where previously selected
						// file can return to directory browsing
						if (!testSelectionIfDirectory(null, selectedPathValue))
						{
							return;
						}
						
						selectListner(new File(selectedPathValue));
						updateCoreFilePathOnBrowse(selectedPathValue);
					}
					else if (cancelListener != null)
					{
						cancelListener();
					}
				}
				else if (cancelListener != null) 
				{
					cancelListener();
				}
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
				
				// to overcome a macOS bug where previously selected
				// file can return to directory browsing
				if (!testSelectionIfDirectory(event.target as File))
				{
					return;
				}
				
				selectListner(event.target as File);
				updateCoreFilePathOnBrowse((event.target as File).nativePath);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
			function testSelectionIfDirectory(byFile:File=null, byPath:String=null):Boolean
			{
				var isValid:Boolean;
				// to overcome a macOS bug where previously selected
				// file can return to directory browsing
				if (byFile && byFile.isDirectory)
				{
					isValid = true;
				}
				else if (byPath && FileUtils.isPathDirectory(byPath))
				{
					isValid = true;
				}
				
				if (!isValid) Alert.show("Selected file is not Directory.", "Error!");
				return isValid;
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
			try
			{
				_file.createDirectory();
			}
			catch (e:Error)
			{
				reportPathAccessError(true);
			}
		}
		
		public function getRelativePath(ref:FileLocation, useDotDot:Boolean=false):String
		{
			if (ref.fileBridge.nativePath == FileUtil.separator) return ref.fileBridge.nativePath;
			return _file.getRelativePath(ref.fileBridge.getFile as File, useDotDot);
		}
		
		public function copyTo(value:FileLocation, overwrite:Boolean = false):void
		{
			_file.copyTo(value.fileBridge.getFile as File, overwrite);
		}

        public function copyInto(locationCopyingTo:FileLocation, copyEmptyFolders:Boolean=true):void
        {
            var directory:Array = _file.getDirectoryListing();

            for each (var f:File in directory)
            {
                if (f.isDirectory)
                {
                    // Copies a folder whether it is empty or not.
                    if( copyEmptyFolders ) f.copyTo(locationCopyingTo.fileBridge.getFile.resolvePath(f.name), true);

                    // Recurse thru folder.
                    new FileLocation(f.nativePath)
							.fileBridge
							.copyInto(locationCopyingTo.fileBridge.resolvePath(f.name));

                }
                else
                {
                    f.copyTo(locationCopyingTo.fileBridge.getFile.resolvePath(f.name), true);
                }
            }
        }

		public function moveToTrashAsync():void
		{
			_file.moveToTrashAsync();
		}
		
		public function load():void
		{
			if (checkFileExistenceAndReport()) _file.load();
		}
		
		public function copyFileTemplate(dst:FileLocation, data:Object=null):void
		{
			var r:FileStream = new FileStream();
			r.open(_file, FileMode.READ);
            var content:String = r.readUTFBytes(_file.size);
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
		
		public function browseForSave(selected:Function, canceled:Function=null, title:String=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);
			
			_file.addEventListener(Event.SELECT, onSelectHandler);
			_file.addEventListener(Event.CANCEL, onCancelHandler);
			_file.browseForSave(title ? title : "");
			
			/*
			 *@local
			 */
			function onSelectHandler(event:Event):void
			{
				removeListeners(event);
				selected(event.target as File);
				updateCoreFilePathOnBrowse((event.target as File).nativePath);
			}
			function onCancelHandler(event:Event):void
			{
				removeListeners(event);
				if (canceled != null) canceled(event);
			}
			function removeListeners(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}
		
		public function moveTo(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			if (checkFileExistenceAndReport())
			{
				_file.moveTo(newLocation.fileBridge.getFile as File, overwrite);
			}
		}
		
		public function moveToAsync(newLocation:FileLocation, overwrite:Boolean=false):void
		{
			if (checkFileExistenceAndReport())
			{
				_file.moveToAsync(newLocation.fileBridge.getFile as File, overwrite);
			}
		}
		
		public function deleteDirectory(deleteDirectoryContents:Boolean=false):void
		{
			try
			{
				_file.deleteDirectory(deleteDirectoryContents);
			}
			catch (e:Error)
			{
				deleteDirectoryAsync(deleteDirectoryContents);
			}
		}
		
		public function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void
		{
			try
			{
				_file.deleteDirectoryAsync(deleteDirectoryContents);
			}
			catch (e:Error)
			{
				reportPathAccessError(true);
			}
		}
		
		public function resolveDocumentDirectoryPath(pathWith:String=null):FileLocation
		{
			if (!pathWith) return (new FileLocation(File.documentsDirectory.nativePath));
			return (new FileLocation(File.documentsDirectory.resolvePath(pathWith).nativePath));
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
		
		public function resolveTemporaryDirectoryPath(pathWith:String=null):FileLocation
		{
			if (!pathWith) return (new FileLocation(File.cacheDirectory.nativePath));
			return (new FileLocation(File.cacheDirectory.resolvePath(pathWith).nativePath));
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
				if (checkFileExistenceAndReport())
				{
					var stream:FileStream = new FileStream();
					stream.open(_file, FileMode.READ);
					saveData = stream.readUTFBytes(stream.bytesAvailable);
					stream.close();
				}
			}
			catch (e:Error)
			{
				trace(e.getStackTrace());
			}
			
			return saveData;
		}
		
		public function readAsync(provider:Object, fieldTypeReadObject:*, fieldTypeProvider:*, fieldInProvider:String=null, fieldInReadObject:String=null):void
		{
			FileUtils.readFromFileAsync(_file, FileUtils.DATA_FORMAT_STRING, onReadComplete, onReadIO);
			
			/*
			 * @local
			 */
			function onReadComplete(value:String):void
			{
				var readObj:Object = fieldTypeReadObject(value);
				if (fieldInProvider) provider[fieldInProvider] = fieldInReadObject ? fieldTypeProvider(readObj[fieldInReadObject]) : fieldTypeProvider(readObj);
				else provider = fieldInReadObject ? fieldTypeProvider(readObj[fieldInReadObject]) : fieldTypeProvider(readObj);
			}
			function onReadIO(value:String):void
			{

			}
		}
		
		public function readAsyncWithListener(onComplete:Function, onError:Function=null, fileToRead:Object=null):void
		{
			if (fileToRead && 
				!(fileToRead is FileLocation) && 
					!(fileToRead is File)) return;
			
			fileToRead ||= _file;
			
			FileUtils.readFromFileAsync((fileToRead is FileLocation) ? ((fileToRead as FileLocation).fileBridge.getFile as File) : fileToRead as File, 
				FileUtils.DATA_FORMAT_STRING, 
				onComplete, onError);
		}
		
		public function deleteFile():void
		{
			try
			{
				_file.deleteFile();
			}
			catch (e:Error)
			{
				deleteFileAsync();
			}
		}
		
		public function deleteFileAsync():void
		{
			try
			{
				_file.deleteFileAsync();
			}
			catch (e:Error)
			{
				reportPathAccessError(false);
			}
		}
		
		public function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null, startFromLocation:String=null):void
		{
			setFileInternalPath(startFromLocation);
			
			var filters:Array;
			var filtersForExt:Array = [];
			if (fileFilters)
			{
				filters = [];
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
			
			if (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION)
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
					
					if (isValidFilePath(selectedPathValue))
					{
						selectListner(new File(selectedPathValue));
						updateCoreFilePathOnBrowse(selectedPathValue);
					}
					else if (cancelListener != null) 
					{
						cancelListener();
					}
				}
				else if (cancelListener != null) 
				{
					cancelListener();
				}
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
				updateCoreFilePathOnBrowse((event.target as File).nativePath);
			}
			function onCancelHandler(event:Event):void
			{
				event.target.removeEventListener(Event.SELECT, onSelectHandler);
				event.target.removeEventListener(Event.CANCEL, onCancelHandler);
			}
		}

		public function openWithDefaultApplication():void
		{
			if (checkFileExistenceAndReport()) _file.openWithDefaultApplication();
		}
		
		public function getFileByPath(value:String):Object
		{
			return (new File(value));
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
				if (checkFileExistenceAndReport(false)) 
				{
					_file.nativePath = value;
				}
				else if (FileUtils.isPathExists(value))
				{
					_file = new File(value);
				}
				else
				{
					_file.nativePath = value;
				}
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
			if (_file && _file.exists) return _file.creationDate;
			return (new Date());
		}
		
		public function set creationDate(value:Date):void
		{
		}
		
		public function get modificationDate():Date
		{
			if (_file && _file.exists) return _file.modificationDate;
			return null;
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

		public function get nameWithoutExtension():String
		{
			var extensionIndex:int = this.name.lastIndexOf(extension);
			if (extensionIndex > -1)
			{
				return this.name.substring(0, extensionIndex - 1);
			}

			return this.name;
		}
		
		public function get userDirectory():Object
		{
			return File.userDirectory;
		}
		
		public function get desktopDirectory():Object
		{
			return File.desktopDirectory;
		}
		
		public function get documentsDirectory():Object
		{
			return File.documentsDirectory;
		}

		public function checkFileExistenceAndReport(showAlert:Boolean=true):Boolean
		{
			// we want to keep this method separate from
			// 'exists' and not add these alerts to the
			// said method, because file.exists uses against many
			// internal checks which are not intentional to throw an alert
			if (!_file.exists)
			{
				if (showAlert) 
				{
					reportPathAccessError(_file.isDirectory, false);
				}
				return false;
			}
			
			return true;
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
		
		protected function reportPathAccessError(isDirectory:Boolean, isExists:Boolean=true):void
		{
			var errorMessage:String = "\nUnable to access "+ (isDirectory ? "directory:" : "file:") + _file.nativePath;
			CONFIG::OSX
				{
					if (isDirectory && isExists)
						errorMessage += '\nPlease open File > Access Manager and click "Add Access" to to allow access to this directory.'
				}
			
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, errorMessage, false, false, ConsoleOutputEvent.TYPE_ERROR));
		}
		
		private function isValidFilePath(value:String):Boolean
		{
			if (value.indexOf("Error Domain=NSCocoaErrorDomain") != -1)
			{
				GlobalEventDispatcher.getInstance().dispatchEvent(
						new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, value, false, false, ConsoleOutputEvent.TYPE_ERROR));
				return false;
			}
			
			return true;
		}
		
		private function setFileInternalPath(startFromLocation:String):void
		{
			// set file path if requires
			try
            {
                if (startFromLocation && FileUtils.isPathExists(startFromLocation))
                {
					_file.nativePath = startFromLocation;
                }
				else
				{
					updateCoreFilePathOnBrowse(IDEModel.getInstance().fileCore.nativePath);
				}
            }
			catch(e:Error)
			{}
		}
		
		private function updateCoreFilePathOnBrowse(value:String):void
		{
			if (FileUtils.isPathDirectory(value)) ConstantsCoreVO.LAST_BROWSED_LOCATION = value;
			else ConstantsCoreVO.LAST_BROWSED_LOCATION = (new File(value)).parent.nativePath;
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new GeneralEvent(GeneralEvent.EVENT_FILE_BROWSED));
			
			IDEModel.getInstance().fileCore.nativePath = ConstantsCoreVO.LAST_BROWSED_LOCATION;
			_file.nativePath = value;
		}
	}
}