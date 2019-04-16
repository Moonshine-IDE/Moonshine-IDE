package actionScripts.plugin.groovy.groovyproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.groovy.groovyproject.exporter.GroovyExporter;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.ISetting;

	public class GroovyProjectVO extends ProjectVO
	{
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var sourceFolder:FileLocation;
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();

		public function GroovyProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
                new SettingsWrapper("Paths",
					new <ISetting>[
						new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
					]
                )
			]);
			return settings;
		}

		override public function saveSettings():void
		{
			GroovyExporter.export(this);
		}
	}
}