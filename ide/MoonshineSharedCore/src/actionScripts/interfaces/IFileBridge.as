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
package actionScripts.interfaces
{
	import actionScripts.factory.FileLocation;

	[Bindable] public interface IFileBridge
	{
		CONFIG::OSX
		{
			function getSSBInterface():IScopeBookmarkInterface;
		}
		function getDirectoryListing():Array;
		function deleteFileOrDirectory():void;
		function onSuccessDelete(value:Object, message:String=null):void;
		function onFault(message:String=null):void;
		function canonicalize():void;
		function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null):void;
		function createFile(forceIsDirectory:Boolean=false):void;
		function createDirectory():void;
		function copyTo(value:FileLocation):void;
		function copyFileTemplate(dst:FileLocation, data:Object=null):void;
		function getRelativePath(ref:FileLocation, useDotDot:Boolean=false):String;
		function load():void;
		function save(content:Object):void;
		function browseForSave(selected:Function, canceled:Function, title:String=null):void;
		function moveTo(newLocation:FileLocation, overwrite:Boolean=false):void;
		function moveToAsync(newLocation:FileLocation, overwrite:Boolean=false):void;
		function deleteDirectory(deleteDirectoryContents:Boolean=false):void;
		function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void;
		function resolveUserDirectoryPath(pathWith:String=null):FileLocation;
		function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileLocation;
		function resolveApplicationDirectoryPath(pathWith:String=null):FileLocation;
		function resolvePath(path:String, toRelativePath:String=null):FileLocation;
		function read():Object;
		function readAsync(provider:Object, fieldTypeReadObject:*, fieldTypeProvider:*, fieldInProvider:String=null, fieldInReadObject:String=null):void;
		function deleteFile():void;
		function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null):void;
		function moveToTrashAsync():void;
		
		function get url():String;
		function set url(value:String):void
		function get separator():String;
		function get getFile():Object;
		function get parent():FileLocation;
		function get exists():Boolean;
		function set exists(value:Boolean):void;
		function get icon():Object;
		function set icon(value:Object):void;
		function get isDirectory():Boolean;
		function set isDirectory(value:Boolean):void;
		function get isHidden():Boolean;
		function set isHidden(value:Boolean):void;
		function get isPackaged():Boolean;
		function set isPackaged(value:Boolean):void;
		function get nativePath():String;
		function set nativePath(value:String):void;
		function get nativeURL():String;
		function set nativeURL(value:String):void;
		function get creator():String;
		function set creator(value:String):void;
		function get extension():String;
		function set extension(value:String):void;
		function get name():String;
		function set name(value:String):void;
		function get type():String;
		function set type(value:String):void;
		function get creationDate():Date;
		function set creationDate(value:Date):void;
		function get modificationDate():Date;
		function set modificationDate(value:Date):void;
		function get data():Object;
		function set data(value:Object):void;
	}
}