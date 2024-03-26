package actionScripts.plugin.tibbo.tibboproject
{
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IActionItemsProvider;
import actionScripts.plugin.IProjectTypePlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.tibbo.tibboproject.importer.TibboBasicImporter;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.project.ProjectType;
import actionScripts.ui.actionbar.vo.ActionItemVO;
import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.ui.menu.vo.MenuItem;
	
	public class TibboBasicProjectPlugin extends PluginBase implements IProjectTypePlugin, IActionItemsProvider
	{	
		public var activeType:uint = ProjectType.TIBBO_BASIC;
		private var executeCreateProject:CreateTibboBasicProject;
		
		override public function get name():String 			{ return "Tibbo Basic Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Tibbo Basic project importing, exporting & scaffolding."; }

		public function get projectClass():Class
		{
			return TibboBasicProjectVO;
		}

		public function getActionItems(project:ProjectVO):Vector.<ActionItemVO>
		{
			return Vector.<ActionItemVO>([]);
		}

		public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
            return null;
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			
			super.deactivate();
		}

		public function testProjectDirectory(dir:FileLocation):FileLocation
		{
			return TibboBasicImporter.test(dir);
		}

		public function parseProject(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):ProjectVO
		{
			return TibboBasicImporter.parse(projectFolder, projectName, settingsFileLocation);
		}
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			executeCreateProject = new CreateTibboBasicProject(event);
		}

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.TIBBO_BASIC) != -1;
        }
	}
}