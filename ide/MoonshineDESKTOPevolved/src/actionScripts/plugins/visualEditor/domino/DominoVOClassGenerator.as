package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.VOClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.PropertyDeclarationStatement;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;

	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;
	import actionScripts.valueObjects.ProjectVO;

	public class DominoVOClassGenerator extends VOClassGenerator
	{
		public function DominoVOClassGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function = null)
		{
			super(project, form, classReferenceSettings, onComplete);
		}

		override protected function generateNewVOfromObject():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = "+ form.formName +"VO.parseFromRequestMultivalueDateString(value."+ field.name +");\t}\n";
							break;
						default:
							tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = value."+ field.name +" ? value."+ field.name +".concat() : [];\t}\n";
							break;
					}
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = "+ form.formName +"VO.parseFromRequestDateString(value."+ field.name +");\t}\n";
							break;
						default:
							tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = value."+ field.name +";\t}\n";
							break;
					}
				}
			}
			tmpContent += "if (\"DominoUniversalID\" in value){\ttmpVO.DominoUniversalID = value.DominoUniversalID;\t}\n";

			return tmpContent;
		}

		override protected function cloneVOObject():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContent += "\t\t\t\ttmpVO."+ field.name +" = this."+ field.name +";\n";
							break;
						default:
							tmpContent += "\t\t\t\ttmpVO."+ field.name +" = this."+ field.name +" ? this."+ field.name +".concat() : [];\n";
							break;
					}
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContent += "\t\t\t\ttmpVO."+ field.name +" = this."+ field.name +";\n";
							break;
						default:
							tmpContent += "\t\t\t\ttmpVO."+ field.name +" = this."+ field.name +";\n";
							break;
					}
				}
			}
			tmpContent += "\t\t\t\ttmpVO.DominoUniversalID = this.DominoUniversalID;\n";

			return tmpContent;
		}

		override protected function generateProperties():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					tmpContent += PropertyDeclarationStatement.getArray(field.name) +"\n\n";
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.TEXT:
						case FormBuilderFieldType.RICH_TEXT:
							tmpContent += PropertyDeclarationStatement.getString(field.name) +"\n\n";
							break;
						case FormBuilderFieldType.NUMBER:
							tmpContent += PropertyDeclarationStatement.getNumber(field.name) +"\n\n";
							break;
						case FormBuilderFieldType.DATETIME:
							tmpContent += PropertyDeclarationStatement.getDate(field.name) +"\n\n";
							break;
					}
				}
			}

			return tmpContent;
		}

		override protected function generateToRequestObjects():String
		{
			var tmpContents:Array = [];
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? "+ form.formName +"VO.getToRequestMultivalueDateString(this."+ field.name +") : \"[]\"");
							break;
						default:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? JSON.stringify("+ field.name +") : \"[]\"");
							break;
					}
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? "+ form.formName +"VO.getToRequestDateString(this."+ field.name +") : ''");
							break;
						default:
							tmpContents.push("\n"+ field.name +": this."+ field.name);
							break;
					}
				}
			}

			return ("var tmpRequestObject:Object = {\n\t"+ tmpContents.join(",") + "\n};\n" +
					"if (DominoUniversalID) tmpRequestObject.DominoUniversalID = DominoUniversalID;\n" +
					"return tmpRequestObject;");
		}
	}
}
