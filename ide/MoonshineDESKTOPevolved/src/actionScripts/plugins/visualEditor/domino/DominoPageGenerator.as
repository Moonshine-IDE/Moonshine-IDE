package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.RoyalePageGeneratorBase;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;

	import view.dominoFormBuilder.vo.DominoFormVO;
	import actionScripts.valueObjects.ProjectVO;

	public class DominoPageGenerator extends RoyalePageGeneratorBase
	{
		private var _pageRelativePathString:String;

		public function DominoPageGenerator(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function = null)
		{
			_pageRelativePathString = "views/modules/"+ form.formName +"/"+ form.formName +"Views/"+ form.formName +".mxml";
			pageImportReferences = new <PageImportReferenceVO>[
				new PageImportReferenceVO(form.formName +"Proxy", "as"),
				new PageImportReferenceVO(form.formName +"VO", "as")
			];

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

				fileContent = fileContent.replace(/%ViewContent%/ig, pageContent);
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
	}
}
