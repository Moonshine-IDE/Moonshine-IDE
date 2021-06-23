////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.java.javaproject.vo
{
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.java.javaproject.exporter.JavaExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ButtonSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MainClassSetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.languageServer.LanguageServerProjectVO;

	public class JavaProjectVO extends LanguageServerProjectVO implements IJavaProject
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";

		public var mavenBuildOptions:MavenBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		
		private var _jdkType:String = JavaTypes.JAVA_DEFAULT;
		public function get jdkType():String									{	return _jdkType;	}
		public function set jdkType(value:String):void							{	_jdkType = value;	}

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
			_mainClassName = value;
		}

		public function get mainClassPath():String
		{
			return _mainClassPath;
		}

		public function set mainClassPath(value:String):void
		{
			_mainClassPath = value;
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

		public var cleanWorkspaceButtonLabel:String = "Clean";

		public function cleanJavaWorkspaceButtonClickHandler():void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ExecuteLanguageServerCommandEvent(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
				this, "java.clean.workspace"));
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

				pathsSettings.push(new MainClassSetting(this, "mainClassName", "Main class", this.mainClassName, defaultMainClassPath));
			}
			
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Java Project", new <ISetting>[
					new ButtonSetting(this, "cleanWorkspaceButtonLabel", "Clean Java Project Workspace Cache", "cleanJavaWorkspaceButtonClickHandler"),
					new MultiOptionSetting(this, 'jdkType', "JDK", 
						Vector.<NameValuePair>([
							new NameValuePair("Use Default JDK", JavaTypes.JAVA_DEFAULT),
							new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
						])
					)
				]),
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