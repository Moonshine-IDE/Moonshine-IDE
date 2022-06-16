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
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ProxyClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.VOClassGenerator;
	import actionScripts.utils.FileUtils;

	import avmplus.getQualifiedClassName;

	import flash.events.Event;

	import flash.filesystem.File;
	import flash.utils.Dictionary;

	import haxe.ds.ObjectMap;
	import haxe.ds.StringMap;

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
	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class CRUDJavaAgentsModuleExporter extends ConsoleOutputter
	{
		private static var TEMPLATE_MODULE_PATH:File;
		private static var TEMPLATE_ELEMENTS_PATH:File;
		
		[Bindable] protected var classReferenceSettings:RoyaleCRUDClassReferenceSettings = new RoyaleCRUDClassReferenceSettings();
		
		protected var targetPath:File;
		protected var project:ProjectVO;
		protected var formObjects:Vector.<DominoFormVO>;

		private var completionCount:int;
		private var waitingCount:int;
		private var onCompleteHandler:Function;
		
		public function CRUDJavaAgentsModuleExporter(originPath:File, targetPath:File, project:ProjectVO, onComplete:Function)
		{
			super();

			waitingCount = 0;
			completionCount = 0;

			TEMPLATE_MODULE_PATH = originPath.resolvePath("project/src/main/java");
			TEMPLATE_ELEMENTS_PATH = originPath.resolvePath("elements");

			this.targetPath = targetPath.resolvePath("src/main/java");
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

			// all done?
			if (onCompleteHandler != null)
			{
				onCompleteHandler();
				onCompleteHandler = null;
			}
		}
		
		protected function copyTemplates(form:DominoFormVO):void
		{
			var moduleName:String = form.formName;

			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["%eachform%"] = th.templatingData["%form%"] = form.formName.replace(/[^0-9a-zA-Z_]/, '');
			th.templatingData["%formRaw%"] = form.formName;
			th.templatingData["%view%"] = form.viewName;
			generateModuleFilesContent(form, th);

			th.projectTemplate(new FileLocation(TEMPLATE_MODULE_PATH.nativePath), new FileLocation(targetPath.nativePath));
		}
		
		protected function generateModuleFilesContent(form:DominoFormVO, th:TemplatingHelper):void
		{
			var allTemplates:File = TEMPLATE_ELEMENTS_PATH.resolvePath('all');
			var keyTemplates:File = TEMPLATE_ELEMENTS_PATH.resolvePath('key');
			var editableTemplates:File = TEMPLATE_ELEMENTS_PATH.resolvePath('editable');
			//var requiredTemplates = TEMPLATE_ELEMENTS_PATH.resolvePath('required');

			generateElementsParametersCategory(allTemplates, form, th, allTemplates.name);
			generateElementsParametersCategory(keyTemplates, form, th, keyTemplates.name);
			generateElementsParametersCategory(editableTemplates, form, th, editableTemplates.name);
			//generateElementsParametersCategory(requiredTemplates, form, th, requiredTemplates.name);
		}

		protected function generateElementsParametersCategory(elementsDirectory:File, form:DominoFormVO, th:TemplatingHelper, type:String):void
		{
			var elementsTemplates:Array = elementsDirectory.getDirectoryListing();
			for each (var template:File in elementsTemplates)
			{
				var key:String = getElementsParameterKey(TEMPLATE_ELEMENTS_PATH, template);
				var fileContent:String = FileUtils.readFromFile(template) as String;
				var replaceToken:String = "";
				for each (var formItem:DominoFormFieldVO in form.fields)
				{
					if (validateElementWiseFieldConditions(formItem, type))
					{
						var tmpFieldDictionary:Dictionary = new Dictionary();
						tmpFieldDictionary['name'] = formItem.name;
						tmpFieldDictionary['label'] = formItem.label;
						tmpFieldDictionary['description'] = formItem.description;
						tmpFieldDictionary['type'] = formItem.type;
						tmpFieldDictionary['typeupper'] = formItem.type.toUpperCase();
						tmpFieldDictionary['multivalue'] = formItem.isMultiValue;

						replaceToken += applyParameters(fileContent, tmpFieldDictionary);
					}
				}

				th.templatingData["%"+ key +"%"] = replaceToken;
			}
		}

		protected function validateElementWiseFieldConditions(field:DominoFormFieldVO, type:String):Boolean
		{
			switch (type)
			{
				case "all":
					return true;
				case "key":
					if (field.isIncludeInView && field.sortOption.label != 'No sorting')
						return true;
					break;
				case "editable":
					if (field.editable == "Editable")
						return true;
					break;
				case "required":
					return false; // we don't have a DominoFormFieldVO.isRequired yet
			}

			return false;
		}

		protected function getElementsParameterKey(elementsDir:File, template:File):String
		{
			// since we know this is a subdirectory, we can simply cut off the elementsPath prefix
			var relativePath:String = template.nativePath.substring(elementsDir.nativePath.length + 1);  // +1 for the file separator

			var key:String = relativePath.replace('\\\\', '/');  // normalize windows paths
			key = key.replace('.template', '')  // use replaceAll for regex
			return key
		}

		protected static function applyParameters(original:String, parameters:Dictionary):String
		{
			for (var key:String in parameters)
			{
				original = original.replace(new RegExp("%"+ key +"%", "gmi"), parameters[key]);
			}

			return original;
		}
	}
}