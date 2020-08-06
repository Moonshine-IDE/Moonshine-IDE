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
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import feathers.data.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import moonshine.plugin.findResources.view.FindResourcesView;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.utils.UtilsCore;
	import mx.collections.ArrayList;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.valueObjects.ResourceVO;

	public class FindResourcesPlugin extends PluginBase
	{
		public static const EVENT_FIND_RESOURCES: String = "findResources";

		private var findResourcesView:FindResourcesView;
		private var findResourcesViewWrapper:FeathersUIWrapper;

		[Bindable]
		public static var previouslySelectedPatterns:ArrayCollection;

		public function FindResourcesPlugin()
		{
			super();
		}
		
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Find Resources"; }
		override public function get name():String { return "Find Resources"; }
		
		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(EVENT_FIND_RESOURCES, findResourcesHandler);
		}

		protected function findResourcesHandler(event:Event):void
		{
			if (!findResourcesView)
			{
				findResourcesView = new FindResourcesView();
				findResourcesView.addEventListener(Event.CLOSE, findResourcesView_closeHandler);
				findResourcesViewWrapper = new FeathersUIWrapper(findResourcesView);
				PopUpManager.addPopUp(findResourcesViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
				PopUpManager.centerPopUp(findResourcesViewWrapper);
				findResourcesViewWrapper.assignFocus("top");
				findResourcesViewWrapper.stage.addEventListener(Event.RESIZE, findResourcesView_stage_resizeHandler, false, 0, true);
			}

			if(!previouslySelectedPatterns)
			{
				previouslySelectedPatterns = new ArrayCollection();
                for each (var extension:String in ConstantsCoreVO.READABLE_FILES)
                {
                    previouslySelectedPatterns.add({label: extension, isSelected: false});
                }
			}
			findResourcesView.patterns = previouslySelectedPatterns;

			var parsedFilesList:ArrayList = new ArrayList();
			UtilsCore.parseFilesList(parsedFilesList);

			var resources:ArrayCollection = findResourcesView.resources;
			resources.removeAll();

			var fileCount:int = parsedFilesList.length;
			for(var i:int = 0; i < fileCount; i++)
			{
				var resource:ResourceVO = ResourceVO(parsedFilesList.getItemAt(i));
				resources.add(resource);
			}
		}

		protected function findResourcesView_closeHandler(event:Event):void
		{
			var selectedResource:ResourceVO = findResourcesView.selectedResource;
			if(selectedResource)
			{
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [selectedResource.sourceWrapper.file], -1, [selectedResource.sourceWrapper]));
			}

			previouslySelectedPatterns = findResourcesView.patterns;
			findResourcesViewWrapper.stage.removeEventListener(Event.RESIZE, findResourcesView_stage_resizeHandler);
			PopUpManager.removePopUp(findResourcesViewWrapper);
			findResourcesView.removeEventListener(Event.CLOSE, findResourcesView_closeHandler);
			findResourcesView = null;
			findResourcesViewWrapper = null;
		}

		protected function findResourcesView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(findResourcesViewWrapper);
		}
	}
}
