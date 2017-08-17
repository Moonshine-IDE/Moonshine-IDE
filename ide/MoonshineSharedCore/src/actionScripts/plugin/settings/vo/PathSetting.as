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
package actionScripts.plugin.settings.vo
{
	import mx.core.IVisualElement;
	
	import spark.filters.BlurFilter;
	
	import actionScripts.plugin.settings.renderers.PathRenderer;
	
	[Event(name="PATH_SELECTED", type="flash.events.Event")]
	public class PathSetting extends AbstractSetting
	{
		public static const PATH_SELECTED:String = "PATH_SELECTED";
		
		[Bindable]
		public var directory:Boolean;
		
		private var isSDKPath:Boolean;
		private var isDropDown:Boolean
		private var rdr:PathRenderer;
		private var myBlurFilter:BlurFilter = new BlurFilter();
		
		private var _isEditable:Boolean;
		
		public function PathSetting(provider:Object, name:String, label:String, directory:Boolean, path:String=null, isSDKPath:Boolean=false, isDropDown:Boolean = false)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.directory = directory;
			this.isSDKPath = isSDKPath;
			this.isDropDown = isDropDown;
			defaultValue = stringValue = (path != null) ? path : stringValue ? stringValue :"";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new PathRenderer();
			rdr.setting = this;
			rdr.isSDKPath = isSDKPath;
			rdr.isDropDown = isDropDown;
			return rdr;
		}
		
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.mouseChildren = _isEditable;
				//rdr.filters = _isEditable ? [] : [myBlurFilter];
			}
		}
		public function get isEditable():Boolean
		{
			return _isEditable;
		}
	}
}