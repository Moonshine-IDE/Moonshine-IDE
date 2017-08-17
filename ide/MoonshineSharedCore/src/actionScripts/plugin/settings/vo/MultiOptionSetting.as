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
	
	import actionScripts.plugin.settings.renderers.MultiOptionRenderer;

	public class MultiOptionSetting extends StringSetting
	{
		private var _options:Vector.<NameValuePair>;
		private var _value:Object;
		private var _isEditable:Boolean;
		
		private var rdr:MultiOptionRenderer;
		private var myBlurFilter:BlurFilter = new BlurFilter();
		
		public function MultiOptionSetting(provider:Object, name:String, label:String,options:Vector.<NameValuePair>)
		{
			super(provider,name,label);
			_options = options;
			value = defaultValue = stringValue;
			
		}
		
		public function get value():Object{
			return getSetting();
		}
		public function set value(v:Object):void{
			setPendingSetting(v);			
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new MultiOptionRenderer();
			rdr.options = _options;
			rdr.setting = this;			
			return rdr;
		}
		
		override public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.mouseChildren = _isEditable;
				//rdr.filters = _isEditable ? [] : [myBlurFilter];
			}
		}
		override public function get isEditable():Boolean
		{
			return _isEditable;
		}
	}
}