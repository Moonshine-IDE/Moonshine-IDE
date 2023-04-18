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
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.VOClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.PropertyInterfaceDeclarationStatement;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;

	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;
	import actionScripts.valueObjects.ProjectVO;

	public class DominoInterfaceVOClassGenerator extends DominoVOClassGenerator
	{
		private var _pageRelativePathString:String;
		override protected function get pageRelativePathString():String		{	return _pageRelativePathString;	}

		public function DominoInterfaceVOClassGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function = null)
		{
			_pageRelativePathString = project.name + "/views/modules/subforms/"+ form.formName +"/interfaces/I"+ form.formName +"VO.as";

			super(project, form, classReferenceSettings, onComplete);
		}

		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;

			generateClassReferences(onGenerationCompleted);

			function onGenerationCompleted():void
			{
				var subFormExtends:String = form.toSubformVOExtends();

				fileContent = fileContent.replace(/%ImportStatements%/ig, generateSubformImportStatements());
				fileContent = fileContent.replace(/%InterfacesExtends%/ig, subFormExtends ? " extends " + form.toSubformVOExtends() : "");
				fileContent = fileContent.replace(/%PropertyStatements%/ig, generateProperties());
				fileContent = fileContent.replace(/$moduleName/ig, form.formName);

				saveFile(fileContent);
				dispatchCompletion();
			}
		}

		override protected function generateProperties():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isMultiValue)
				{
					tmpContent += PropertyInterfaceDeclarationStatement.getArray(field.name) +"\n\n";
				}
				else
				{
					switch (field.type)
					{
						case FormBuilderFieldType.TEXT:
						case FormBuilderFieldType.RICH_TEXT:
							tmpContent += PropertyInterfaceDeclarationStatement.getString(field.name) +"\n\n";
							break;
						case FormBuilderFieldType.NUMBER:
							tmpContent += PropertyInterfaceDeclarationStatement.getNumber(field.name) +"\n\n";
							break;
						case FormBuilderFieldType.DATETIME:
							tmpContent += PropertyInterfaceDeclarationStatement.getDate(field.name) +"\n\n";
							break;
					}
				}
			}

			return tmpContent;
		}
	}
}
