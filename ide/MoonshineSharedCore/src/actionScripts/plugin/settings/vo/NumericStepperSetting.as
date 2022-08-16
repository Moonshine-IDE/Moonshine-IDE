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
    import actionScripts.plugin.settings.renderers.NumericStepperRenderer;

    public class NumericStepperSetting extends AbstractSetting
    {
        public function NumericStepperSetting(provider:Object, name:String, label:String, minimum:Number = 0.0, maximum:Number = 100.0, stepSize:Number = 1.0, snapInterval:Number = 1.0)
        {
            super();
            this.provider = provider;
            this.name = name;
            this.label = label;
			this.minimum = minimum;
			this.maximum = maximum;
			this.stepSize = stepSize;
			this.snapInterval = snapInterval;
            defaultValue = stringValue;
        }

        [Bindable]
		public var minimum:Number;

        [Bindable]
		public var maximum:Number;

        [Bindable]
		public var stepSize:Number;

        [Bindable]
		public var snapInterval:Number;
        
        public function get value():Number
        {
            return parseFloat(getSetting());
        }

        public function set value(v:Number):void
        {
            setPendingSetting(v);
        }

        override public function get renderer():IVisualElement
        {
            var rdr:NumericStepperRenderer = new NumericStepperRenderer();
            rdr.setting = this;

            return rdr;
        }

    }
}