package actionScripts.plugin.genericproj.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.genericproj.exporter.GenericProjectExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.valueObjects.ProjectVO;

	import mx.collections.ArrayCollection;

	public class GenericProjectVO extends ProjectVO
	{
		public var mavenBuildOptions:MavenBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;
		public var isAntFileAvailable:Boolean;
		public var buildOptions:GenericProjectBuildOptions;

		public function get antBuildPath():String
		{
			return buildOptions.antBuildPath;
		}
		public function set antBuildPath(value:String):void
		{
			buildOptions.antBuildPath = value;
		}

		public function GenericProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);

			buildOptions = new GenericProjectBuildOptions();
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
			gradleBuildOptions.commandLine = "clean run";
		}

		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = new Vector.<SettingsWrapper>();

			var pathSetting:StringSetting = new StringSetting(this, 'folderPath', 'Path');
			pathSetting.isEditable = false;

			settings.push(
					new SettingsWrapper(
							"Name & Location",
							Vector.<ISetting>([pathSetting])
					)
			);

			if (buildOptions.antBuildPath || isAntFileAvailable)
			{
				settings.push(
					new SettingsWrapper("Ant Build", Vector.<ISetting>([
						new PathSetting(this, "antBuildPath", "Ant Build File", false, antBuildPath, false)
					]))
				);
			}

			if (hasPom())
			{
				settings.push(new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions")
				])));
			}

			if (hasGradleBuild())
			{
				settings.push(new SettingsWrapper("Gradle Build", Vector.<ISetting>([
					new BuildActionsListSettings(this.gradleBuildOptions, gradleBuildOptions.buildActions, "commandLine", "Build Actions")
				])));
			}

			return settings;
		}

		override public function saveSettings():void
		{
			GenericProjectExporter.export(this);
		}

		public function hasPom():Boolean
		{
			var pomFile:FileLocation = projectFolder.file.fileBridge.resolvePath("pom.xml");
			return pomFile.fileBridge.exists;
		}

		public function hasGradleBuild():Boolean
		{
			var gradleFile:FileLocation = projectFolder.file.fileBridge.resolvePath("build.gradle");
			return gradleFile.fileBridge.exists;
		}

		public function hasAnt():Boolean
		{
			if (buildOptions.antBuildPath)
					return model.fileCore.isPathExists(buildOptions.antBuildPath);

			var antFiles:ArrayCollection = model.flexCore.searchAntFile(this);
			if (antFiles.length > 0)
			{
				buildOptions.antBuildPath = (antFiles[0] as FileLocation).fileBridge.nativePath;
			}
			return ((antFiles.length > 0) ? true : false);
		}
	}
}
