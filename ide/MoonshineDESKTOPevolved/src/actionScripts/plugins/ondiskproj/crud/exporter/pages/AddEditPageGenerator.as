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
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleFormItem;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.RoyaleCRUDUtils;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class AddEditPageGenerator extends RoyalePageGeneratorBase
	{
		private var _pageRelativePathString:String;
		override protected function get pageRelativePathString():String		{	return _pageRelativePathString;	}
		
		public function AddEditPageGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			_pageRelativePathString = "views/modules/"+ form.formName +"/"+ form.formName +"Views/"+ form.formName +"AddEdit.mxml";
			pageImportReferences = new <PageImportReferenceVO>[
				new PageImportReferenceVO(form.formName +"Listing", "mxml"),
				new PageImportReferenceVO(form.formName +"Proxy", "as"),
				new PageImportReferenceVO(form.formName +"VO", "as")
			];

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
				fileContent = fileContent.replace(/%ImportStatements%/ig, importPathStatements.join("\n"));
				fileContent = fileContent.replace(/$moduleName/ig, form.formName);
				fileContent = fileContent.replace(/%ListingComponentName%/ig, form.formName +"Listing");
				fileContent = fileContent.replace(/%ViewComponentName%/ig, form.formName +"AddEdit");

				fileContent = fileContent.replace(/%FormItems%/ig, generateFormItems());
				fileContent = fileContent.replace(/%ProxyValuesToComponentCodes%/ig, generateAssignProxyValuesToComponents());
				fileContent = fileContent.replace(/%ComponentValuesToProxyCodes%/ig, generateAssignComponentsValuesToProxy());
				fileContent = fileContent.replace(/%FormResetCodes%/ig, generateFormResetCodes());
				fileContent = fileContent.replace(/%FormName%/ig, form.viewName);
				saveFile(fileContent);
				dispatchCompletion();
			}
		}
		
		private function generateFormItems():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				tmpContent += RoyaleFormItem.toCode(field) +"\n";
			}
			
			return tmpContent;
		}

		private function generateAssignProxyValuesToComponents():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.type == FormBuilderFieldType.NUMBER && !field.isMultiValue)
				{
					tmpContent += RoyaleFormItem.assignValuesToComponentCode(field) +"proxy.selectedItem."+ field.name + ".toString();\n";
				}
				else
				{
					tmpContent += RoyaleFormItem.assignValuesToComponentCode(field) +"proxy.selectedItem."+ field.name + ";\n";
				}
				/*switch (field.type)
				{
					case FormBuilderFieldType.NUMBER:
						if (!field.isMultiValue)

						break;
					default:

				}*/
			}

			return tmpContent;
		}

		private function generateAssignComponentsValuesToProxy():String
		{
			var tmpContent:String = "var submitObject:"+ form.formName +"VO = new "+ form.formName +"VO();\n";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				tmpContent += "submitObject."+ field.name + RoyaleFormItem.retrieveComponentValuesToCode(field) +";\n";
			}

			tmpContent += "if (proxy.selectedItem) submitObject.DominoUniversalID = proxy.selectedItem.DominoUniversalID;\n";
			tmpContent += "proxy.submitItem(submitObject);\n";

			return tmpContent;
		}

		private function generateFormResetCodes():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				tmpContent += RoyaleFormItem.assignValuesToComponentCode(field) +"null;\n";
			}

			return tmpContent;
		}
	}
}