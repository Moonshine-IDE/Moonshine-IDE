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
	import flash.filesystem.File;
	
	import actionScripts.utils.WorkerSearchInProjects;

	[Bindable] dynamic public class WorkerFileWrapper
	{
		public var projectReference: Object;
		public var searchCount:int;
		public var lineNumbersWithRange:Array;
		public var fileReference:String;
		
		private var _file: File;
		private var _children: Array = [];
		
		protected var _isRoot: Boolean;
		protected var _defaultName: String;
		protected var _isWorking: Boolean;
		protected var _isDeleting: Boolean;
		protected var _shallUpdateChildren: Boolean;
		protected var _isShowAsLineNumber:Boolean;
		protected var _lineText:String;
		
		public function set shallUpdateChildren(value:Boolean):void {	_shallUpdateChildren = value;	}
		public function get shallUpdateChildren():Boolean {	return _shallUpdateChildren;	}
		
		public function WorkerFileWrapper(file:File, isRoot:Boolean=false, projectRef:Object=null, shallUpdateChildren:Boolean=true)
		{
			_file = file;
			_isRoot = isRoot;
			_shallUpdateChildren = shallUpdateChildren;
			projectReference = projectRef;
			
			if (isRoot && projectRef && projectRef.name) name = projectRef.name;
			else if (file) name = file.name;
			
			WorkerSearchInProjects.FILES_COUNT++;
			
			// store filelocation reference for later
			// search through Find Resource menu option
			if (_file && _shallUpdateChildren)
			{
				updateChildren();
			}
		}
		
		public function updateChildren():void
		{
			if (!file.isDirectory) return;
			
			var directoryListing:Array = file.getDirectoryListing();
			if (directoryListing.length == 0 && !file.isDirectory)
			{
				_children = null;
				return;
			}
			else _children = [];
			var fw: WorkerFileWrapper;
			var directoryListingCount:int = directoryListing.length;
			
			for (var i:int = 0; i < directoryListingCount; i++)
			{
				var currentDirectory:Object = directoryListing[i];
				/*var hasHiddenPath:Boolean = projectReference.hiddenPaths.some(function(item:Object, index:int, arr:Vector.<Object>):Boolean
				{
					return currentDirectory.nativePath == item.fileBridge.nativePath;
				});*/
				
				if (!currentDirectory.isHidden)
				{
					fw = new WorkerFileWrapper(new File(currentDirectory.nativePath), false, projectReference, _shallUpdateChildren);
					_children.push(fw);
				}
			}
		}
		
		public function containsFile(file:File):Boolean
		{
			if (file.nativePath.indexOf(nativePath) == 0) return true;
			return false;
		}
		
		public function get file():File
		{
			return _file;
		}
		public function set file(v:File):void
		{
			_file = v;
		}
		
		public function get isRoot():Boolean
		{
			return _isRoot;
		}
		public function set isRoot(value:Boolean):void
		{
			_isRoot = value;
		}
		
		public function get name():String
		{
			if (isRoot && _defaultName) return _defaultName;
			else if (file && _shallUpdateChildren) return file.name;
			else if (!_defaultName && projectReference) return projectReference.name;
			else return _defaultName;
		}
		public function set name(value:String):void
		{
			_defaultName = value;
		}
		
		public function get defaultName():String
		{
			return _defaultName;
		}
		public function set defaultName(v:String):void
		{
			_defaultName = v;
		}
		
		public function get children():Array
		{
			if (!_children && _shallUpdateChildren && !isShowAsLineNumber) updateChildren();
			
			return _children;
		}
		public function set children(value:Array):void
		{
			_children = value;
		}
		
		public function get nativePath():String
		{
			if (!file) return null;
			return file.nativePath;
		}
		
		public function set isWorking(value:Boolean):void
		{
			_isWorking = value;
		}
		public function get isWorking():Boolean
		{
			return _isWorking;
		}
		
		public function set isDeleting(value:Boolean):void
		{
			_isDeleting = value;
		}
		public function get isDeleting():Boolean
		{
			return _isDeleting;
		}
		
		public function get isShowAsLineNumber():Boolean
		{
			return _isShowAsLineNumber;
		}
		public function set isShowAsLineNumber(value:Boolean):void
		{
			_isShowAsLineNumber = value;
			if (_isShowAsLineNumber) children = null;
		}
		
		public function set lineText(value:String):void
		{
			_lineText = value;
		}
		public function get lineText():String
		{
			return _lineText;
		}
	}
}