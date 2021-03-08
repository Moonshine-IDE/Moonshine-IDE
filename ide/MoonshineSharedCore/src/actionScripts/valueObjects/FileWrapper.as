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

    [Bindable]
    public dynamic class FileWrapper
	{
		public var projectReference: ProjectReferenceVO;
		
		private var _file: FileLocation;
		private var _children:Array;
		
		private var _isRoot: Boolean;
        private var _isSourceFolder: Boolean;
        private var _defaultName: String;
        private var _isWorking: Boolean;
        private var _isDeleting: Boolean;
        private var _sourceController:ISourceControlProvider;
        private var _shallUpdateChildren: Boolean;
		private var _isHidden:Boolean;

		public function FileWrapper(file:FileLocation, isRoot:Boolean = false,
									projectRef:ProjectReferenceVO=null, shallUpdateChildren:Boolean = true)
		{
			_file = file;
			_isRoot = isRoot;
			_shallUpdateChildren = shallUpdateChildren;
			projectReference = projectRef;

			if (isRoot && projectRef && projectRef.name)
			{
				name = projectRef.name;
            }
			else if (file)
			{
				name = file.fileBridge.name;
            }
			
			// store filelocation reference for later
			// search through Find Resource menu option
			if (_file && _shallUpdateChildren)
			{
				updateChildren();
			}
		}

		public function get shallUpdateChildren():Boolean
		{
			return _shallUpdateChildren;
		}

        public function set shallUpdateChildren(value:Boolean):void
		{
			_shallUpdateChildren = value;
		}

        public function get file():FileLocation
		{
			return _file;
		}

		public function set file(value:FileLocation):void
		{
			_file = value;
		}

		public function get isHidden():Boolean
		{
			return _isHidden;
		}

		public function get isRoot():Boolean
		{
			return _isRoot;
		}
		public function set isRoot(value:Boolean):void
		{
			_isRoot = value;
		}
		
		public function get isSourceFolder():Boolean
		{
			return _isSourceFolder;
		}
		public function set isSourceFolder(value:Boolean):void
		{
			_isSourceFolder = value;
		}
		
		public function get name():String
		{
			if (isRoot && _defaultName)
			{
				return _defaultName;
            }
			else if (file && _shallUpdateChildren)
			{
				return file.fileBridge.name;
            }
			else if (!_defaultName && projectReference)
			{
				return projectReference.name;
            }
			else
			{
				return _defaultName;
            }
		}

		public function set name(value:String):void
		{
			_defaultName = value;
		}

		public function get defaultName():String
		{
			return _defaultName;
		}

		public function set defaultName(value:String):void
		{
			_defaultName = value;
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
		
		public function set sourceController(value:ISourceControlProvider):void
        {
            if (_sourceController == value) return;
            _sourceController = value;

            if (!children) return;
            for (var i:int = 0; i < children.length; i++)
            {
                children[i].sourceController = value;
            }
        }

        public function sortChildren():void
        {
            _children.sortOn("name", Array.CASEINSENSITIVE);
        }

        public function updateChildren():void
        {
            if (!ConstantsCoreVO.IS_AIR)
            {
                return;
            }

            if (projectReference)
            {
                if (projectReference.showHiddenPaths)
                {
                    _isHidden = projectReference.hiddenPaths.some(function (item:FileLocation, index:int, arr:Vector.<FileLocation>):Boolean
                    {
                        return nativePath == item.fileBridge.nativePath;
                    });
                }
                else
                {
                    _isHidden = false;
                }
            }

            if (!file.fileBridge.isDirectory)
            {
                return;
            }

            var directoryListing:Array = file.fileBridge.getDirectoryListing();
            if (directoryListing.length == 0 && !file.fileBridge.isDirectory)
            {
                _children = null;
                return;
            }
            else
            {
                _children = [];
            }

            var fw:FileWrapper;
            var directoryListingCount:int = directoryListing.length;

            for (var i:int = 0; i < directoryListingCount; i++)
            {
                var currentDirectory:Object = directoryListing[i];

				if (currentDirectory.isHidden)
				{
					continue;
                }

				if (projectReference.showHiddenPaths)
				{
					fw = new FileWrapper(new FileLocation(currentDirectory.nativePath), false, projectReference, false);
					fw.children = [];
					fw.sourceController = _sourceController;
					_children.push(fw);
				}
                else
                {
                    var currentIsHidden:Boolean = projectReference && projectReference.hiddenPaths.some(function (item:FileLocation, index:int, arr:Vector.<FileLocation>):Boolean
                    {
                        return currentDirectory.nativePath == item.fileBridge.nativePath;
                    });

					if (!currentIsHidden)
                    {
                        fw = new FileWrapper(new FileLocation(currentDirectory.nativePath), false, projectReference, false);
						fw.children = [];
                        fw.sourceController = _sourceController;
                        _children.push(fw)
                    }
                }
            }
        }

        public function containsFile(file:FileLocation):Boolean
        {
            if (file.fileBridge.nativePath.indexOf(nativePath) == 0) return true;
            return false;
        }
    }
}