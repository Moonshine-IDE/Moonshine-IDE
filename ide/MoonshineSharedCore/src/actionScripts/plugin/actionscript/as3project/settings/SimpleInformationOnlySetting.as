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
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.plugin.settings.vo.AbstractSetting;

	public class SimpleInformationOnlySetting extends AbstractSetting
	{
		private var rdr:IVisualElement;

		public function SimpleInformationOnlySetting()
		{
			super();
			this.provider = {};
			this.name = "";
			defaultValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			return rdr;
		}
		
		public function set renderer(value:IVisualElement):void
		{
			rdr = value;
		}
    }
}