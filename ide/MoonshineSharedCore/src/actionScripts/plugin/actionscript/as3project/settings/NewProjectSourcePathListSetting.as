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
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	
	public class NewProjectSourcePathListSetting extends AbstractSetting
	{
		protected var copiedPaths:ArrayCollection;
		
		public var relativeRoot:FileLocation;
		
		private var rdr:NewProjectSourcePathListSettingRenderer;
		
		private var _project:AS3ProjectVO;
		private var _visible:Boolean = true;
		
		public function NewProjectSourcePathListSetting(provider:Object, name:String, label:String, 
										relativeRoot:FileLocation=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.relativeRoot = relativeRoot;
			defaultValue = "";
		}
		
		override public function set stringValue(v:String):void 
		{
			if (v != "")
			{
				var toRet:Vector.<FileLocation> = new Vector.<FileLocation>();
				var values:Array = v.split(",");
				for each (var v:String in values)
				{
					toRet.push( new FileLocation(v) );
				}
			}
			setPendingSetting(toRet);
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new NewProjectSourcePathListSettingRenderer();
			rdr.setting = this;
			rdr.enabled = _visible; 
			return rdr;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			if (rdr) rdr.enabled = _visible;
		}
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set project(value:AS3ProjectVO):void
		{
			_project = value;
			if (rdr) rdr.resetAllProjectPaths();
		}
		public function get project():AS3ProjectVO
		{
			return _project;
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