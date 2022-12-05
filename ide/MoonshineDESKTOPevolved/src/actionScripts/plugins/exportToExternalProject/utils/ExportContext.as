package actionScripts.plugins.exportToExternalProject.utils
{
	public class ExportContext
	{
		private var projectName:String;
		private var formNames:Array;

		public function ExportContext(projectName:String, formNames:Array)
		{
			this.projectName = projectName;
			this.formNames = formNames;
		}

		private function getStartMenuItem(formName:String):String
		{
			<!--START_GENERATED_MENU_MYPROJECT_ConfiguredCommand:  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->
			return "<!--START_GENERATED_MENU_" + projectName + "_" + formName + ":  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->"
		}

		private function getEndMenuItem(formName:String):String
		{
			<!--START_GENERATED_MENU_MYPROJECT_ConfiguredCommand:  **DO NOT MODIFY ANYTHING BELOW THIS LINE MANUALLY**-->
			return "<!--END_GENERATED_MENU_" + projectName + "_" + formName + ":  **DO NOT MODIFY ANYTHING ABOVE THIS LINE MANUALLY**-->"
		}
	}
}
