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
				fileContent = fileContent.replace(/$moduleName/ig, form.formName);
				fileContent = fileContent.replace(/%ToRequestObjectStatements%/g, generateToRequestObjects());
				fileContent = fileContent.replace(/%GetNewVOStatements%/g, generateNewVOfromObject());

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
			var tmpContent:String = "return {";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					//tmpContent += PropertyDeclarationStatement.getArrayList(field.name) +"\n\n"; // need server-sending example
				}
				else
				{
					tmpContent += "\n"+ field.name +": this."+ field.name +","
				}
			}

			// remove the ending comma
			if (tmpContent.charAt(tmpContent.length - 1) == ",")
			{
				tmpContent = tmpContent.substr(0, tmpContent.length - 1);
			}

			return (tmpContent + "\n};");
		}

		private function generateNewVOfromObject():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				tmpContent += "if (\""+ field.name +"\" in value){\ttmpVO."+ field.name +" = value."+ field.name +";\t}\n";
			}
			tmpContent += "if (\"DominoUniversalID\" in value){\ttmpVO.dominoUniversalID = value.DominoUniversalID;\t}\n";

			return tmpContent;
		}
	}
}