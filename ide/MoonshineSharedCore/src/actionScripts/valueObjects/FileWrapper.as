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
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.core.sourcecontrol.ISourceControlProvider;
	
	[Bindable] dynamic public class FileWrapper
	{
		public var projectReference: ProjectReferenceVO;
		
		private var _file: FileLocation;
		private var _children: Array = [];
		
		protected var _isRoot: Boolean;
		protected var _defaultName: String;
		protected var _isWorking: Boolean;
		protected var _isDeleting: Boolean;
		protected var _sourceController:ISourceControlProvider;
		protected var _shallUpdateChildren: Boolean;
		
		public function set shallUpdateChildren(value:Boolean):void {	_shallUpdateChildren = value;	}
		public function get shallUpdateChildren():Boolean {	return _shallUpdateChildren;	}
		
		public function FileWrapper(file:FileLocation, isRoot:Boolean=false, projectRef:ProjectReferenceVO=null, shallUpdateChildren:Boolean=true)
		{
			_file = file;
			_isRoot = isRoot;
			_shallUpdateChildren = shallUpdateChildren;
			projectReference = projectRef;
			
			if (isRoot && projectRef && projectRef.name) name = projectRef.name;
			else if (file) name = file.fileBridge.name;
			
			// store filelocation reference for later
			// search through Find Resource menu option
			if (_file && _shallUpdateChildren)
			{
				updateChildren();
			}
		}
		
		public function updateChildren():void
		{
			if (!ConstantsCoreVO.IS_AIR || !file.fileBridge.isDirectory) return;
			
			var c:Array = file.fileBridge.getDirectoryListing();
			if (c.length == 0 && !file.fileBridge.isDirectory)
			{
				_children = null;
				return;
			}
			else _children = [];
			var fw: FileWrapper;
			for (var i:int = 0; i < c.length; i++)
			{
				if (!c[i].isHidden)
				{
					fw = new FileWrapper(new FileLocation(c[i].nativePath), false, projectReference, _shallUpdateChildren);
					fw.sourceController = _sourceController;
					_children.push(fw);
				}
			}
		}
		
		public function containsFile(file:FileLocation):Boolean
		{
			if (file.fileBridge.nativePath.indexOf(nativePath) == 0) return true;
			return false;
		}
		
		public function get file():FileLocation
		{
			return _file;
		}
		public function set file(v:FileLocation):void
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
			else if (file && _shallUpdateChildren) return file.fileBridge.name;
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
			if (ConstantsCoreVO.IS_AIR && !_children && _shallUpdateChildren) updateChildren();
			if (ConstantsCoreVO.IS_AIR && !file.fileBridge.isDirectory) _children = null;
				
			return _children;
		}
		public function set children(value:Array):void
		{
			_children = value;
		}
		
		public function get nativePath():String
		{
			if (!file) return null;
			return file.fileBridge.nativePath;
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
		
		public function get sourceController():ISourceControlProvider
		{
			return _sourceController;	
		}
		
		public function set sourceController(v:ISourceControlProvider):void
		{
			if (_sourceController == v) return;
			_sourceController = v;
			
			if (!children) return;
			for (var i:int = 0; i < children.length; i++)
			{
				children[i].sourceController = v;
			}	
		}
	}
}