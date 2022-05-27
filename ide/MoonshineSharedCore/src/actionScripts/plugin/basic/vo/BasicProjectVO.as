package actionScripts.plugin.basic.vo
{
    import actionScripts.languageServer.LanguageServerProjectVO;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.basic.exporter.BasicExporter;
    import actionScripts.plugin.settings.vo.SettingsWrapper;

	public class BasicProjectVO extends LanguageServerProjectVO
	{
		public function BasicProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true)
		{
			super(folder, projectName, updateToTreeView);
		}
		
		
		override public function saveSettings():void
		{
			BasicExporter.export(this);
		}
		
		
		override public function getSettings():Vector.<SettingsWrapper>{
			//throw new Error("Method getSettings() is not implemented")
			/**
			Do nothing for now
			*/
			return new Vector.<SettingsWrapper>();
		}
		
		
	}
}