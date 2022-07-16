package actionScripts.plugin.basic
{
    
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.project.ProjectType;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.events.NewProjectEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.project.ProjectType;
    import actionScripts.valueObjects.ConstantsCoreVO;	

	public class BasicProjectPlugin extends PluginBase
	{	
		public var activeType:uint = ProjectType.BASIC;
		
		override public function get name():String 			{ return "Basic Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Basic project importing, exporting & scaffolding."; }
		public function BasicProjectPlugin()
		{
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
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			model.basicCore.createProject(event);
		}

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.BASIC) != -1;
        }
	}
}