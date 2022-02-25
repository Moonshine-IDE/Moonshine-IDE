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
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleScrollableSectionContent;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class MainContentPageGenerator extends RoyalePageGeneratorBase
	{
		override protected function get pageRelativePathString():String		{	return "views/MainContent.mxml";	}
		
		private var forms:Vector.<DominoFormVO>;
		
		public function MainContentPageGenerator(project:ProjectVO, forms:Vector.<DominoFormVO>, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			super(project, null, classReferenceSettings, onComplete);
			
			this.forms = forms;
			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;
			
			var importStatements:String = "";
			var scrollableContents:String = "";
			var namespaces:String = "";
			
			for each (var form:DominoFormVO in forms)
			{
				importStatements += "import "+ classReferenceSettings[(form.formName +"Listing"+ RoyaleCRUDClassReferenceSettings.IMPORT)] +";\n";
				importStatements += "import "+ classReferenceSettings[(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.IMPORT)] +";\n";
				
				namespaces += 'xmlns:'+ form.formName +'AddEdit="'+ classReferenceSettings[(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.NAMESPACE)] +'" \n';
				namespaces += 'xmlns:'+ form.formName +'Listing="'+ classReferenceSettings[(form.formName +"Listing"+ RoyaleCRUDClassReferenceSettings.NAMESPACE)] +'" \n';
				
				scrollableContents += RoyaleScrollableSectionContent.toCode(form.formName +"Listing") +"\n";
				scrollableContents += RoyaleScrollableSectionContent.toCode(form.formName +"AddEdit") +"\n";
			}
			
			fileContent = fileContent.replace(/%Namespaces%/gi, namespaces);
			fileContent = fileContent.replace(/%ImportStatements%/gi, importStatements);
			fileContent = fileContent.replace(/%ScrollableSectionContents%/gi, scrollableContents);
			
			saveFile(fileContent);
			dispatchCompletion();
		}
	}
}