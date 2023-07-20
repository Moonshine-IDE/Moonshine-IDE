package actionScripts.plugin.tibbo.tibboproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.languageServer.LanguageServerProjectVO;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.tibbo.tibboproject.exporter.TibboBasicExporter;

	public class TibboBasicProjectVO extends LanguageServerProjectVO
	{
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var showHiddenPaths:Boolean = false;
		
		public function TibboBasicProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Paths",
						Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true)
						])
				)
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
			TibboBasicExporter.export(this);
		}

		override public function getProjectFilesToDelete():Array
		{
			var filesList:Array = [];
			filesList.unshift(classpaths);
			return filesList;
		}
	}
}