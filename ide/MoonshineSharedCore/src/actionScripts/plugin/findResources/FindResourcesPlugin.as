////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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
			projectsPaths = [];
			for each (var project:ProjectVO in model.projects)
			{
				projectsPaths.push({path:project.folderLocation.fileBridge.nativePath, name:project.name});
			}
			
			readFilePaths();
		}
		
		private function readFilePaths():void
		{
			if (projectsPaths.length == 0 || !findResourcesView) 
				return;
			
			var tmpObj:Object = projectsPaths.shift();
			var tmpFSP:FileSystemParser = new FileSystemParser();
			tmpFSP.addEventListener(FileSystemParser.EVENT_PARSE_COMPLETED, onParseCompleted, false, 0, true);
			tmpFSP.parseFilesPaths(tmpObj.path, tmpObj.name);
		}
		
		protected function onParseCompleted(event:Event):void
		{
			event.currentTarget.removeEventListener(FileSystemParser.EVENT_PARSE_COMPLETED, onParseCompleted);
			
			// don't update anything if the window closed
			if (!findResourcesView) return;
			
			parsedStrings += (ConstantsCoreVO.IS_MACOS ? "\n" : "\r\n") + (event.currentTarget as FileSystemParser).resultsStringFormat;
			updatesFilesInUI(event.currentTarget as FileSystemParser);
			
			if (projectsPaths.length == 0)
			{
				findResourcesView.isBusyState = false;
			}
			else
			{
				readFilePaths();
			}
		}
		
		private function updatesFilesInUI(parser:FileSystemParser):void
		{
			// don't update anything if the window closed
			if (!findResourcesView) return;
			
			var resources:ArrayCollection = findResourcesView.resources;
			var parsedFilesList:Array = parser.resultsArrayFormat;
			var fileCount:int = parsedFilesList.length;
			var separator:String = model.fileCore.separator;
			var projectPath:String = parser.projectPath;
			var projectName:String = parser.fileName;
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
					resources.add({name:tmpNameLabel, extension: tmpNameExtension, labelPath:i.replace(projectPath, projectName), 
						resourcePath: i});
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
