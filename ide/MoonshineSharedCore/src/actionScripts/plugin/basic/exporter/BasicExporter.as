package actionScripts.plugin.basic.exporter
{
    
	import actionScripts.plugin.basic.vo.BasicProjectVO;
	import actionScripts.factory.FileLocation;


	public class BasicExporter  
	{
		private static const FILE_EXTENSION_BASICPROJ:String = ".basicproj";
		public function BasicExporter()
		{  
		}
		
		public static function export(project:BasicProjectVO, existingSource:Boolean = false):void{
			
			var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + FILE_EXTENSION_BASICPROJ);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
				
		}
		
		private static function toXML(project:BasicProjectVO):XML
		{
			var projectXML:XML = <project/>;
			var projectName:XML=<pn/>;
			projectName.@['projName']=project.projectName;
			projectXML.appendChild(projectName)
			          
			return projectXML;
		}

	}
}