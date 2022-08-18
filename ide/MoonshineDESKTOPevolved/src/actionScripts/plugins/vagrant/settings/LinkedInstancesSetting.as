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
package actionScripts.plugins.vagrant.settings
{
	import actionScripts.plugins.vagrant.settings.renderer.LinkedInstancesRenderer;

	import mx.collections.ArrayCollection;

	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.vo.AbstractSetting;

	public class LinkedInstancesSetting extends AbstractSetting
	{
		protected var rdr:LinkedInstancesRenderer = new LinkedInstancesRenderer();

		[Bindable] public var vagrantInstances:ArrayCollection;
		public var fakeSetting:String = "";
		
		public function LinkedInstancesSetting(instances:ArrayCollection)
		{
			super();
			this.vagrantInstances = instances;
			this.provider = this;
			this.name = 'fakeSetting';
			defaultValue = stringValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr.setting = this;
			return rdr;
		}
	}
}