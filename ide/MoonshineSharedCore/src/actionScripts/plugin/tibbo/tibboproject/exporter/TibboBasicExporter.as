package actionScripts.plugin.tibbo.tibboproject.exporter
{
    import actionScripts.plugin.tibbo.tibboproject.vo.TibboBasicProjectVO;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
    import actionScripts.utils.SerializeUtil;

    public class TibboBasicExporter extends FlashDevelopExporterBase
    {
		private static const PROJECT_FILE_EXTENSION:String = ".tibboproj";

        public static function export(project:TibboBasicProjectVO):void
        {
            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + PROJECT_FILE_EXTENSION);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
		}

		private static function toXML(project:TibboBasicProjectVO):XML
		{
			var projectXML:XML = <project/>;
			var tmpXML:XML;

			projectXML.appendChild(exportPaths(project.classpaths, <classpaths />, <class />, project));
			
			projectXML.appendChild(exportPaths(project.hiddenPaths, <hiddenPaths />, <hidden />, project));
			
			var options:XML = <options />;
			var optionPairs:Object = {
				showHiddenPaths		:	SerializeUtil.serializeBoolean(project.showHiddenPaths)
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);

			return projectXML;
		}
	}
}