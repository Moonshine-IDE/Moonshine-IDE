package actionScripts.plugin.java.javaproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.java.javaproject.exporter.JavaExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.valueObjects.ProjectVO;

	public class JavaProjectVO extends ProjectVO
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";

		public var mavenBuildOptions:MavenBuildOptions;
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var sourceFolder:FileLocation;

		public function JavaProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
		}

		public function hasPom():Boolean
		{
			var pomFile:FileLocation = new FileLocation(mavenBuildOptions.mavenBuildPath).resolvePath("pom.xml");
			return pomFile.fileBridge.exists;
		}

		public function hasGradleBuild():Boolean
		{
			var gradleFile:FileLocation = projectFolder.file.fileBridge.resolvePath("build.gradle");
			return gradleFile.fileBridge.exists;
		}

		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = getJavaSettings();
			settings.sort((function order(a:Object, b:Object):Number
			{
				if (a.name < b.name) { return -1; }
				else if (a.name > b.name) { return 1; }
				return 0;
			}));

			return settings;
		}

		override public function saveSettings():void
		{
			JavaExporter.export(this);
		}

		private function getJavaSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Paths",
						Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true)
						])
				)
			]);

			if (hasPom())
			{
				settings.push(new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "mavenBuildPath", "Maven Build File", this.mavenBuildOptions.mavenBuildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
					new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
				])));
			}

			return settings;
		}
	}
}