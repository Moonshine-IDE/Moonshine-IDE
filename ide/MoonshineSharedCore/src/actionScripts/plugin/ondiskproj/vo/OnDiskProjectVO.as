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
package actionScripts.plugin.ondiskproj.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.ondiskproj.exporter.OnDiskExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.valueObjects.ProjectVO;

	public class OnDiskProjectVO extends ProjectVO
	{
		public var buildOptions:OnDiskBuildOptions;
		public var mavenBuildOptions:MavenBuildOptions;

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var showHiddenPaths:Boolean = false;

		public var prebuildCommands:String;
		public var postbuildCommands:String;
		public var postbuildAlways:Boolean;
		public var visualEditorExportPath:String;

		public function OnDiskProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);
			
			buildOptions = new OnDiskBuildOptions();
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);

            projectReference.hiddenPaths = this.hiddenPaths;
			projectReference.showHiddenPaths = this.showHiddenPaths = model.showHiddenPaths;
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Paths",
					Vector.<ISetting>([
						new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
						new PathSetting(this, "visualEditorExportPath", "Export Path", true, visualEditorExportPath)
					])
				),
				new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
					new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false),
					new PathSetting(this.mavenBuildOptions, "dominoNotesProgram", "Notes Programe Path", true, this.mavenBuildOptions.dominoNotesProgram, false),
					new PathSetting(this.mavenBuildOptions, "dominoNotesPlatform", "Notes Platform Path", true, this.mavenBuildOptions.dominoNotesPlatform, false)
				]))
			]);
			
			settings.sort(order);
			return settings;
			
			/*
			* @local
			*/
			function order(a:Object, b:Object):Number
			{ 
				if (a.name < b.name) { return -1; } 
				else if (a.name > b.name) { return 1; }
				return 0;
			}
		}
		
		override public function saveSettings():void
		{
			OnDiskExporter.export(this);
		}
	}
}