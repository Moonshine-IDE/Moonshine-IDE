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
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleScrollableSectionContent;
	
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class MainContentPageGenerator extends RoyalePageGeneratorBase
	{
		override protected function get pageRelativePathString():String		{	return "src/views/MainContent.mxml";	}
		
		private var forms:Vector.<DominoFormVO>;
		
		public function MainContentPageGenerator(projectPath:FileLocation, forms:Vector.<DominoFormVO>)
		{
			super(projectPath, null);
			
			this.forms = forms;
			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;
			
			var importStatements:String = "";
			var scrollableContents:String = "";
			
			for each (var field:DominoFormVO in forms)
			{
				importStatements += "import views.modules."+ field.formName +"."+ field.formName +"_views."+ field.formName +"_listing;\n";
				importStatements += "import views.modules."+ field.formName +"."+ field.formName +"_views."+ field.formName +"_addEdit;\n";
				
				scrollableContents += RoyaleScrollableSectionContent.toCode(field.formName +"_listing") +"\n";
				scrollableContents += RoyaleScrollableSectionContent.toCode(field.formName +"_addEdit") +"\n";
			}
			
			fileContent = fileContent.replace(/%ImportStatements%/gi, importStatements);
			fileContent = fileContent.replace(/%ScrollableSectionContents%/gi, scrollableContents);
			
			saveFile(fileContent);
		}
	}
}