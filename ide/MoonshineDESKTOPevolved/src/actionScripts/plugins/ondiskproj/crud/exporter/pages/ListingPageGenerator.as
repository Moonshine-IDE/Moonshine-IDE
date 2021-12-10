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
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleDataGridColumn;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.RoyaleCRUDUtils;
	import actionScripts.valueObjects.ProjectVO;

	import flash.events.Event;

	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class ListingPageGenerator extends RoyalePageGeneratorBase
	{
		public static const EVENT_COMPLETE:String = "event-complete";

		private var _pageRelativePathString:String;
		override protected function get pageRelativePathString():String		{	return _pageRelativePathString;	}
		
		public function ListingPageGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			_pageRelativePathString = "views/modules/"+ form.formName +"/"+ form.formName +"Views/"+ form.formName +"Listing.mxml";
			
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
				fileContent = fileContent.replace(/%ImportStatements%/ig, "import "+ classReferenceSettings[(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.IMPORT)] +";\n");
				fileContent = fileContent.replace(/%AddEditComponentName%/ig, form.formName +"AddEdit");
				fileContent = fileContent.replace(/%ViewComponentName%/ig, form.formName +"Listing");

				fileContent = fileContent.replace(/%DataGridColumns%/ig, generateColumns());
				fileContent = fileContent.replace(/%FormName%/g, form.viewName);
				saveFile(fileContent);
				dispatchCompletion();
			}
		}
		
		private function generateColumns():String
		{
			var tmpContent:String = "";
			for each (var field:DominoFormFieldVO in form.fields)
			{
				if (field.isIncludeInView)
				{
					tmpContent += RoyaleDataGridColumn.toCode(field) +"\n";
				}
			}
			
			return tmpContent;
		}
		
		private function generateClassReferences(onComplete:Function):void
		{
			if (!classReferenceSettings.hasOwnProperty(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.IMPORT))
			{
				RoyaleCRUDUtils.getImportReferenceFor(form.formName +"AddEdit.mxml", project, onImportCompletes, ["mxml"]);

				/*
				 * @local
				 */
				function onImportCompletes(importPath:String):void
				{
					classReferenceSettings[(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.IMPORT)] = importPath;

					var splitPath:Array = importPath.split(".");
					splitPath[splitPath.length - 1] = "*";
					classReferenceSettings[(form.formName +"AddEdit"+ RoyaleCRUDClassReferenceSettings.NAMESPACE)] = splitPath.join(".");
					onComplete();
				}
			}
		}
	}
}