package actionScripts.plugin.java.javaproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
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
		public var gradleBuildOptions:GradleBuildOptions;
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();

		private var _mainClassName:String;
		private var _mainClassPath:String;

		public function JavaProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths.splice(0, projectReference.hiddenPaths.length);
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
		}

		public function get mainClassName():String
		{
			return _mainClassName;
		}

		public function set mainClassName(value:String):void
		{
			if (_mainClassName != value)
			{
				_mainClassName = value;
			}
		}

		public function get mainClassPath():String
		{
			return _mainClassPath;
		}

		public function set mainClassPath(value:String):void
		{
			if (_mainClassPath != value)
			{
				mainClassName = new FileLocation(value).fileBridge.nameWithoutExtension;
				_mainClassPath = value;
			}
		}

		public function hasPom():Boolean
		{
			var pomFile:FileLocation = new FileLocation(mavenBuildOptions.buildPath).resolvePath("pom.xml");
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
			var pathsSettings:Vector.<ISetting> = new Vector.<ISetting>();
			pathsSettings.push(new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true));

			if (!hasGradleBuild())
			{
				var defaultMainClassPath:String = this._mainClassPath;
				if (!_mainClassPath)
				{
					defaultMainClassPath = this.folderLocation.fileBridge.nativePath;
				}

				pathsSettings.push(new PathSetting(this, "mainClassPath", "Main class", false, this.mainClassName, false, false, defaultMainClassPath));
			}

			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Paths", pathsSettings)
			]);

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
	}
}