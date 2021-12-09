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
package actionScripts.plugin.groovy.grailsproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.GrailsBuildOptions;
	import actionScripts.plugin.groovy.grailsproject.exporter.GrailsExporter;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.languageServer.LanguageServerProjectVO;

	public class GrailsProjectVO extends LanguageServerProjectVO implements IJavaProject
	{
		private static const TARGET_BYTECODE_VALUES:Array = ["1.4", "1.5", "1.6", "1.7", "1.8", "9", "10", "11", "12", "13"];

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var grailsBuildOptions:GrailsBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;

		private var _jdkType:String = JavaTypes.JAVA_8;
		public function get jdkType():String									{	return _jdkType;	}
		public function set jdkType(value:String):void							{	_jdkType = value;	}
		
		public function GrailsProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
			grailsBuildOptions = new GrailsBuildOptions(folder.fileBridge.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Grails Build", Vector.<ISetting>([
					new BuildActionsListSettings(this.grailsBuildOptions, grailsBuildOptions.buildActions, "commandLine", "Grails Build Actions"),
					new BuildActionsListSettings(this.gradleBuildOptions, gradleBuildOptions.buildActions, "commandLine", "Gradle Build Actions")
				])),
				new SettingsWrapper("Java Project", new <ISetting>[
					new MultiOptionSetting(this, 'jdkType', "JDK",
						Vector.<NameValuePair>([
							new NameValuePair("Use Default JDK", JavaTypes.JAVA_DEFAULT),
							new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
						])
					)
				]),
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
			GrailsExporter.export(this);
		}
	}
}