package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.OnDiskRoyaleCRUDModuleExporter;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.GlobalClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ListingPageGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.ProxyClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.VOClassGenerator;

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

		public function DominoRoyaleModuleExporter(targetPath:FileLocation, project:ProjectVO, components:Array)
		{
			this.components = components;

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
					tmpFormObject.formName = this.components[i].file.fileBridge.nameWithoutExtension;
					tmpFormObject.viewName = "All By UNID_5c" + this.components[i].file.fileBridge.nameWithoutExtension + ".view";

					parseComponents(componentData, tmpFormObject);
					formObjects.push(tmpFormObject);
				}
			}

			copyModuleTemplates();
		}

		override protected function copyTemplates(form:DominoFormVO):void
		{
			var moduleName:String = form.formName;

			var th:TemplatingHelper = new TemplatingHelper();
			th.templatingData["$moduleName"] = moduleName;
			th.templatingData["$packagePath"] = "views.modules."+ moduleName +"."+ moduleName +"Services";

			th.projectTemplate(TEMPLATE_MODULE_PATH, targetPath);
		}

		override protected function generateModuleClasses():void
		{
			for each (var form:DominoFormVO in formObjects)
			{
				waitingCount += 3;
				new VOClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new ProxyClassGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
				new DominoPageGenerator(this.project, form, classReferenceSettings, onModuleGenerationCompletes);
			}
		}

		override protected function generateProjectClasses():void
		{
			new DominoMainContentPageGenerator(this.project, this.formObjects, classReferenceSettings, onProjectFilesGenerationCompletes);
			new GlobalClassGenerator(this.project, classReferenceSettings, onProjectFilesGenerationCompletes);
		}

		override protected function onModuleGenerationCompletes(origin:RoyalePageGeneratorBase):void
		{
			super.onModuleGenerationCompletes(origin);

			onCompleteHandler = null;
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
