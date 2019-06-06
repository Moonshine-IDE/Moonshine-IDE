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
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.PathRenderer;
	
	[Event(name="pathSelected", type="flash.events.Event")]
	public class PathSetting extends AbstractSetting
	{
		[Bindable] public var dropdownListItems:ArrayCollection;
		[Bindable] public var directory:Boolean;
		public var fileFilters:Array;
		
		private var isSDKPath:Boolean;
		private var isDropDown:Boolean;
		private var rdr:PathRenderer;

		private var _editable:Boolean = true;
		private var _path:String;
		private var _defaultPath:String;

		public function PathSetting(provider:Object, name:String, label:String, directory:Boolean,
									path:String=null, isSDKPath:Boolean=false, isDropDown:Boolean = false, defaultPath:String = null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.directory = directory;
			this.isSDKPath = isSDKPath;
			this.isDropDown = isDropDown;

			_path = path;
			_defaultPath = defaultPath;

			defaultValue = stringValue = (path != null) ? path : stringValue ? stringValue :"";
		}

		public function get path():String
		{
			return _path;
		}

		public function get defaultPath():String
		{
			return _defaultPath;
		}

		public function setMessage(value:String, type:String=MESSAGE_NORMAL):void
		{
			if (rdr)
			{
				rdr.setMessage(value, type);
            }
			else
			{
				message = value;
				messageType = type;
			}
		}
		
		override public function get renderer():IVisualElement
		{
			if (!rdr)
			{
				rdr = new PathRenderer();
				rdr.setting = this;
				rdr.isSDKPath = isSDKPath;
				rdr.isDropDown = isDropDown;
				rdr.enabled = _editable;
				rdr.setMessage(message, messageType);
			}

			return rdr;
		}
		
		public function set editable(value:Boolean):void
		{
			_editable = value;
			if (rdr) 
			{
				rdr.enabled = _editable;
			}
		}
		public function get editable():Boolean
		{
			return _editable;
		}
	}
}