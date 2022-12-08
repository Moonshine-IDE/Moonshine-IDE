package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
    
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.factory.FileLocation;

	public class ExportConstants  
	{
		private const J_APPLICATION:String = "<j:Application"
		
		// Main Content Manager
		private const GENERATED_MAINCONTENTMANAGER_CURSOR:String = "GENERATED_MAINCONTENTMANAGER_CURSOR";
		private const START_GENERATED_SCRIPT_MAINCONTENTMANAGER:String = "START_GENERATED_SCRIPT_MAINCONTENTMANAGER";
		private const END_GENERATED_SCRIPT_MAINCONTENTMANAGER:String = "END_GENERATED_SCRIPT_MAINCONTENTMANAGER";
		
		// Menu
		private const GENERATED_MENU_CURSOR:String = "GENERATED_MENU_CURSOR";
		private const START_GENERATED_MENU:String = "START_GENERATED_MENU";
		private const END_GENERATED_MENU:String = "END_GENERATED_MENU";
		
		// Views
		private const GENERATED_VIEWS_CURSOR:String = "GENERATED_VIEWS_CURSOR";
		private const START_GENERATED_SCROLLABLE_SECTION:String = "START_GENERATED_SCROLLABLE_SECTION";
		private const END_GENERATED_SCROLLABLE_SECTION:String = "END_GENERATED_SCROLLABLE_SECTION";
		
		// CSS
		private const CSS_CURSOR:String = "APPLICATION_CSS_CURSOR";		
		private const START_GENERATED_SCRIPT_CSSSTYLES:String = "START_GENERATED_SCRIPT_CSSSTYLES";
		private const END_GENERATED_SCRIPT_CSSSTYLES:String = "END_GENERATED_SCRIPT_CSSSTYLES";	

		private var _projectName:String;
		
		public function ExportConstants(projectName:String)
		{
			_projectName = projectName;
		}
		
		public function get jApplication():String
		{
			return this.J_APPLICATION;
		}
		
		// Main Content Manager
		public function get mainContentManagerStartToken():String
		{
			return this.START_GENERATED_SCRIPT_MAINCONTENTMANAGER + "_" + _projectName;
		}
		
		public function get mainContentManagerEndToken():String
		{
			return this.END_GENERATED_SCRIPT_MAINCONTENTMANAGER + "_" + _projectName;
		}
		
		public function get mainContentMenagerCursor():String
		{
			return this.GENERATED_MAINCONTENTMANAGER_CURSOR;
		}
		
		// Menu
		public function get menuStartToken():String
		{
			return this.START_GENERATED_MENU + "_" + _projectName;
		}
		
		public function get menuEndToken():String
		{
			return this.END_GENERATED_MENU + "_" + _projectName;
		}
		
		public function get menuCursor():String
		{
			return this.GENERATED_MENU_CURSOR;
		}
		
		// Views
		public function get viewsStartToken():String
		{
			return this.START_GENERATED_SCROLLABLE_SECTION + "_" + _projectName;
		}
		
		public function get viewsEndToken():String
		{
			return this.END_GENERATED_SCROLLABLE_SECTION + "_" + _projectName;
		}
		
		public function get viewsCursor():String
		{
			return this.GENERATED_VIEWS_CURSOR;
		}
		
		// CSS
		public function get cssStartToken():String
		{
			return this.START_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName;
		}
		
		public function get cssEndToken():String
		{
			return this.END_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName;
		}
		
		public function get cssCursor():String
		{
			return this.CSS_CURSOR;
		}
		
		public function getCssSection():TextLines
		{
			return new TextLines([
				"<!--" + START_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName + ":  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->",
				"<fx:Style source=\"../../generated/" + _projectName + "/resources/export-app-styles.css\"/>",
				"<!--" + END_GENERATED_SCRIPT_CSSSTYLES + "_" + _projectName + ": **DO NOT MODIFY ANYTHING ABOVE THIS LINE MANUALLY**-->"
			])
		}
	}
}