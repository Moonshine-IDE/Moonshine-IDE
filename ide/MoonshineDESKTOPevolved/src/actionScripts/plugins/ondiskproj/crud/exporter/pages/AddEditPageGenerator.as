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
package actionScripts.plugins.ondiskproj.crud.exporter.pages
{
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleFormItem;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
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