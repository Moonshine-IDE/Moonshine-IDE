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
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.haxe.hxproject.exporter.HaxeExporter;
	import actionScripts.plugin.haxe.hxproject.utils.getHaxeProjectOutputFileExtension;
	import actionScripts.plugin.haxe.hxproject.utils.getHaxeProjectOutputPath;
	import actionScripts.plugin.haxe.hxproject.utils.getHaxeProjectTarget;
	import actionScripts.plugin.settings.vo.ButtonSetting;
	import actionScripts.plugin.settings.vo.DropDownListSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringListSetting;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;

	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	import actionScripts.languageServer.LanguageServerProjectVO;

	public class HaxeProjectVO extends LanguageServerProjectVO
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
		public static const LIME_PLATFORM_NEKO:String = "neko";
		public static const LIME_PLATFORM_HASHLINK:String = "hashlink";

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

		private var webBrowserSettings:DropDownListSetting;
		private var targetPlatformSettings:DropDownListSetting;
		
		public function get outputPath():String
		{
			var fileExtension:String = getHaxeProjectOutputFileExtension(this);
			if(fileExtension == null)
			{
				//if there's no file extension, then the output path is already
				//a folder, and we return it as-is
				return haxeOutput.path.fileBridge.nativePath;
			}
			//otherwise, we return the parent folder
			var tmpPath:String = this.folderLocation.fileBridge.getRelativePath(haxeOutput.path.fileBridge.parent);
			if (!tmpPath) tmpPath = haxeOutput.path.fileBridge.parent.fileBridge.nativePath;
			return tmpPath;
		}

		public function set outputPath(value:String):void
		{
			if (!value || value == "") return;

			//make sure that the path is absolute (if it's already absolute,
			//calling resolvePath() from another folder won't change anything)
			haxeOutput.path = this.folderLocation.fileBridge.resolvePath(value);
			
			//we set this twice because some Haxe projects have a folder, and
			//some have a file name. the first time we set a folder, and then
			//getHaxeProjectOutputPath() populates the file name, if necessary.
			//this keeps the behavior consistent with HaxeDevelop.
			haxeOutput.path = new FileLocation(getHaxeProjectOutputPath(this));
		}
		
		public function get haxePlatform():String
		{
			return haxeOutput.platform;
		}

		public function set haxePlatform(value:String):void
		{
			haxeOutput.platform = value;

			//this will ensure that the correct output path will be saved
			//it could either be a folder or a file with extension specific to
			//the target platform
			haxeOutput.path = new FileLocation(getHaxeProjectOutputPath(this));
		}

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
			var haxeTarget:String = getHaxeProjectTarget(this);
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
					LIME_PLATFORM_NEKO,
					LIME_PLATFORM_HASHLINK
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
		
		private var _runWebBrowser:String;

		public function get runWebBrowser():String
		{
			return _runWebBrowser;
		}

		public function set runWebBrowser(value:String):void
		{
			_runWebBrowser = value;
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
			if (targetPlatformSettings) targetPlatformSettings = null;
			if (webBrowserSettings) webBrowserSettings = null;

			var settings:Vector.<SettingsWrapper>;

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
			if (targetPlatformSettings) targetPlatformSettings.removeEventListener(Event.CHANGE, onTargetPlatformChanged);
		}

		public function openLimeProjectXML():void
		{
			if(!this.isLime)
			{
				throw new IllegalOperationError("Cannot open Lime/OpenFL project.xml for this type of Haxe project");
			}
			var event:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, [this.folderLocation.resolvePath("project.xml")]);
			GlobalEventDispatcher.getInstance().dispatchEvent(event);
		}

		public var openLimeProjectXMLLabel:String = "Open project.xml";

		private function getSettingsForLimeProject():Vector.<SettingsWrapper>
		{
			targetPlatformSettings = new DropDownListSetting(this, "limeTargetPlatform", "Platform", limePlatformTypes);
			targetPlatformSettings.addEventListener(Event.CHANGE, onTargetPlatformChanged, false, 0, true);
			webBrowserSettings = new DropDownListSetting(this, "runWebBrowser", "Web Browser (HTML5 only)", ConstantsCoreVO.TEMPLATES_WEB_BROWSERS, "name");
			webBrowserSettings.isEditable = targetPlatformSettings.stringValue == LIME_PLATFORM_HTML5;
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
							new ButtonSetting(this, "openLimeProjectXMLLabel", "Edit project.xml to customize build options for OpenFL and Lime projects.", "openLimeProjectXML")
                        ])
                ),
                new SettingsWrapper("Output",
                        Vector.<ISetting>([
							targetPlatformSettings
                        ])
				),
                new SettingsWrapper("Run",
                        Vector.<ISetting>([
                            webBrowserSettings
                        ])
				)
            ]);

			return settings;
		}

		private function getSettingsForHaxeProject():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Output",
                        new <ISetting>[
                            new DropDownListSetting(this, "haxePlatform", "Platform", haxePlatformTypes),
							new PathSetting(this, "outputPath", "Output Path", true, outputPath),
                        ]
                ),
                new SettingsWrapper("Build options",
                        new <ISetting>[
                            new StringListSetting(buildOptions, "directives", "Conditional compilation directives", "a-zA-Z0-9\\-=<>()!&|."),
                            new StringSetting(buildOptions, "additional", "Additional compiler options")
                        ]
                ),
                new SettingsWrapper("Paths",
                        new <ISetting>[
                            new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                            new StringListSetting(this, "haxelibs", "Haxelibs", "a-zA-Z0-9"),
                        ]
                )
            ]);

			return settings;
		}

		private function onTargetPlatformChanged(event:Event):void
		{
			if (webBrowserSettings)
			{
				if(isLime)
				{
					webBrowserSettings.isEditable = targetPlatformSettings.stringValue == LIME_PLATFORM_HTML5;
				}
			}
		}
	}
}