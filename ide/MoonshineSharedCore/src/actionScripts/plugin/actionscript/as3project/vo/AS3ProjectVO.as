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
package actionScripts.plugin.actionscript.as3project.vo
{
	import flash.events.Event;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ColorSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.IntSetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	
	public class AS3ProjectVO extends ProjectVO
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";
		
		public static const TEST_MOVIE_EXTERNAL_PLAYER:String = "ExternalPlayer";
		public static const TEST_MOVIE_CUSTOM:String = "Custom";
		public static const TEST_MOVIE_OPEN_DOCUMENT:String = "OpenDocument";
		public static const TEST_MOVIE_AIR:String = "AIR";
		
		public var fromTemplate:FileLocation;
		public var sourceFolder:FileLocation;
		
		public var swfOutput:SWFOutputVO;
		public var buildOptions:BuildOptions;
		
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var resourcePaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var includeLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var libraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var externalLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var nativeExtensions:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var runtimeSharedLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var intrinsicLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var assetLibrary:XMLList; // TODO Unknown if it works in FD, there just for compatibility purposes (<library/> tag)
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var projectWithExistingSourcePaths:Vector.<FileLocation>;
		public var showHiddenPaths:Boolean = false;
		
		public var prebuildCommands:String;
		public var postbuildCommands:String;
		public var postbuildAlways:Boolean;
		public var FlexJS:Boolean = false;
		public var isMDLFlexJS:Boolean;
		
		public var testMovie:String = TEST_MOVIE_EXTERNAL_PLAYER;
		public var testMovieCommand:String;
		public var defaultBuildTargets:String;
		public var isMobile:Boolean;
		public var isProjectFromExistingSource:Boolean;
		
		public var config:MXMLCConfigVO;
		
		public var flashBuilderProperties:XML;
		public var flashDevelopObjConfig:XML;
		public var isFlashBuilderProject:Boolean;
		public var flashBuilderDOCUMENTSPath:String;
		
		public function get air():Boolean
		{
			if (buildOptions && buildOptions.additional)
			{
				var isBool: Boolean = (buildOptions.additional.indexOf("+configname=air") != -1) || (buildOptions.additional.indexOf("+configname=airmobile") != -1);
				return isBool;
			}
			return false;	
		}
		
		public function set air(v:Boolean):void
		{
			if (v && buildOptions && buildOptions.additional)
			{
				if (buildOptions.additional.length > 0) buildOptions.additional += " ";
				if (!isMobile && (buildOptions.additional.indexOf("+configname=air") == -1)) buildOptions.additional += " +configname=air";
				else if (isMobile && (buildOptions.additional.indexOf("+configname=airmobile") == -1)) buildOptions.additional += " +configname=airmobile";
				this.testMovie = TEST_MOVIE_AIR;
			}
		}
		
		public function get customSDKPath():String
		{
			return buildOptions.customSDKPath;
		}
		
		public function set customSDKPath(value:String):void
		{
			if(buildOptions.customSDKPath === value)
			{
				return;
			}
			buildOptions.customSDKPath = value;
			swfOutput.swfVersion = SWFOutputVO.getSDKSWFVersion(value);
			this.dispatchEvent(new Event(CHANGE_CUSTOM_SDK));
		}
		
		public function get AntBuildPath():String
		{
			return buildOptions.antBuildPath;
		}
		
		public function set AntBuildPath(value:String):void
		{
			buildOptions.antBuildPath = value;
		}
		
		override public function get name():String
		{
			return projectName;
		}
		
		protected var configInvalid:Boolean = true;
		
		
		
		public function AS3ProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);
			
			swfOutput = new SWFOutputVO();
			buildOptions = new BuildOptions();
			
			config = new MXMLCConfigVO();
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			// TODO more categories / better setting UI
			var settings:Vector.<SettingsWrapper>;
			
			if (!isFlashBuilderProject)
			{
				settings = Vector.<SettingsWrapper>([
					
					new SettingsWrapper("Build options",
						Vector.<ISetting>([
							new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
							new PathSetting(this, "AntBuildPath", "Ant Build File", false, buildOptions.antBuildPath, false),
							new StringSetting(buildOptions, "additional", "Additional compiler options"),
							
							new StringSetting(buildOptions, "compilerConstants",				"Compiler constants"),
							
							new BooleanSetting(buildOptions, "accessible",						"Accessible SWF generation"),
							new BooleanSetting(buildOptions, "allowSourcePathOverlap",			"Allow source path overlap"),
							new BooleanSetting(buildOptions, "benchmark",						"Benchmark"),
							new BooleanSetting(buildOptions, "es",								"ECMAScript edition 3 prototype based object model (es)"),
							new BooleanSetting(buildOptions, "optimize",						"Optimize"),
							
							new BooleanSetting(buildOptions, "useNetwork",						"Enable network access"),
							new BooleanSetting(buildOptions, "useResourceBundleMetadata",		"Use resource bundle metadata"),
							new BooleanSetting(buildOptions, "verboseStackTraces",				"Verbose stacktraces"),
							new BooleanSetting(buildOptions, "staticLinkRSL",					"Static link runtime shared libraries"),
							
							new StringSetting(buildOptions, "linkReport",						"Link report XML file"),
							new StringSetting(buildOptions, "loadConfig",						"Load config")
						])
					),
					new SettingsWrapper("Paths",
						Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false),
							new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
							new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
							new PathListSetting(this, "libraries", "Libraries", folderLocation),
							new PathListSetting(this, "nativeExtensions", "Native extensions", folderLocation, true, false)
						])
					),
					new SettingsWrapper("Warnings & Errors",
						Vector.<ISetting>([
							new BooleanSetting(buildOptions, "showActionScriptWarnings",		"Show actionscript warnings"),
							new BooleanSetting(buildOptions, "showBindingWarnings",				"Show binding warnings"),
							new BooleanSetting(buildOptions, "showDeprecationWarnings",			"Show deprecation warnings"),
							new BooleanSetting(buildOptions, "showUnusedTypeSelectorWarnings",	"Show unused type selector warnings"),
							new BooleanSetting(buildOptions, "warnings",						"Show all warnings"),
							new BooleanSetting(buildOptions, "strict",							"Strict error checking"),
						])
					),
					new SettingsWrapper("Run",
						Vector.<ISetting>([
							new MultiOptionSetting(this, 'testMovie', 							"Launch", 
								Vector.<NameValuePair>([
									new NameValuePair("AIR", TEST_MOVIE_AIR),
									new NameValuePair("Custom", TEST_MOVIE_CUSTOM),
									new NameValuePair("Open with default application", TEST_MOVIE_OPEN_DOCUMENT)
								])
							),
							new StringSetting(this, 'testMovieCommand', 						"Custom launch command")
						])
					)
				]);
				
				if (!isMDLFlexJS)
				{
					settings.unshift(new SettingsWrapper("Output", 
						Vector.<ISetting>([
							new IntSetting(swfOutput,	"frameRate", 	"Framerate (FPS)"),
							new IntSetting(swfOutput,	"width", 		"Width"),
							new IntSetting(swfOutput,	"height",	 	"Height"),
							new ColorSetting(swfOutput,	"background",	"Background color"),
							new IntSetting(swfOutput,	"swfVersion",	"Minimum player version")
						])
					));
				}
			}
			else
			{
				settings = Vector.<SettingsWrapper>([
					
					new SettingsWrapper("Build options",
						Vector.<ISetting>([
							new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
							new PathSetting(this, "AntBuildPath", "Ant Build File", false, buildOptions.antBuildPath, false),
							new StringSetting(buildOptions, "additional", "Additional compiler options"),
							
							new StringSetting(buildOptions, "compilerConstants",				"Compiler constants"),
							
							new BooleanSetting(buildOptions, "accessible",						"Accessible SWF generation"),
							new BooleanSetting(buildOptions, "allowSourcePathOverlap",			"Allow source path overlap"),
							new BooleanSetting(buildOptions, "benchmark",						"Benchmark"),
							new BooleanSetting(buildOptions, "es",								"ECMAScript edition 3 prototype based object model (es)"),
							new BooleanSetting(buildOptions, "optimize",						"Optimize"),
							
							new BooleanSetting(buildOptions, "useNetwork",						"Enable network access"),
							new BooleanSetting(buildOptions, "useResourceBundleMetadata",		"Use resource bundle metadata"),
							new BooleanSetting(buildOptions, "verboseStackTraces",				"Verbose stacktraces"),
							new BooleanSetting(buildOptions, "staticLinkRSL",					"Static link runtime shared libraries"),
							
							new StringSetting(buildOptions, "linkReport",						"Link report XML file"),
							new StringSetting(buildOptions, "loadConfig",						"Load config")
						])
					),
					new SettingsWrapper("Paths",
						Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false),
							new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
							new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
							new PathListSetting(this, "libraries", "Libraries", folderLocation)
						])
					),
					new SettingsWrapper("Warnings & Errors",
						Vector.<ISetting>([
							new BooleanSetting(buildOptions, "warnings",						"Show all warnings"),
							new BooleanSetting(buildOptions, "strict",							"Strict error checking"),
						])
					),
					new SettingsWrapper("Run",
						Vector.<ISetting>([
							new MultiOptionSetting(this, 'testMovie', 							"Launch", 
								Vector.<NameValuePair>([
									new NameValuePair("AIR", TEST_MOVIE_AIR),
									new NameValuePair("Custom", TEST_MOVIE_CUSTOM),
									new NameValuePair("Open with default application", TEST_MOVIE_OPEN_DOCUMENT)
								])
							),
							new StringSetting(this, 'testMovieCommand', 						"Custom launch command")
						])
					)
				]);
			}
			
			return settings;
		}
		
		override public function saveSettings():void
		{
			if (ConstantsCoreVO.IS_AIR)
			{
				// @santanu
				// 02/08/2017 (mm/dd/yyyy)
				// since .actionScriptProperties file do not accept any
				// unrelated or unknown tags to be include in it's file
				// and taken as a corrupt file when try to open in Flash Builder,
				// we have no choice to include any extra tags/properties 
				// to the file. 
				// but we do need to save many fields/properties those we
				// have in project's settings screen and .actionScriptProperties
				// file do not have any placeholder for them. 
				// thus from today we shall save project settings only to .as3proj
				// file where we can include custom fields; irrespective of the 
				// project type - flash builder or flash develop.
				// also we shall take .as3proj file if exists to project opening,
				// even there's an .actionScriptProperties file exists
				
				var settingsFile:FileLocation;
				/*if (isFlashBuilderProject)
				{
					settingsFile = folderLocation.resolvePath(".actionScriptProperties");
					// Write settings
					IDEModel.getInstance().flexCore.exportFlashBuilder(this, settingsFile);
				}
				else
				{*/
					settingsFile = folderLocation.resolvePath(projectName+".as3proj");
					// Write settings
					IDEModel.getInstance().flexCore.exportFlashDevelop(this, settingsFile);
				//}
			}
		}
		
		public function updateConfig():void 
		{
			/*if (configInvalid)
			{*/
				config.write(this);
				configInvalid = false;
			//}
		}
	}
}