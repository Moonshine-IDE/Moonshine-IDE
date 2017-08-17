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
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ColorSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.IntSetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	
	public class MXMLProjectVO extends AS3ProjectVO 
	{
		public function MXMLProjectVO(folder:String, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(new FileLocation(folder), projectName, updateToTreeView);
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			// TODO more categories / better setting UI
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Output", 
					Vector.<ISetting>([
						new IntSetting(swfOutput,	"frameRate", 	"Framerate (FPS)"),
						new IntSetting(swfOutput,	"width", 		"Width"),
						new IntSetting(swfOutput,	"height",	 	"Height"),
						new ColorSetting(swfOutput,	"background",	"Background color"),
						new IntSetting(swfOutput,	"swfVersion",	"Minimum player version")
					])
				),
				new SettingsWrapper("Build options",
					Vector.<ISetting>([
						new PathSetting(buildOptions, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
						new PathSetting(buildOptions, "antBuildPath", "Ant Build File", false, buildOptions.antBuildPath, false),
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
						new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
						new PathListSetting(this, "libraries", "Libraries", folderLocation)
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
				/*new SettingsWrapper("Run",
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
				)*/
			]);
			
			return settings;
		}
	}
}