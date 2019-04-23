////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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