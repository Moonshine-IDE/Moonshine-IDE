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
	import mx.utils.StringUtil;

	public class HaxeProjectVO extends ProjectVO
	{
		public static const TEST_MOVIE_WEBSERVER:String = "Webserver";
		public static const TEST_MOVIE_CUSTOM:String = "Custom";
		public static const TEST_MOVIE_OPEN_DOCUMENT:String = "OpenDocument";

		public static const LIME_PLATFORM_HTML5:String = "html5";
		public static const LIME_PLATFORM_WINDOWS:String = "windows";
		public static const LIME_PLATFORM_MAC:String = "mac";
		public static const LIME_PLATFORM_LINUX:String = "linux";
		public static const LIME_PLATFORM_ANDROID:String = "android";
		public static const LIME_PLATFORM_IOS:String = "ios";
		public static const LIME_PLATFORM_TVOS:String = "tvos";
		public static const LIME_PLATFORM_FLASH:String = "flash";
		public static const LIME_PLATFORM_AIR:String = "air";

		public static const HAXE_TARGET_AS3:String = "as3";
		public static const HAXE_TARGET_CPP:String = "cpp";
		public static const HAXE_TARGET_CS:String = "cs";
		public static const HAXE_TARGET_SWF:String = "swf";
		public static const HAXE_TARGET_HL:String = "hl";
		public static const HAXE_TARGET_JAVA:String = "java";
		public static const HAXE_TARGET_JS:String = "js";
		public static const HAXE_TARGET_LUA:String = "lua";
		public static const HAXE_TARGET_NEKO:String = "neko";
		public static const HAXE_TARGET_PHP:String = "php";
		public static const HAXE_TARGET_PYTHON:String = "python";

		private static const OUTPUT_PLATFORM_TO_HAXE_TARGET:Object = {};
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_AIR] = HAXE_TARGET_SWF;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_AIR_MOBILE] = HAXE_TARGET_SWF;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_CPP] = HAXE_TARGET_CPP;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_CSHARP] = HAXE_TARGET_CS;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_FLASH_PLAYER] = HAXE_TARGET_SWF;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_HASHLINK] = HAXE_TARGET_HL;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_JAVASCRIPT] = HAXE_TARGET_JS;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_JAVA] = HAXE_TARGET_JAVA;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_NEKO] = HAXE_TARGET_NEKO;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_PHP] = HAXE_TARGET_PHP;
		OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_PYTHON] = HAXE_TARGET_PYTHON;

		public var haxeOutput:HaxeOutputVO;
		public var buildOptions:HaxeBuildOptions;
		public var limeTargetPlatform:String;

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

		public function getHXML():String
		{
			var result:String = "";
			for each(var fileLocation:FileLocation in classpaths)
			{
				result += "-cp " + fileLocation.fileBridge.nativePath + "\n";
			}
			for each(var haxelib:String in haxelibs)
			{
				result += "-lib " + haxelib + "\n";
			}
			var haxeTarget:String = getHaxeTarget(haxeOutput.platform);
			result += "--" + haxeTarget + " " + haxeOutput.path.fileBridge.nativePath + "\n";
			
			var buildArgs:String = StringUtil.trim(buildOptions.getArguments());
			if(buildArgs.length > 0)
			{
				//split into multiple lines
				buildArgs = buildArgs.replace(/ \-/g, "\n-");
				result += buildArgs + "\n";
			}
			return result;
		}
		
		public function get limePlatformTypes():ArrayCollection
		{
			var tmpCollection:ArrayCollection = new ArrayCollection([
					LIME_PLATFORM_HTML5,
					LIME_PLATFORM_WINDOWS,
					LIME_PLATFORM_MAC,
					LIME_PLATFORM_LINUX,
					LIME_PLATFORM_ANDROID,
					LIME_PLATFORM_IOS,
					LIME_PLATFORM_TVOS,
					LIME_PLATFORM_AIR,
					LIME_PLATFORM_FLASH,
				]);
			
			return tmpCollection;
		}
		
		public function get haxePlatformTypes():ArrayCollection
		{
			var tmpCollection:ArrayCollection = new ArrayCollection([
					HaxeOutputVO.PLATFORM_AIR,
					HaxeOutputVO.PLATFORM_AIR_MOBILE,
					HaxeOutputVO.PLATFORM_CPP,
					HaxeOutputVO.PLATFORM_CSHARP,
					HaxeOutputVO.PLATFORM_FLASH_PLAYER,
					HaxeOutputVO.PLATFORM_HASHLINK,
					HaxeOutputVO.PLATFORM_JAVASCRIPT,
					HaxeOutputVO.PLATFORM_JAVA,
					HaxeOutputVO.PLATFORM_NEKO,
					HaxeOutputVO.PLATFORM_PHP,
					HaxeOutputVO.PLATFORM_PYTHON
				]);
			
			return tmpCollection;
		}

		public function getHaxeTarget(outputPlatform:String):String
		{
			return OUTPUT_PLATFORM_TO_HAXE_TARGET[outputPlatform];
		}

		public function HaxeProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);
			
			haxeOutput = new HaxeOutputVO();
			buildOptions = new HaxeBuildOptions();

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
                            new DropDownListSetting(this, "targetPlatform", "Platform", limePlatformTypes),
                            new StaticLabelSetting("Edit project.xml to customize other build options for OpenFL and Lime projects.", 14, 0x686868)
                        ])
                )
            ]);

			return settings;
		}

		private function getSettingsForHaxeProject():Vector.<SettingsWrapper>
		{
			additional = new StringSetting(buildOptions, "additional", "Additional compiler options");

            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new DropDownListSetting(haxeOutput, "platform", "Platform", haxePlatformTypes),
                            additional
                        ])
                )
            ]);

			return settings;
		}
	}
}