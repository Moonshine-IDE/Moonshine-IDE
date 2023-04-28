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
	import actionScripts.plugins.ondiskproj.crud.exporter.CRUDJavaAgentsModuleExporter;

	import flash.filesystem.File;
	import interfaces.ISurface;

	import actionScripts.valueObjects.ProjectVO;

	import view.dominoFormBuilder.utils.FormBuilderCodeUtils;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class DominoJavaAgentsModuleExporter extends CRUDJavaAgentsModuleExporter
	{
		private var components:Array;

		public function DominoJavaAgentsModuleExporter(originPath:File, targetPath:File, project:ProjectVO, onComplete:Function, components:Array = null)
		{
			super(originPath, targetPath, project, onComplete);

			this.components = components;

			parseModules();
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
						tmpFormObject.formName = this.components[i].file.fileBridge.nameWithoutExtension;
						tmpFormObject.viewName = "All By UNID/CRUD/" + this.components[i].file.fileBridge.nameWithoutExtension;

					parseComponents(componentData, tmpFormObject);
					formObjects.push(tmpFormObject);
				}
			}

			copyModuleTemplates();
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