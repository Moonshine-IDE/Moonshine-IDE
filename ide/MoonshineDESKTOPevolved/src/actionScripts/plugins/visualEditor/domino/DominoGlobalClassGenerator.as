package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.pages.GlobalClassGenerator;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.valueObjects.ProjectVO;

	public class DominoGlobalClassGenerator extends GlobalClassGenerator
	{
		public function DominoGlobalClassGenerator(project:ProjectVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function = null)
		{
			super(project, classReferenceSettings, onComplete);
		}

		override public function generate():void
		{
			pagePath = project.sourceFolder.resolvePath(project.name + "/classes/vo/Constants.as");
			super.generate();
		}
	}
}
