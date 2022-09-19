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