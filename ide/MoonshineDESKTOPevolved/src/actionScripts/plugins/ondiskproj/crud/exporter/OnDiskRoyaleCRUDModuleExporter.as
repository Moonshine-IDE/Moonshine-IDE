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
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.impls.IDominoFormBuilderLibraryBridgeImp;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.GlobalClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ProxyClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.VOClassGenerator;

	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.templating.TemplatingHelper;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.AddEditPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.DashboardPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ListingPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.MainContentPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.ResourceVO;

	import utils.MoonshineBridgeUtils;

	import view.dominoFormBuilder.utils.FormBuilderCodeUtils;
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class OnDiskRoyaleCRUDModuleExporter
	{
		private static const TEMPLATE_MODULE_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleTabularCRUD/module");
		
		[Bindable] protected var classReferenceSettings:RoyaleCRUDClassReferenceSettings = new RoyaleCRUDClassReferenceSettings();
		
		protected var targetPath:FileLocation;
		protected var project:ProjectVO;
		protected var formObjects:Vector.<DominoFormVO>;
		protected var waitingCount:int;

		protected var completionCount:int;
		protected var onCompleteHandler:Function;
		
		public function OnDiskRoyaleCRUDModuleExporter(targetPath:FileLocation, project:ProjectVO, onComplete:Function)
		{
			waitingCount = 0;
			completionCount = 0;

			this.targetPath = targetPath;
			this.project = project;
			this.onCompleteHandler = onComplete;

			if (!MoonshineBridgeUtils.moonshineBridgeFormBuilderInterface)
			{
				MoonshineBridgeUtils.moonshineBridgeFormBuilderInterface = new IDominoFormBuilderLibraryBridgeImp();
			}

			parseModules();
		}
		
		protected function parseModules():void
		{
			var tmpFormObject:DominoFormVO;
			
			// get all available dfb files
			var resources:ArrayCollection = new ArrayCollection();
			UtilsCore.parseFilesList(resources, null, IDEModel.getInstance().activeProject, ["dfb"], false, onFilesParseCompletes);

			/*
			 * @local
			 */
			function onFilesParseCompletes():void
			{
				// parse to dfb files to form-object
				// no matter opened or non-opened
				formObjects = new Vector.<DominoFormVO>();
				if (resources.length == 0)
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(
							new ConsoleOutputEvent(
									ConsoleOutputEvent.CONSOLE_PRINT,
									"No .dfb module found in: "+ IDEModel.getInstance().activeProject.name +". Process terminates.",
									false, false,
									ConsoleOutputEvent.TYPE_ERROR
							)
					);
					onCompleteHandler = null;
					return;
				}

				for each (var resource:Object in resources)
				{
					tmpFormObject = new DominoFormVO();
					FormBuilderCodeUtils.loadFromFile(new File(resource.resourcePath), tmpFormObject);

					// form with no fields doesn't make sense
					// to being generate in the royale application
					if (tmpFormObject.fields && tmpFormObject.fields.length > 0)
					{
						formObjects.push(tmpFormObject);
					}
				}

				// starts generation
				copyModuleTemplates();
			}
		}
		
		protected function copyModuleTemplates():void
		{
			// module specific generation
			for each (var form:DominoFormVO in formObjects)
			{
				copyTemplates(form);
			}
			
			// ** IMPORTANT **
			// update files-list once ALL file
			// creation are complete
			// run once to save process
			project.projectFolder.updateChildren();

			// class-files gneration
			generateModuleClasses();
		}
		
		protected function copyTemplates(form:DominoFormVO):void
		{
			var moduleName:String = form.formName;

			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["$moduleName"] = moduleName;
			th.templatingData["$packagePath"] = "views.modules."+ moduleName +"."+ moduleName +"Services";
			
			th.projectTemplate(TEMPLATE_MODULE_PATH, targetPath);
		}
		
		protected function generateModuleClasses():void
		{
			for each (var form:DominoFormVO in formObjects)
			{
				waitingCount += 4;
				new VOClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new ProxyClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new ListingPageGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new AddEditPageGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
			}
		}
		
		protected function generateProjectClasses():void
		{
			new MainContentPageGenerator(this.project, formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
			new DashboardPageGenerator(this.project, formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
			new GlobalClassGenerator(this.project, classReferenceSettings, onProjectFilesGenerationCompletes);
		}

		protected function onModuleGenerationCompletes(origin:RoyalePageGeneratorBase):void
		{
			completionCount++;

			if (waitingCount == completionCount)
			{
				waitingCount = 3;
				completionCount = 0;

				// project specific generation
				generateProjectClasses();
			}
		}

		protected function onProjectFilesGenerationCompletes(origin:RoyalePageGeneratorBase):void
		{
			completionCount++;

			if (waitingCount == completionCount)
			{
				onCompleteHandler();
				onCompleteHandler = null;
			}
		}
	}
}