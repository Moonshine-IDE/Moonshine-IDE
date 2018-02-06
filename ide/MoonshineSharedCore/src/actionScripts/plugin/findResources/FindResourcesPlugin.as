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
package actionScripts.plugin.findResources
{
	import actionScripts.plugin.PluginBase;
	import components.popup.FindResourcesPopup;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

    import mx.collections.ArrayCollection;

    import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	public class FindResourcesPlugin extends PluginBase
	{
		public static const EVENT_FIND_RESOURCES: String = "findResources";
		private var resourceSearchView:FindResourcesPopup;

		[Bindable]
		public static var previouslySelectedPatterns:ArrayCollection;

		public function FindResourcesPlugin()
		{
			super();
		}
		
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Find Resources"; }
		override public function get name():String { return "Find Resources"; }
		
		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(EVENT_FIND_RESOURCES, findResourcesHandler);
		}

		protected function findResourcesHandler(event:Event):void
		{
			if (!resourceSearchView)
			{
				resourceSearchView = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, FindResourcesPopup, true) as FindResourcesPopup;
				resourceSearchView.addEventListener(CloseEvent.CLOSE, findResourcesViewCloseHandler);

				PopUpManager.centerPopUp(resourceSearchView);
			}
		}

		protected function findResourcesViewCloseHandler(event:CloseEvent):void
		{
			if (resourceSearchView.filesExtensionFilterView.hasSelectedExtensions())
			{
                previouslySelectedPatterns = resourceSearchView.filesExtensionFilterView.patterns;
			}
			else
			{
				previouslySelectedPatterns = null;
			}

			resourceSearchView.removeEventListener(CloseEvent.CLOSE, findResourcesViewCloseHandler);
			resourceSearchView = null;
		}
	}
}
