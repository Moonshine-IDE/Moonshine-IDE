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
	
	import actionScripts.plugin.settings.renderers.FileNameRenderer;
	
	public class FileNameSetting extends AbstractSetting
	{
		public static const VALUE_UPDATED:String = "valueUpdated";
		
		private var rdr:FileNameRenderer;
    	
        private var _extension:String;
        [Bindable]
        public function get extension():String
        {
            return _extension;
        }
        public function set extension(v:String):void
        {
            _extension = v;
        }

		private var _isEditable:Boolean = true;
		
		public function FileNameSetting(provider:Object, name:String, label:String, extension:String)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.extension = extension;
			defaultValue = stringValue;
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new FileNameRenderer();
			rdr.text.restrict = "A-Za-z0-9\\-_";

			rdr.setting = this;
			rdr.enabled = isEditable;
			rdr.setMessage(message, messageType);
			return rdr;
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
		
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.enabled = _isEditable;
			}
		}

		public function get isEditable():Boolean
		{
			return _isEditable;
		}
	}
}