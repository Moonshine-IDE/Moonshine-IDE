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
package actionScripts.plugins.ondiskproj.crud.exporter.pages
{
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleDataGridColumn;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.PropertyDeclarationStatement;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.RoyaleCRUDUtils;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;
	import actionScripts.valueObjects.ProjectVO;

	import flash.events.Event;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class VOClassGenerator extends RoyalePageGeneratorBase
	{
		public static const EVENT_COMPLETE:String = "event-complete";

		private var _pageRelativePathString:String;
		override protected function get pageRelativePathString():String		{	return _pageRelativePathString;	}
		
		public function VOClassGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			_pageRelativePathString = "views/modules/"+ form.formName +"/"+ form.formName +"VO/"+ form.formName +"VO.as";

			super(project, form, classReferenceSettings, onComplete);
			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;
			
			generateClassReferences(onGenerationCompletes);

			/*
			 * @local
			 */
			function onGenerationCompletes():void
			{
				fileContent = fileContent.replace(/%PropertyStatements%/ig, generateProperties());
				fileContent = fileContent.replace(/%ToRequestObjectStatements%/g, generateToRequestObjects());
				fileContent = fileContent.replace(/%GetNewVOStatements%/g, generateNewVOfromObject());
				fileContent = fileContent.replace(/$moduleName/ig, form.formName);

				saveFile(fileContent);
				dispatchCompletion();
			}
		}

		private function generateProperties():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					tmpContent += PropertyDeclarationStatement.getArrayList(field.name) +"\n\n";
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

		private function generateToRequestObjects():String
		{
			var tmpContents:Array = [];
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? "+ form.formName +"VO.getToRequestMultivalueDateString(this."+ field.name +") : []");
							break;
						default:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? JSON.stringify("+ field.name +".source) : []");
							break;
					}
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.DATETIME:
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? "+ form.formName +"VO.getToRequestDateString(this."+ field.name +") : null");
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

		private function generateNewVOfromObject():String
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
							tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = new ArrayList(value."+ field.name +");\t}\n";
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
	}
}