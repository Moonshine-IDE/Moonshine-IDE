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
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.utils.FileSystemParser;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import feathers.data.ArrayCollection;
	
	import moonshine.plugin.findResources.view.FindResourcesView;

	public class FindResourcesPlugin extends PluginBase
	{
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Find Resources"; }
		override public function get name():String { return "Find Resources"; }
		
		[Bindable] public static var previouslySelectedPatterns:ArrayCollection;
		public static const EVENT_FIND_RESOURCES: String = "findResources";

		private var findResourcesView:FindResourcesView;
		private var findResourcesViewWrapper:FeathersUIWrapper;
		private var projectsPaths:Array = [];
		private var parsedStrings:String = "";

		public function FindResourcesPlugin()
		{
			super();
		}
		
		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_FIND_RESOURCES, findResourcesHandler, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(EVENT_FIND_RESOURCES, findResourcesHandler);
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
			parsedStrings = "";
			for each (var project:ProjectVO in model.projects)
			{
				projectsPaths.push({path:project.folderLocation.fileBridge.nativePath, name:project.name});
			}
			
			readFilePaths();
		}
		
		private function readFilePaths():void
		{
			if (projectsPaths.length == 0) return;
			
			var tmpObj:Object = projectsPaths.shift();
			var tmpFSP:FileSystemParser = new FileSystemParser();
			tmpFSP.addEventListener(FileSystemParser.EVENT_PARSE_COMPLETED, onParseCompleted, false, 0, true);
			tmpFSP.parseFilesPaths(tmpObj.path, tmpObj.name, ConstantsCoreVO.READABLE_FILES);
		}
		
		
		protected function onParseCompleted(event:Event):void
		{
			event.currentTarget.removeEventListener(FileSystemParser.EVENT_PARSE_COMPLETED, onParseCompleted);
			
			parsedStrings += (ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n") + (event.currentTarget as FileSystemParser).resultsStringFormat;
			if (projectsPaths.length == 0)
			{
				prepareDisplayOnUI();
			}
			else
			{
				readFilePaths();
			}
		}
		
		private function prepareDisplayOnUI():void
		{
			findResourcesView.isBusyState = false;
			
			var parsedFilesList:Array = parsedStrings.split(ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n");
			var resources:ArrayCollection = findResourcesView.resources;
			
			var fileCount:int = parsedFilesList.length;
			var separator:String = model.fileCore.separator;
			var tmpNameLabel:String;
			var tmpNameExtension:String;
			for each (var i:String in parsedFilesList)
			{
				//var resource:ResourceVO = ResourceVO(parsedFilesList.getItemAt(i));
				//resources.add(resource);
				if (i != "")
				{
					tmpNameLabel = i.substr(i.lastIndexOf(separator)+1, i.length);
					tmpNameExtension = tmpNameLabel.substr(tmpNameLabel.lastIndexOf(".")+1, tmpNameLabel.length);
					resources.add({name:tmpNameLabel, extension: tmpNameExtension, resourcePath: i});
				}
			}
		}

		protected function findResourcesView_closeHandler(event:Event):void
		{
			var selectedResource:Object = findResourcesView.selectedResource;
			if(selectedResource)
			{
				dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [new FileLocation(selectedResource.resourcePath)]));
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
