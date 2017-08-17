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
	
	import actionScripts.plugin.settings.renderers.StaticLabelRenderer;
	
	public class StaticLabelSetting extends AbstractSetting
	{
		[Bindable] public var fontSize:int;
		
		public var fakeSetting:String = "";
		
		public function StaticLabelSetting(label:String, fontSize:int=24)
		{
			super();
			this.name = "fakeSetting";
			this.label = label;
			this.fontSize = fontSize;
			
		}
		
		override public function get renderer():IVisualElement
		{
			var rdr:StaticLabelRenderer = new StaticLabelRenderer();
			rdr.setting = this;
			return rdr;
		}
		
		
		// Do nothing
        override protected function getSetting():*
        {
        	return "";
        }

        override protected function hasProperty(... names:Array):Boolean
        {
            return false;
        }
        
        override protected function setPendingSetting(v:*):void
        {        
        }

        override public function valueChanged():Boolean
        {
            return false;
        }
		
		override public function commitChanges():void
		{
		}
		
	}
}