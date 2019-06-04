package actionScripts.plugin.groovy.grailsproject.vo
{
	import mx.collections.ArrayList;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GrailsBuildOptions;
	import actionScripts.plugin.groovy.grailsproject.exporter.GrailsExporter;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import actionScripts.plugin.settings.vo.FileNameSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.valueObjects.ProjectVO;

	public class GrailsProjectVO extends ProjectVO
	{
		private static const TARGET_BYTECODE_VALUES:Array = ["1.4", "1.5", "1.6", "1.7", "1.8", "9", "10", "11", "12", "13"];

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var grailsBuildOptions:GrailsBuildOptions;
		
		public function GrailsProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
			grailsBuildOptions = new GrailsBuildOptions(folder.fileBridge.nativePath);
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Grails Build", Vector.<ISetting>([
					new BuildActionsListSettings(this.grailsBuildOptions, grailsBuildOptions.buildActions, "commandLine", "Build Actions")
				]))
			]);
			settings.sort(order);
			return settings;
		}

		private function order(a:SettingsWrapper, b:SettingsWrapper):int
		{ 
			if (a.name < b.name) { return -1; } 
			else if (a.name > b.name) { return 1; }
			return 0;
		}

		override public function saveSettings():void
		{
			GrailsExporter.export(this);
		}
	}
}