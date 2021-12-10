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
package actionScripts.plugins.ondiskproj.crud.exporter
{
	import actionScripts.impls.IDominoFormBuilderLibraryBridgeImp;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;

	import avmplus.getQualifiedClassName;

	import flash.events.Event;

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

		private var completionCount:int;
		private var waitingCount:int;
		private var onCompleteHandler:Function;
		
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
			UtilsCore.parseFilesList(resources, null,null, ["dfb"], false, onFilesParseCompletes);

			/*
			 * @local
			 */
			function onFilesParseCompletes():void
			{
				// parse to dfb files to form-object
				// no matter opened or non-opened
				formObjects = new Vector.<DominoFormVO>();
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
				waitingCount += 2;
				new ListingPageGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new AddEditPageGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
			}
		}
		
		protected function generateProjectClasses():void
		{
			new MainContentPageGenerator(this.project, formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
			new DashboardPageGenerator(this.project, formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
		}

		protected function onModuleGenerationCompletes(origin:RoyalePageGeneratorBase):void
		{
			completionCount++;

			if (waitingCount == completionCount)
			{
				waitingCount = 2;
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