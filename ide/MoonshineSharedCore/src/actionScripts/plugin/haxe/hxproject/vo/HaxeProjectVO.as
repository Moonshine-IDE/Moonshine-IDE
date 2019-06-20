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
package actionScripts.plugin.haxe.hxproject.vo
{
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.IntSetting;
	import actionScripts.plugin.settings.vo.ColorSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.StaticLabelSetting;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import mx.collections.ArrayCollection;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.plugin.haxe.hxproject.exporter.HaxeExporter;

	public class HaxeProjectVO extends ProjectVO
	{
		public static const TEST_MOVIE_WEBSERVER:String = "Webserver";
		public static const TEST_MOVIE_CUSTOM:String = "Custom";
		public static const TEST_MOVIE_OPEN_DOCUMENT:String = "OpenDocument";

		public static const PLATFORM_HTML5:String = "html5";
		public static const PLATFORM_WINDOWS:String = "windows";
		public static const PLATFORM_MAC:String = "mac";
		public static const PLATFORM_LINUX:String = "linux";
		public static const PLATFORM_ANDROID:String = "android";
		public static const PLATFORM_IOS:String = "ios";
		public static const PLATFORM_TVOS:String = "tvos";
		public static const PLATFORM_FLASH:String = "flash";
		public static const PLATFORM_AIR:String = "air";

		public var haxeOutput:HaxeOutputVO;
		public var buildOptions:HaxeBuildOptions;
		public var targetPlatform:String;

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var haxelibs:Vector.<String> = new Vector.<String>();
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var showHiddenPaths:Boolean = false;

		public var prebuildCommands:String;
		public var postbuildCommands:String;
		public var postbuildAlways:Boolean;
		public var isLime:Boolean;

		public var testMovie:String = TEST_MOVIE_WEBSERVER;
		public var testMovieCommand:String;
		
		private var additional:StringSetting;
		
		public function get platformTypes():ArrayCollection
		{
			var tmpCollection:ArrayCollection = new ArrayCollection([
					PLATFORM_HTML5,
					PLATFORM_WINDOWS,
					PLATFORM_MAC,
					PLATFORM_LINUX,
					PLATFORM_ANDROID,
					PLATFORM_IOS,
					PLATFORM_TVOS,
					PLATFORM_AIR,
					PLATFORM_FLASH,
				]);
			
			return tmpCollection;
		}

		public function HaxeProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);
			
			haxeOutput = new HaxeOutputVO();
			buildOptions = new HaxeBuildOptions();
			targetPlatform = PLATFORM_HTML5;

            projectReference.hiddenPaths = this.hiddenPaths;
			projectReference.showHiddenPaths = this.showHiddenPaths = model.showHiddenPaths;
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			// TODO more categories / better setting UI
			var settings:Vector.<SettingsWrapper>;
			
			if (additional) additional = null;

			if(isLime)
			{
				settings = getSettingsForLimeProject();
			}
			else
			{
				settings = getSettingsForHaxeProject();
			}
			
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
			HaxeExporter.export(this);
		}

		private function getSettingsForLimeProject():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new StaticLabelSetting("Edit project.xml to customize build options for OpenFL and Lime projects.", 14, 0x686868)
                        ])
                ),
                new SettingsWrapper("Run",
                        Vector.<ISetting>([
                            new DropDownListSetting(this, "targetPlatform", "Platform", platformTypes)
                        ])
                ),
            ]);

			return settings;
		}

		private function getSettingsForHaxeProject():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            additional
                        ])
                )
            ]);

			return settings;
		}
	}
}