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
package actionScripts.plugin.actionscript.as3project.settings
{
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	
	public class PathListSetting extends AbstractSetting
	{
		protected var copiedPaths:ArrayCollection;
		
		public var allowFiles:Boolean;
		public var allowFolders:Boolean;
		public var fileMustExist:Boolean;
		public var relativeRoot:FileLocation;
		public var customMessage:IVisualElement;
		public var displaySourceFolder:Boolean;
		
		private var rdr:PathListSettingRenderer;
		
		public function PathListSetting(provider:Object, name:String, label:String, 
										relativeRoot:FileLocation=null,
										allowFiles:Boolean=true,
										allowFolders:Boolean=true,
										fileMustExist:Boolean=true,
										displaySourceFolder:Boolean=false)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.allowFiles = allowFiles;
			this.allowFolders = allowFolders;
			this.fileMustExist = fileMustExist;
			this.relativeRoot = relativeRoot;
			this.displaySourceFolder = displaySourceFolder;
			defaultValue = "";
		}
		
		override public function set stringValue(v:String):void 
		{
			if (v != "")
			{
				var toRet:Vector.<FileLocation> = new Vector.<FileLocation>();
				var values:Array = v.split(",");
				for each (var value:String in values)
				{
					toRet.push( new FileLocation(value) );
				}
			}
			setPendingSetting(toRet);
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new PathListSettingRenderer();
			rdr.setting = this;
			rdr.enabled = _isEditable;
			return rdr;
		}
		
		public function get paths():ArrayCollection
		{
			if (!copiedPaths)
			{
				if (getSetting() == null) return null;
				
				copiedPaths = new ArrayCollection();
				for each (var f:FileLocation in getSetting())
				{
					var tmpPath:PathListItemVO = new PathListItemVO(f, getLabelFor(f));
					if (displaySourceFolder &&
						provider.hasOwnProperty("sourceFolder") && 
						provider["sourceFolder"] &&
						FileLocation(provider["sourceFolder"]).fileBridge.nativePath == f.fileBridge.nativePath) tmpPath.isMainSourceFolder = true;
					copiedPaths.addItem(tmpPath);
				}
			}
			return copiedPaths;
		}
		
		override public function valueChanged():Boolean
        {
        	if (!copiedPaths) return false;
        	
			var tmpString:String = "";
        	var matches:Boolean = true;
        	var itemMatch:Boolean;
        	for each (var f1:FileLocation in getSetting())
        	{
        		itemMatch = false;
        		for each (var item:PathListItemVO in copiedPaths)
        		{
					if (item.file)
					{
						tmpString += f1.fileBridge.nativePath +" : "+ item.file.fileBridge.nativePath +"\n";
	        			if (f1.fileBridge.nativePath == item.file.fileBridge.nativePath)
	        			{
	        				itemMatch = true;
	        			}
					}
        		}
        		
        		if (!itemMatch)
        		{
        			matches = false;
        			break;
        		}
        	}
        	
        	// Length mismatch?
        	if (getSetting() && copiedPaths)
        	{
        		if (getSetting().length != copiedPaths.length)
        		{
        			matches = false;	
        		}
        	}
			
        	return !matches;
        }
        
        override public function commitChanges():void
		{
			if (!hasProperty() || !valueChanged()) return;
			
			var pending:Vector.<FileLocation> = new Vector.<FileLocation>();
			for each (var item:PathListItemVO in copiedPaths)
			{
				if (item.label != PathListSettingRenderer.NOT_SET_PATH_MESSAGE) pending.push(item.file);
			}
			
			provider[name] = pending;
			hasPendingChanges = false;
		}
		
		private var _isEditable:Boolean = true;
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) rdr.enabled = _isEditable;
		}
		public function get isEditable():Boolean
		{
			return _isEditable;
		}
        
		// Helper function
		public function getLabelFor(file:Object):String
		{
			var tmpFL: FileLocation = (file is FileLocation) ? file as FileLocation : new FileLocation(file.nativePath);
			var lbl:String = FileLocation(provider.folderLocation).fileBridge.getRelativePath(tmpFL, true);
			if (!lbl)
			{
				if (relativeRoot) lbl = relativeRoot.fileBridge.getRelativePath(tmpFL);
				if (relativeRoot && relativeRoot.fileBridge.nativePath == tmpFL.fileBridge.nativePath) lbl = "/";
				if (!lbl) lbl = tmpFL.fileBridge.nativePath;
				
				if (tmpFL.fileBridge.isDirectory
					&& lbl.charAt(lbl.length-1) != "/")
				{
					lbl += "/";	
				}
			}
			
			return lbl;
		}        

	}
}