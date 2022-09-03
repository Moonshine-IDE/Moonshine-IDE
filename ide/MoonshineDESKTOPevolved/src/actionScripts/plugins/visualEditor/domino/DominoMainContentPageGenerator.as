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
		override protected function get pageRelativePathString():String		{	return "views/MainContent.mxml";	}
		
		private var forms:Vector.<DominoFormVO>;
		
		public function DominoMainContentPageGenerator(project:ProjectVO, forms:Vector.<DominoFormVO>, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
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
			var drawerDataProvider:String = "";
			for each (var form:DominoFormVO in forms)
			{
				scrollableContents += DominoRoyaleScrollableSectionContent.toCode(form.formName,"views.modules." + form.formName + "." + form.formName + "Views.") + "\n";
				drawerDataProvider += DominoRoyaleDrawerDataProvider.toCode(form.formName, form.formName);
			}
			
			fileContent = fileContent.replace(/%Namespaces%/gi, namespacePathStatements.join("\n"));
			fileContent = fileContent.replace(/%ImportStatements%/gi, importPathStatements.join("\n"));
			fileContent = fileContent.replace(/%MainContentMenu%/gi, drawerDataProvider);
			fileContent = fileContent.replace(/%ScrollableSectionContents%/gi, scrollableContents);
			
			saveFile(fileContent);
			dispatchCompletion();
		}

		override protected function get namespacePathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				paths.push('xmlns:'+ item.name +'="'+ 'views.modules.' + item.name + '.' + item.name +'Views.*" ');
			}
			return paths;
		}

		override protected function get importPathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				paths.push("import "+ 'views.modules.' + item.name + '.' + item.name + 'Views.' + item.name +";");
			}
			return paths;
		}
	}
}