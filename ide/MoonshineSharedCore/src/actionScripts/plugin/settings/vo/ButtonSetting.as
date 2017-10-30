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
	
	import actionScripts.plugin.settings.renderers.ButtonRenderer;
	
	public class ButtonSetting extends AbstractSetting
	{
		public static const STYLE_NORMAL:String = "STYLE_NORMAL";
		public static const STYLE_DARK:String = "STYLE_DARK";
		public static const STYLE_DANGER:String = "STYLE_DANGER";
		public static const STYLE_POSITIVE:String = "STYLE_POSITIVE";
		
		public var style:String;
		public var handlerName:String;
		
		private var rdr:ButtonRenderer;
		private var _title:String;
		
		public function ButtonSetting(provider:Object, name:String, label:String, handlerName:String,
									  title:String = null, style:String=STYLE_NORMAL)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.title = title;
			this.style = style;
			
			// instead of using any Function or Event (which may left footprint) 
			// use a setter method to notify the owner 
			this.handlerName = handlerName;
			
			defaultValue = stringValue;
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new ButtonRenderer();
			rdr.setting = this;
			rdr.enabled = _isEnabled;
			return rdr;
		}

		[Bindable]
        public function get title():String
        {
            return _title;
        }

        public function set title(value:String):void
        {
            _title = value;
        }

		private var _isEnabled:Boolean = true;
		public function set isEnabled(value:Boolean):void
		{
			_isEnabled = value;
			if (rdr) rdr.enabled = _isEnabled;
		}
		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}
    }
}