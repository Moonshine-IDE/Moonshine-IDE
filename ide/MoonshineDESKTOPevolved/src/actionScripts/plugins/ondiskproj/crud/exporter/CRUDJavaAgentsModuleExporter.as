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
	import actionScripts.impls.IDominoFormBuilderLibraryBridgeImp;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.FileUtils;

	import flash.filesystem.File;
	import flash.utils.Dictionary;

	import haxe.ds.ObjectMap;

	import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.templating.TemplatingHelper;
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
		private static var TEMPLATE_ELEMENTS_PATH:File;
		
		[Bindable] protected var classReferenceSettings:RoyaleCRUDClassReferenceSettings = new RoyaleCRUDClassReferenceSettings();

		protected var moduleCopyTargets:ObjectMap = new ObjectMap();
		protected var project:ProjectVO;
		protected var formObjects:Vector.<DominoFormVO>;

		private var targetPath:File;
		private var completionCount:int;
		private var waitingCount:int;
		private var onCompleteHandler:Function;
		
		public function CRUDJavaAgentsModuleExporter(originPath:File, targetPath:File, project:ProjectVO, onComplete:Function)
		{
			super();

			waitingCount = 0;
			completionCount = 0;

			moduleCopyTargets.set(originPath.resolvePath("project/src/main/java"), targetPath.resolvePath("src/main/java"));
			moduleCopyTargets.set(originPath.resolvePath("project/src/main/generated"), targetPath.resolvePath("src/main/generated"));
			moduleCopyTargets.set(originPath.resolvePath("project/docs"), targetPath.resolvePath("docs"));
			moduleCopyTargets.set(originPath.resolvePath("project/agentProperties/agentbuild"), targetPath.resolvePath("agentProperties/agentbuild"));

			TEMPLATE_ELEMENTS_PATH = originPath.resolvePath("elements");

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
			UtilsCore.parseFilesList(resources, null, this.project, ["dfb"], false, onFilesParseCompletes);

			/*
			 * @local
			 */
			function onFilesParseCompletes():void
			{
				if (resources.length == 0)
				{
					error("No .dfb module found in: "+ project.name +". Process terminates.");
					onCompleteHandler = null;
					return;
				}

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
			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["%eachform%"] = th.templatingData["%form%"] = form.formName.replace(/[^0-9a-zA-Z_]/, '');
			th.templatingData["%formRaw%"] = form.formName;
			th.templatingData["%view%"] = form.viewName;
			th.templatingData["%project%"] = targetPath.name;
			generateModuleFilesContent(form, th);

			for (var source:Object in moduleCopyTargets)
			{
				th.projectTemplate(new FileLocation(source.nativePath), new FileLocation(moduleCopyTargets[source].nativePath));
			}
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

			var key:String = relativePath.replace('\\', '/');  // normalize windows paths
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