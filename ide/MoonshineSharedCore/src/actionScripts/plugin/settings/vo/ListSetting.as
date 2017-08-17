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
	import mx.collections.IList;
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.ListSettingRenderer;
	
	public class ListSetting extends AbstractSetting
	{
		public var labelField:String;
		public var dataProvider:IList;
		
		private var rdr:ListSettingRenderer;
		
		private var _isEditable:Boolean;
		
		public function ListSetting(provider:Object, name:String, label:String, dataProvider:IList, labelField:String=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.labelField = labelField;
			this.dataProvider = dataProvider;
			defaultValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new ListSettingRenderer();
			rdr.setting = this;
			return rdr;
		}
		
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.mouseChildren = _isEditable;
			}
		}
		public function get isEditable():Boolean
		{
			return _isEditable;
		}
	}
}