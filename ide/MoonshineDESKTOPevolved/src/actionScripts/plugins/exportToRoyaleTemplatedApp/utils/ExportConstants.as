package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

	public class ExportConstants  
	{
		public static const ROYALE_JEWEL_APPLICATION:String = "<j:Application";
		
		// General
		public static const NAME_START:String = "GENERATED_";
		public static const NAME_END:String = ":";
		public static const TOKEN_START:String = "<!--";
		public static const TOKEN_END:String = "-->";
		
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
		
		public static function getCssSection(projectName:String):GeneratedSection
		{
			return new GeneratedSection([
				"<!--" + START_GENERATED_SCRIPT_CSSSTYLES + "_" + projectName + ":  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->",
				"<fx:Style source=\"../../generated/" + projectName + "/resources/export-app-styles.css\"/>",
				"<!--" + END_GENERATED_SCRIPT_CSSSTYLES + "_" + projectName + ": **DO NOT MODIFY ANYTHING ABOVE THIS LINE MANUALLY**-->"
			])
		}
	}
}