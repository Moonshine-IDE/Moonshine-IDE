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
    
    import actionScripts.plugin.settings.renderers.BooleanRenderer;

    public class BooleanSetting extends AbstractSetting
    {
		private var immediateSave:Boolean;
		
        public function BooleanSetting(provider:Object, name:String, label:String, immediateSave:Boolean=false)
        {
            super();
            this.provider = provider;
            this.name = name;
            this.label = label;
			this.immediateSave = immediateSave;
            defaultValue = stringValue;
        }


        override protected function setPendingSetting(v:*):void
        {
            super.setPendingSetting(v is String ? v == "true" ? true : false : v);
        }

        [Bindable]
        public function get value():Boolean
        {
            var val:String = getSetting();
            return val == "true" ? true : false;
        }

        public function set value(v:Boolean):void
        {
            setPendingSetting(v);
			if (immediateSave) commitChanges();
        }

        override public function get renderer():IVisualElement
        {
            var rdr:BooleanRenderer = new BooleanRenderer();
            rdr.setting = this;

            return rdr;
        }

    }
}