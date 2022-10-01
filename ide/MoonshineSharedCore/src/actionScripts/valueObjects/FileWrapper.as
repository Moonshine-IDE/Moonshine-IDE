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
						if (fw.file.fileBridge.isDirectory)
							fw.isSourceFolder = testIfSourceFolder(fw);
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

		private function testIfSourceFolder(wrapper:FileWrapper):Boolean
		{
			if (!projectReference.sourceFolder) return false;

			if (projectReference.sourceFolder &&
					(wrapper.nativePath == projectReference.sourceFolder.fileBridge.nativePath))
			{
				return true;
			}

			return false;
		}
    }
}