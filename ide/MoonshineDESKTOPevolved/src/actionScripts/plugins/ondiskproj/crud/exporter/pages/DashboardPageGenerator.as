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
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleModuleLinkButton;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.RoyaleCRUDUtils;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class DashboardPageGenerator extends RoyalePageGeneratorBase
	{
		override protected function get pageRelativePathString():String		{	return "src/views/general/Dashboard.mxml";	}
		
		public var project:ProjectVO;
		
		private var forms:Vector.<DominoFormVO>;
		
		public function DashboardPageGenerator(projectPath:FileLocation, forms:Vector.<DominoFormVO>)
		{
			super(projectPath, form);
			
			this.forms = forms;
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;
			
			var importStatements:String = "";
			var moduleLinks:String = "";
			
			for each (var field:DominoFormVO in forms)
			{
				importStatements += "import "+ RoyaleCRUDUtils.getImportReferenceFor(project, field.formName +"_listing.mxml", ["mxml"]) +"\n";
				importStatements += "import "+ RoyaleCRUDUtils.getImportReferenceFor(project, field.formName +"_addEdit.mxml", ["mxml"]) +"\n";
				
				moduleLinks += RoyaleModuleLinkButton.toCode(field.formName +"_listing", field.viewName);
			}
			
			fileContent = fileContent.replace(/%ImportStatements%/gi, importStatements);
			fileContent = fileContent.replace(/%ModuleLinks%/gi, moduleLinks);
			
			saveFile(fileContent);
		}
	}
}