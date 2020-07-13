package actionScripts.plugin.ondiskproj.exporter
{
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class OnDiskMavenSettingsExporter
	{
		public static var mavenSettingsPath:FileLocation;
		
		private static var model:IDEModel = IDEModel.getInstance();
		
		public static function exportOnDiskMavenSettings(updateSitePath:String):void
		{
			var templateFileValue:String = getSettingsTemplate();
			
			if (mavenSettingsPath && templateFileValue)
			{
				templateFileValue = templateFileValue.replace(/\$NOTES_INSTALLATION_PATH/ig, model.notesPath);
				templateFileValue = templateFileValue.replace(/\$UPDATE_SITE_PATH/ig, updateSitePath);
				
				mavenSettingsPath.fileBridge.save(templateFileValue);
			}
		}
		
		private static function getSettingsTemplate():String
		{
			var templateFile:FileLocation = model.fileCore.resolveApplicationDirectoryPath(
				"elements/templates/domino/"+ (ConstantsCoreVO.IS_MACOS ? "settingsOSMac.xml" : "settingsOSWindows.xml")
			);
			
			if (templateFile.fileBridge.exists)
			{
				return (templateFile.fileBridge.read() as String);
			}
			
			return "";
		}
	}
}