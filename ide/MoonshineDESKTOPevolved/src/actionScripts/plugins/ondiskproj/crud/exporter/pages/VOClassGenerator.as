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
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.PropertyDeclarationStatement;
	import actionScripts.valueObjects.ProjectVO;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class VOClassGenerator extends RoyalePageGeneratorBase
	{
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
				fileContent = fileContent.replace(/%ToCloneStatements%/, cloneVOObject());
				fileContent = fileContent.replace(/$moduleName/ig, form.formName);

				saveFile(fileContent);
				dispatchCompletion();
			}
		}

		protected function generateProperties():String
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

		protected function generateToRequestObjects():String
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
							tmpContents.push("\n"+ field.name +": this."+ field.name +" ? JSON.stringify("+ field.name +".source) : \"[]\"");
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

		protected function generateNewVOfromObject():String
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

		protected function cloneVOObject():String
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
							tmpContent += "\t\t\t\ttmpVO."+ field.name +" = new ArrayList(this."+ field.name +".source);\n";
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
	}
}