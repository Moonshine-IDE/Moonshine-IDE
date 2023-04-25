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
package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.OnDiskRoyaleCRUDModuleExporter;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;

	import interfaces.ISurface;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;

	import view.dominoFormBuilder.vo.DominoFormVO;
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.templating.TemplatingHelper;

	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class DominoRoyaleModuleExporter extends OnDiskRoyaleCRUDModuleExporter
	{
		protected static const TEMPLATE_MODULE_PATH:FileLocation = IDEModel.getInstance().fileCore.resolveApplicationDirectoryPath("elements/templates/royaleDominoElements/module");

		private var components:Array;
		private var subFormPath:FileLocation;

		public function DominoRoyaleModuleExporter(targetPath:FileLocation, project:ProjectVO, components:Array, subFormPath:FileLocation = null)
		{
			this.components = components;
			this.subFormPath = subFormPath;

			super(targetPath, project, function():void {});
		}

		override protected function parseModules():void
		{
			if (!this.components) return;

			formObjects = new Vector.<DominoFormVO>();
			for (var i:int = 0; i < this.components.length; i++)
			{
				var surface:ISurface = this.components[i].surface;
				var componentData:Array = surface["getComponentData"]();
				if (componentData.length > 0)
				{
					for (var j:int = 0; j < componentData.length; j++)
					{
						var componentDataItem:Object = componentData[j];
						if (!componentDataItem.fields && !componentDataItem.name)
						{
							componentData.splice(j, 1);
						}
					}

					var tmpFormObject:DominoFormVO = new DominoFormVO();

					var nameWithoutExt:String = this.components[i].file.fileBridge.nameWithoutExtension;
					tmpFormObject.formName = nameWithoutExt;
					tmpFormObject.viewName = "All By UNID/CRUD/" + nameWithoutExt;
					tmpFormObject.pageContent = this.components[i].pageContent;
					tmpFormObject.isSubForm = this.components[i].isSubForm;
					tmpFormObject.subFormsNames = this.components[i].subFormsNames;

					parseComponents(componentData, tmpFormObject);
					formObjects.push(tmpFormObject);
				}
			}

			for (var j:int = 0; j < formObjects.length; j++)
			{
				var formObj:DominoFormVO = formObjects[j];
				var fields:Array = [];
				if (!formObj.isSubForm)
				{
					prepareFieldsFromSubForms(fields, formObj.subFormsNames);

					for each (var field:DominoFormFieldVO in fields)
					{
						formObj.fields.addItem(field);
					}
				}
			}

			copyModuleTemplates();
			generateProjectClasses();
		}

		private function prepareFieldsFromSubForms(fields:Array, subFormNames:Array):void
		{
			for (var i:int = 0; i < formObjects.length; i++)
			{
				var formObj:DominoFormVO = formObjects[i];
				if (subFormNames && subFormNames.length > 0)
				{
					for (var j:int = 0; j < subFormNames.length; j++)
					{
						var formName:String = subFormNames[j];
						if (formObj.formName == formName)
						{
							for each (var field:DominoFormFieldVO in formObj.fields)
							{
								fields.push(field);
							}

							if (formObj.subFormsNames && formObj.subFormsNames.length > 0)
							{
								prepareFieldsFromSubForms(fields, formObj.subFormsNames);
							}
						}
					}
				}
			}
		}

		override protected function copyTemplates(form:DominoFormVO):void
		{
			var moduleName:String = form.formName;

			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["$moduleName"] = moduleName;
			th.templatingData["$subforms"] = moduleName;
			th.templatingData["$packagePath"] = project.name + ".views.modules." + moduleName + "." + moduleName + "Services";

			th.templatingData["$ProjectName"] = project.name;

			var excludeFiles:Array = ["$subformsViews", "interfaces"];
			var templateTargetPath:FileLocation = targetPath;
			if (form.isSubForm)
			{
				excludeFiles = [];
				excludeFiles.push("$moduleNameServices");
				excludeFiles.push("$moduleNameVO");
				excludeFiles.push("$moduleNameViews");

				templateTargetPath = this.subFormPath;
			}

			th.projectTemplate(TEMPLATE_MODULE_PATH, templateTargetPath, excludeFiles);
		}

		override protected function generateModuleClasses():void
		{
			for each (var form:DominoFormVO in formObjects)
			{
				if (!form.isSubForm)
				{
					waitingCount += 3;
					new DominoVOClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
					new DominoProxyClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
					new DominoFormGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				}
				else
				{
					waitingCount += 2;
					new DominoInterfaceVOClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
					new DominoSubFormGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				}
			}
		}

		override protected function generateProjectClasses():void
		{
			new DominoMainContentPageGenerator(this.project, this.formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
			new DominoGlobalClassGenerator(this.project, classReferenceSettings, onProjectFilesGenerationCompletes);
		}

		override protected function onModuleGenerationCompletes(origin:RoyalePageGeneratorBase):void
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

		override protected function onProjectFilesGenerationCompletes(origin:RoyalePageGeneratorBase):void
		{
			completionCount++;

			if (waitingCount == completionCount)
			{
				onCompleteHandler();
				onCompleteHandler = null;
			}
		}

		private function parseComponents(componentData:Array, form:DominoFormVO):void
		{
			var data:Object = null;
			var fields:Array = null;
			var dominoField:DominoFormFieldVO;
			var componentDataCount:int = componentData.length;

			for (var i:int = 0; i < componentDataCount; i++)
			{
				data = componentData[i];
				fields = data.fields;
				if (!data.fields && !data.name)
				{
					continue;
				}

				dominoField = new DominoFormFieldVO();
				if (!data.fields && data.name)
				{
					dominoField.name = data.name;
					dominoField.type = getDominoType(data);
					dominoField.isMultiValue = data.allowMultiValues;

					form.fields.addItem(dominoField);
				}
				else
				{
					for (var j:int = 0; j < fields.length; j++)
					{
						var field:Object = fields[j];
						if (!field.name)
						{
							if (field.fields)
							{
								parseComponents(field.fields, form);
							}
							else
							{
								continue;
							}
						}
						else
						{
							dominoField.name = field.name;
							dominoField.type = getDominoType(field);
							dominoField.isMultiValue = field.allowMultiValues;

							form.fields.addItem(dominoField);
						}
					}
				}
			}
		}

		private function getDominoType(field:Object):String
		{
			switch(field.fieldType)
			{
				case "String":
					return field.isRichText ? FormBuilderFieldType.RICH_TEXT : FormBuilderFieldType.TEXT;
					break;
				case "Number":
					return FormBuilderFieldType.NUMBER;
					break;
				case "Date":
					return FormBuilderFieldType.DATETIME;
					break;
				default:
					return FormBuilderFieldType.TEXT;
					break;
			}
		}
	}
}
