
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
package actionScripts.plugin.splashscreen
{
	import components.views.other.SamplesScreen;
	import flash.events.Event;
    import actionScripts.plugin.PluginBase;
    import actionScripts.ui.IContentWindow;

	import mx.collections.ArrayList;

	public class SamplesScreenPlugin extends PluginBase
	{
		override public function get name():String			{ return "Samples Screen Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Shows all possibility to create new projects"; }

		public static const EVENT_SHOW_SAMPLES_SCREEN:String = "eventShowSamplesScreen";

		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(EVENT_SHOW_SAMPLES_SCREEN, samplesScreenHandler);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(EVENT_SHOW_SAMPLES_SCREEN, samplesScreenHandler);
		}

		protected function samplesScreenHandler(event:Event):void
		{
			showSamplesScreen();
		}

        private function showSamplesScreen():void
        {
            for each (var tab:IContentWindow in model.editors)
            {
                if (tab is SamplesScreen) return;
            }

			var samplesScreen:SamplesScreen = new SamplesScreen();
			samplesScreen.samplesList = new ArrayList([]);

            model.editors.addItem(samplesScreen);
        }
    }
}