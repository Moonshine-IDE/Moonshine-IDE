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
	
	import actionScripts.interfaces.IDisposable;
	import actionScripts.plugin.settings.renderers.LinkOnlySettingsRenderer;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	public class LinkOnlySetting extends AbstractSetting implements IDisposable
	{
		public static const EVENT_MODIFY:String = "modify";
		public static const EVENT_REMOVE:String = "delete";
		
		protected var rdr:LinkOnlySettingsRenderer = new LinkOnlySettingsRenderer();
		
		public var fakeSetting:String = "";
		
		private var nameEventPair:Vector.<LinkOnlySettingVO>;
		
		public function LinkOnlySetting(nameEventPair:Vector.<LinkOnlySettingVO>)
		{
			super();
			this.provider = this;
			this.name = 'fakeSetting';
			this.label = 'fakeLabel';
			this.nameEventPair = nameEventPair;
			defaultValue = stringValue = '';
		}
		
		override public function get renderer():IVisualElement
		{
			rdr.setting = this;
			rdr.nameEventPair = nameEventPair;
			return rdr;
		}
		
		public function dispose():void
		{
		}
	}
}