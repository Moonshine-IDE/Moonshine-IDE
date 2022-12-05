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
package actionScripts.interfaces
{
	import actionScripts.factory.FileLocation;

	import flash.utils.ByteArray;

	[Bindable] public interface IFileBridge
	{
		CONFIG::OSX
		{
			function getSSBInterface():IScopeBookmarkInterface;
		}
		function isPathExists(value:String):Boolean;
		function getDirectoryListing():Array;
		function deleteFileOrDirectory():void;
		function onSuccessDelete(value:Object, message:String=null):void;
		function onFault(message:String=null):void;
		function canonicalize():void;
		function browseForDirectory(title:String, selectListner:Function, cancelListener:Function=null, startFromLocation:String=null):void;
		function createFile(forceIsDirectory:Boolean=false):void;
		function createDirectory():void;
		function copyTo(value:FileLocation, overwrite:Boolean = false):void;
		function copyInto(locationCopyingTo:FileLocation, copyEmptyFolders:Boolean=true):void
		function copyFileTemplate(dst:FileLocation, data:Object=null):void;
		function getRelativePath(ref:FileLocation, useDotDot:Boolean=false):String;
		function load():void;
		function save(content:Object):void;
		function browseForSave(selected:Function, canceled:Function=null, title:String=null, startFromLocation:String=null):void;
		function moveTo(newLocation:FileLocation, overwrite:Boolean=false):void;
		function moveToAsync(newLocation:FileLocation, overwrite:Boolean=false):void;
		function deleteDirectory(deleteDirectoryContents:Boolean=false):void;
		function deleteDirectoryAsync(deleteDirectoryContents:Boolean=false):void;
		function resolveUserDirectoryPath(pathWith:String=null):FileLocation;
		function resolveApplicationStorageDirectoryPath(pathWith:String=null):FileLocation;
		function resolveApplicationDirectoryPath(pathWith:String=null):FileLocation;
		function resolveTemporaryDirectoryPath(pathWith:String=null):FileLocation;
		function resolvePath(path:String, toRelativePath:String=null):FileLocation;
		function resolveDocumentDirectoryPath(pathWith:String=null):FileLocation;
		function writeToFile(data:Object):void;
		function read():Object;
		function readAsync(provider:Object, fieldTypeReadObject:*, fieldTypeProvider:*, fieldInProvider:String=null, fieldInReadObject:String=null):void;
		function readAsyncWithListener(onComplete:Function, onError:Function=null, fileToRead:Object=null):void;
		function deleteFile():void;
		function deleteFileAsync():void;
		function browseForOpen(title:String, selectListner:Function, cancelListener:Function=null, fileFilters:Array=null, startFromLocation:String=null):void;
		function moveToTrashAsync():void;
		function openWithDefaultApplication():void;
		function checkFileExistenceAndReport(showAlert:Boolean=true):Boolean;
		function getFileByPath(value:String):Object;
		
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
		function get userDirectory():Object;
		function get desktopDirectory():Object;
		function get documentsDirectory():Object;
		function get isBrowsed():Boolean;
		function get nameWithoutExtension():String;
		function get readByteArray():ByteArray;
	}
}