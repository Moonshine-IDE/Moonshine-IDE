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
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleModuleLinkButton;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class DashboardPageGenerator extends RoyalePageGeneratorBase
	{
		override protected function get pageRelativePathString():String		{	return "views/general/Dashboard.mxml";	}
		
		private var forms:Vector.<DominoFormVO>;
		
		public function DashboardPageGenerator(project:ProjectVO, forms:Vector.<DominoFormVO>, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			super(project, form, classReferenceSettings, onComplete);
			
			this.forms = forms;
			pageImportReferences = new Vector.<PageImportReferenceVO>();
			for each (var form:DominoFormVO in forms)
			{
				pageImportReferences.push(new PageImportReferenceVO(form.formName +"Listing", "mxml"));
			}

			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;

			var moduleLinks:String = "";
			
			for each (var form:DominoFormVO in forms)
			{
				moduleLinks += RoyaleModuleLinkButton.toCode(form.formName +"Listing", form.viewName) +"\n";
			}
			
			fileContent = fileContent.replace(/%ImportStatements%/gi, importPathStatements.join("\n"));
			fileContent = fileContent.replace(/%ModuleLinks%/gi, moduleLinks);
			
			saveFile(fileContent);
			dispatchCompletion();
		}
	}
}