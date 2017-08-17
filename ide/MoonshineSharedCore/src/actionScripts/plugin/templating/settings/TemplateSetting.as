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
package actionScripts.plugin.templating.settings
{
	import mx.core.IVisualElement;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.plugin.templating.settings.renderer.TemplateRenderer;
	
	public class TemplateSetting extends AbstractSetting
	{
		protected var rdr:TemplateRenderer = new TemplateRenderer();
		
		public var originalTemplate:FileLocation;
		public var customTemplate:FileLocation;
		
		public var fakeSetting:String = "";
		
		public function TemplateSetting(originalTemplate:FileLocation , customTemplate:FileLocation, label:String)
		{
			super();
			this.provider = this;
			this.name = 'fakeSetting';
			this.label = label;
			this.customTemplate = customTemplate;
			this.originalTemplate = originalTemplate;
			defaultValue = stringValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr.setting = this;
			return rdr;
		}
		
	}
}