package actionScripts.plugins.exportToExternalProject.utils
{
    
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.factory.FileLocation;

	public class ExportConstants  
	{
		public static const J_APPLICATION:String = "<j:Application"
		
		// Main Content Manager
		public static const GENERATED_MAINCONTENTMANAGER_CURSOR:String = "GENERATED_MAINCONTENTMANAGER_CURSOR";
		public static const START_GENERATED_SCRIPT_MAINCONTENTMANAGER:String = "START_GENERATED_SCRIPT_MAINCONTENTMANAGER";
		public static const END_GENERATED_SCRIPT_MAINCONTENTMANAGER:String = "END_GENERATED_SCRIPT_MAINCONTENTMANAGER";
		
		// Menu
		public static const GENERATED_MENU_CURSOR:String = "GENERATED_MENU_CURSOR";
		public static const START_GENERATED_MENU:String = "START_GENERATED_MENU";
		public static const END_GENERATED_MENU:String = "END_GENERATED_MENU";
		
		// Views
		public static const GENERATED_VIEWS_CURSOR:String = "GENERATED_VIEWS_CURSOR";
		public static const START_GENERATED_SCROLLABLE_SECTION:String = "START_GENERATED_SCROLLABLE_SECTION";
		public static const END_GENERATED_SCROLLABLE_SECTION:String = "END_GENERATED_SCROLLABLE_SECTION";
		
		// CSS
		public static const CSS_CURSOR:String = "APPLICATION_CSS_CURSOR";		
		public static const START_GENERATED_SCRIPT_CSSSTYLES:String = "START_GENERATED_SCRIPT_CSSSTYLES";
		public static const END_GENERATED_SCRIPT_CSSSTYLES:String = "END_GENERATED_SCRIPT_CSSSTYLES";	

		private var _projectName:String;
		
		public function ExportConstants(projectName:String)
		{
			_projectName = projectName;
		}
		
		// Main Content Manager
		public function get mainContentManagerStartToken():String
		{
			return START_GENERATED_SCRIPT_MAINCONTENTMANAGER + "_" + _projectName;
		}
		
		public function get mainContentManagerEndToken():String
		{
			return END_GENERATED_SCRIPT_MAINCONTENTMANAGER + "_" + _projectName;
		}
		
		// Menu
		public function get menuStartToken():String
		{
			return START_GENERATED_MENU + "_" + _projectName;
		}
		
		public function get menuEndToken():String
		{
			return END_GENERATED_MENU + "_" + _projectName;
		}
		
		// Views
		public function get viewsStartToken():String
		{
			return START_GENERATED_SCROLLABLE_SECTION + "_" + _projectName;
		}
		
		public function get viewsEndToken():String
		{
			return END_GENERATED_SCROLLABLE_SECTION + "_" + _projectName;
		}
		
		// CSS
		public function cssSection():TextLines
		{
			return new TextLines([
				"<!--" + START_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName + ":  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->",
				"<fx:Style source=\"../../generated/" + _projectName + "/resources/export-app-styles.css\"/>",
				"<!--" + END_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName + ": **DO NOT MODIFY ANYTHING ABOVE THIS LINE MANUALLY**-->"
			])
		}
	}
}