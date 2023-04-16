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
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;

	import view.dominoFormBuilder.vo.DominoFormVO;
	import actionScripts.valueObjects.ProjectVO;

	public class DominoFormGenerator extends RoyalePageGeneratorBase
	{
		private var _pageRelativePathString:String;

		private const MAX_LIST_COLUMNS_COUNT:int = 4;

		public function DominoFormGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function = null)
		{
			this.project = project;
			this.setPagePath(form);

			if (!pageImportReferences)
			{
				pageImportReferences = new <PageImportReferenceVO>[
					new PageImportReferenceVO(form.formName + "Proxy", "as"),
					new PageImportReferenceVO(form.formName + "VO", "as")
				];
			}

			super(project, form, classReferenceSettings, onComplete);
			generate();
		}

		override protected function get pageRelativePathString():String
		{
			return _pageRelativePathString;
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
				fileContent = fileContent.replace(/%ViewComponentName%/ig, form.formName);

				var pageChildren:XMLList = form.pageContent.children();
				var pageContent:String = "";
				for (var i:int = 0; i < pageChildren.length(); i++)
				{
					var page:String = pageChildren[i].toXMLString();
					pageContent += page + "\n";
				}

				//We are inserting here in fileContent quite large content. Unfortunately replace method for some reason
				//messing up inserted string - because of that we are using here different method for replace/insert.
				fileContent = fileContent.split(/%ViewContent%/ig).join(pageContent);

				var dgColumnList:String = getDataGridColumnsList();
				fileContent = fileContent.replace(/%DataGridColumnsList%/ig, dgColumnList);
				/*fileContent = fileContent.replace(/$moduleName/ig, form.formName);
				fileContent = fileContent.replace(/%ListingComponentName%/ig, form.formName +"Listing");
				fileContent = fileContent.replace(/%ViewComponentName%/ig, form.formName +"AddEdit");

				fileContent = fileContent.replace(/%FormItems%/ig, generateFormItems());
				fileContent = fileContent.replace(/%ProxyValuesToComponentCodes%/ig, generateAssignProxyValuesToComponents());
				fileContent = fileContent.replace(/%ComponentValuesToProxyCodes%/ig, generateAssignComponentsValuesToProxy());
				fileContent = fileContent.replace(/%FormResetCodes%/ig, generateFormResetCodes());
				fileContent = fileContent.replace(/%FormName%/ig, form.viewName);*/
				saveFile(fileContent);
				dispatchCompletion();
			}
		}

		private function getDataGridColumnsList():String
		{
			var fields:Object = this.form.fields;
			var columns:Array = [];
			if (fields)
			{
				var maxListColCount:int = fields.length > MAX_LIST_COLUMNS_COUNT ? MAX_LIST_COLUMNS_COUNT : fields.length;
				for (var i:int = 0; i < maxListColCount; i++)
				{
					var field:DominoFormFieldVO = fields.getItemAt(i);
					columns.push("{caption: '" + field.name + "', dataField: '"  + field.name + "'}");
				}
			}

			return columns.length > 0 ? "[" + columns.join(",") + "]" : "[]";
		}

		private function setPagePath(form:DominoFormVO):void
		{
			if (form.isSubForm)
			{
				_pageRelativePathString = project.name + "/views/modules/subforms/"+ form.formName +"/"+ form.formName +"Views/"+ form.formName +".mxml";
			}
			else
			{
				_pageRelativePathString = project.name + "/views/modules/"+ form.formName +"/"+ form.formName +"Views/"+ form.formName +".mxml";
			}
		}
	}
}
