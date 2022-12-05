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
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.*;
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleScrollableSectionContent;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class DominoMainContentPageGenerator extends RoyalePageGeneratorBase
	{
		private var _pageRelativePathString:String;

		override protected function get pageRelativePathString():String		{ return _pageRelativePathString;	}
		
		private var forms:Vector.<DominoFormVO>;
		
		public function DominoMainContentPageGenerator(project:ProjectVO, forms:Vector.<DominoFormVO>, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			_pageRelativePathString = project.name + "/views/MainContent.mxml";
			super(project, null, classReferenceSettings, onComplete);

			this.forms = forms;
			pageImportReferences = new Vector.<PageImportReferenceVO>();
			for each (var form:DominoFormVO in forms)
			{
				pageImportReferences.push(new PageImportReferenceVO(form.formName, "mxml"));
			}

			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;

			var scrollableContents:String = "";
			var drawerDataProvider:Array = [];
			for (var i:int = 0; i < forms.length; i++)
			{
				var form:DominoFormVO = forms[i];
				scrollableContents += DominoRoyaleScrollableSectionContent.toCode(form.formName,project.name + ".views.modules." + form.formName + "." + form.formName + "Views.") + "\n";
				drawerDataProvider.push(DominoRoyaleDrawerDataProvider.toCode(form.formName, form.formName));
			}
			
			fileContent = fileContent.replace(/%Namespaces%/gi, namespacePathStatements.join("\n"));
			fileContent = fileContent.replace(/%ImportStatements%/gi, importPathStatements.join("\n\t\t\t"));
			fileContent = fileContent.replace(/%MainContentMenu%/gi, drawerDataProvider.join("\n\t\t\t\t\t\t\t"));
			fileContent = fileContent.replace(/%ScrollableSectionContents%/gi, scrollableContents);
			
			saveFile(fileContent);
			dispatchCompletion();
		}

		override protected function get namespacePathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				paths.push('xmlns:'+ item.name +'="'+ project.name + '.views.modules.' + item.name + '.' + item.name +'Views.*" ');
			}
			return paths;
		}

		override protected function get importPathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				paths.push("import "+ project.name + '.views.modules.' + item.name + '.' + item.name + 'Views.' + item.name +";");
			}
			return paths;
		}
	}
}