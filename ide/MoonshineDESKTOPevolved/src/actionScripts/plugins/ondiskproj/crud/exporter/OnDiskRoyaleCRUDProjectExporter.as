////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.plugins.ondiskproj.crud.exporter
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugins.as3project.CreateProject;
	import actionScripts.plugin.actionscript.as3project.importer.FlashDevelopImporter;
	import actionScripts.valueObjects.ProjectVO;
	
	public class OnDiskRoyaleCRUDProjectExporter extends CreateProject
	{
		private static const TEMPLATE_PROJECT_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleTabularCRUD/project");
		
		private var targetDirectory:File;
		
		/**
		 * CONSTRUCTOR
		 */
		public function OnDiskRoyaleCRUDProjectExporter(event:NewProjectEvent)
		{
			super(event);
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------
		
		public function browseToExport():void
		{
			model.fileCore.browseForDirectory("Select Directory to Export", onDirectorySelected, onDirectorySelectionCancelled);
		}
		
		//--------------------------------------------------------------------------
		//
		//  OVERRIDES
		//
		//--------------------------------------------------------------------------
		
		override protected function getProjectWithTemplate(pvo:Object, exportProject:AS3ProjectVO=null):Object
		{
			templateLookup[pvo] = TEMPLATE_PROJECT_PATH;
			return pvo;
		}
		
		override protected function setProjectType(templateName:String):void
		{
			isFlexJSRoyalProject = true;
		}
		
		override protected function onCreateProjectSave(event:Event):void
		{
			var projectName:String = model.activeProject.name +"RoyaleApplication";
			
			dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Saving project at: "+ targetDirectory.resolvePath(projectName).nativePath)
			);
			
			project = FlashDevelopImporter.parse(TEMPLATE_PROJECT_PATH.resolvePath("$Settings.as3proj.template"), null, null, false);
			(project as AS3ProjectVO).projectName = projectName;
			(project as AS3ProjectVO).folderLocation = new FileLocation(targetDirectory.nativePath);
			
			project = createFileSystemBeforeSave(project);
			if (project)
			{
				generatePageContents();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		protected function onDirectorySelected(path:File):void
		{
			targetDirectory = path;
			onCreateProjectSave(null);
		}
		
		protected function onDirectorySelectionCancelled():void
		{
			project = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function generatePageContents():void
		{
			new OnDiskRoyaleCRUDModuleExporter(
				(project as ProjectVO).sourceFolder.resolvePath("views/modules"),
				project as ProjectVO,
					onModulesExported
			);
		}

		private function onModulesExported():void
		{
			// success message
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(
							ConsoleOutputEvent.CONSOLE_PRINT,
							"Project saved at: "+ targetDirectory.resolvePath((project as ProjectVO).name).nativePath,
							false, false,
							ConsoleOutputEvent.TYPE_SUCCESS
					)
			);
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Opening project in Moonshine..")
			);

			// open project in Moonshine
			openProjectInMoonshine();
		}
		
		private function openProjectInMoonshine():void
		{
			dispatcher.dispatchEvent(
				new ProjectEvent(ProjectEvent.ADD_PROJECT, project)
			);
			
			dispatcher.dispatchEvent( 
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, [project.targets[0]], -1, [project.projectFolder])
			);
		}
	}
}