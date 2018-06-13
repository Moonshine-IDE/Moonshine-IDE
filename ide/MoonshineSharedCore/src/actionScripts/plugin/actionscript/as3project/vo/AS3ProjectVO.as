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
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.controls.LinkButton;
    
    import __AS3__.vec.Vector;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.ICloneable;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
    import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
    import actionScripts.plugin.run.RunMobileSetting;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ColorSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.IntSetting;
    import actionScripts.plugin.settings.vo.ListSetting;
    import actionScripts.plugin.settings.vo.NameValuePair;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;
    import actionScripts.plugin.settings.vo.StringSetting;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.utils.SDKUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.MobileDeviceVO;
    import actionScripts.valueObjects.ProjectVO;
	
	public class AS3ProjectVO extends ProjectVO implements ICloneable
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";
		public static const NATIVE_EXTENSION_MESSAGE:String = "NATIVE_EXTENSION_MESSAGE";
		
		public static const TEST_MOVIE_EXTERNAL_PLAYER:String = "ExternalPlayer";
		public static const TEST_MOVIE_CUSTOM:String = "Custom";
		public static const TEST_MOVIE_OPEN_DOCUMENT:String = "OpenDocument";
		public static const TEST_MOVIE_AIR:String = "AIR";
		
		public static const FLEXJS_DEBUG_PATH:String = "bin/js-debug/index.html";
		public static const FLEXJS_RELEASE_PATH:String = "bin/js-release";
		
		[Bindable] public var isLibraryProject:Boolean;
		
		public var fromTemplate:FileLocation;
		public var sourceFolder:FileLocation;
		public var visualEditorSourceFolder:FileLocation;
		
		public var swfOutput:SWFOutputVO;
		public var buildOptions:BuildOptions;
		public var htmlPath:FileLocation;
		
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var resourcePaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var includeLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var libraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var externalLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var nativeExtensions:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var runtimeSharedLibraries:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var intrinsicLibraries:Vector.<String> = new Vector.<String>();
		public var assetLibrary:XMLList; // TODO Unknown if it works in FD, there just for compatibility purposes (<library/> tag)
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var projectWithExistingSourcePaths:Vector.<FileLocation>;
		public var showHiddenPaths:Boolean = false;
		public var filesList:ArrayCollection; // all acceptable files list those can be opened in Moonshine editor (mainly generates for VisualEditor project)
		
		public var prebuildCommands:String;
		public var postbuildCommands:String;
		public var postbuildAlways:Boolean;
		public var isFlexJS:Boolean;
		public var isMDLFlexJS:Boolean;
		public var isRoyale:Boolean;
		
		public var testMovie:String = TEST_MOVIE_EXTERNAL_PLAYER;
		public var testMovieCommand:String;
		public var defaultBuildTargets:String;

		public var config:MXMLCConfigVO;
		
		public var flashBuilderProperties:XML;
		public var flashDevelopObjConfig:XML;
		public var isFlashBuilderProject:Boolean;
		public var flashBuilderDOCUMENTSPath:String;

        public var isMobile:Boolean;
        public var isProjectFromExistingSource:Boolean;
		public var isVisualEditorProject:Boolean;
		public var isActionScriptOnly:Boolean;
		public var isPrimeFacesVisualEditorProject:Boolean;
		public var isExportedToExistingSource:Boolean;
		public var visualEditorExportPath:String;

		public var menuType:String = ProjectMenuTypes.FLEX_AS;

		private var additional:StringSetting;
		private var htmlFilePath:PathSetting;
		private var outputPathSetting:PathSetting;
		private var nativeExtensionPath:PathListSetting;
		private var mobileRunSettings:RunMobileSetting;
		private var targetPlatformSettings:ListSetting;
		
		public function get air():Boolean
		{
			return UtilsCore.isAIR(this);
		}
		
		public function set air(v:Boolean):void
		{
			this.testMovie = v ? TEST_MOVIE_AIR : "";
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
			swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(value);
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
		
		private var _targetPlatform:String;
		public function set targetPlatform(value:String):void
		{
			_targetPlatform = value;
		}
		public function get targetPlatform():String
		{
			return _targetPlatform;
		}
		
		private var _isMobileRunOnSimulator:Boolean = true;
		public function set isMobileRunOnSimulator(value:Boolean):void
		{
			_isMobileRunOnSimulator = value;
		}
		public function get isMobileRunOnSimulator():Boolean
		{
			return _isMobileRunOnSimulator;
		}
		
		private var _isMobileHasSimulatedDevice:MobileDeviceVO;
		public function set isMobileHasSimulatedDevice(value:MobileDeviceVO):void
		{
			_isMobileHasSimulatedDevice = value;
		}
		public function get isMobileHasSimulatedDevice():MobileDeviceVO
		{
			return _isMobileHasSimulatedDevice;
		}
		
		public function get platformTypes():ArrayCollection
		{
			var tmpCollection:ArrayCollection;
			//additional.isEditable = air;
			htmlFilePath.isEditable = !air && !isLibraryProject;
			nativeExtensionPath.isEditable = air;
			mobileRunSettings.visible = isMobile;
			
			if (!air)
			{
				tmpCollection = new ArrayCollection([
					new NameValuePair("Web", AS3ProjectPlugin.AS3PROJ_AS_WEB)
				]);
			}
			else if (isMobile)
			{
				tmpCollection = new ArrayCollection([
					new NameValuePair("Android", AS3ProjectPlugin.AS3PROJ_AS_ANDROID),
					new NameValuePair("iOS", AS3ProjectPlugin.AS3PROJ_AS_IOS)
				]);
			}
			else
			{
				tmpCollection = new ArrayCollection([
					new NameValuePair("AIR", AS3ProjectPlugin.AS3PROJ_AS_AIR)
				]);
			}
			
			return tmpCollection;
		}
		
		public function get getHTMLPath():String
		{
			if (!air && !isLibraryProject)
			{
				if (htmlPath) return htmlPath.fileBridge.nativePath;
				
				var html:FileLocation = !isFlexJS ? folderLocation.resolvePath("bin-debug/"+ swfOutput.path.fileBridge.name.split(".")[0] +".html") : folderLocation.resolvePath(FLEXJS_DEBUG_PATH);
				htmlPath = html;
				
				return htmlPath.fileBridge.nativePath;
			}
			
			return "";
		}
		public function set getHTMLPath(value:String):void
		{
			if (value) htmlPath = new FileLocation(value);
		}
		
		public function get outputPath():String
		{
			var tmpPath:String = this.folderLocation.fileBridge.getRelativePath(swfOutput.path.fileBridge.parent);
			if (!tmpPath) tmpPath = swfOutput.path.fileBridge.parent.fileBridge.nativePath;
			return tmpPath;
		}
		public function set outputPath(value:String):void
		{
			if (!value || value == "") return;
			
			var fileNameSplit:Array = swfOutput.path.fileBridge.nativePath.split(folderLocation.fileBridge.separator);
			swfOutput.path = new FileLocation(value + folderLocation.fileBridge.separator + fileNameSplit[fileNameSplit.length - 1]);
		}
		
		private function onTargetPlatformChanged(event:Event):void
		{
			if (mobileRunSettings) 
			{
				mobileRunSettings.updateDevices(targetPlatformSettings.stringValue);
				buildOptions.isMobileHasSimulatedDevice = (!targetPlatformSettings.stringValue || targetPlatformSettings.stringValue == "Android") ? ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES[0] : ConstantsCoreVO.TEMPLATES_IOS_DEVICES[0];
			}
		}
		
		public function AS3ProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

			swfOutput = new SWFOutputVO();
			buildOptions = new BuildOptions();
			
			config = new MXMLCConfigVO();

            projectReference.hiddenPaths = this.hiddenPaths;
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			// TODO more categories / better setting UI
			var settings:Vector.<SettingsWrapper>;
			
			if (additional) additional = null;
			if (htmlFilePath) htmlFilePath = null;
			if (outputPathSetting) outputPathSetting = null;
			if (nativeExtensionPath) nativeExtensionPath = null;
			if (mobileRunSettings) mobileRunSettings = null;
			if (targetPlatformSettings) targetPlatformSettings = null;
			
			additional = new StringSetting(buildOptions, "additional", "Additional compiler options");
			htmlFilePath = new PathSetting(this, "getHTMLPath", "URL to Launch", false, getHTMLPath);
			outputPathSetting = new PathSetting(this, "outputPath", "Output Path", true, outputPath);
			nativeExtensionPath = getExtensionsSettings();
			mobileRunSettings = new RunMobileSetting(buildOptions, "Launch Method");
			targetPlatformSettings = new ListSetting(buildOptions, "targetPlatform", "Platform", platformTypes, "name");
			if (isLibraryProject) targetPlatformSettings.isEditable = false;
			else targetPlatformSettings.addEventListener(Event.CHANGE, onTargetPlatformChanged, false, 0, true);

			if (isVisualEditorProject)
			{
				settings = getSettingsForVisualEditorTypeOfProjects();
			}
			else if (!isFlashBuilderProject)
			{
				settings = getSettingsForNonFlashBuilderProject();
			}
			else
			{
				settings = getSettingsForOtherTypeOfProjects();
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
			if (ConstantsCoreVO.IS_AIR)
			{
				// @devsena
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

				/*if (isFlashBuilderProject)
				{
				settingsFile = folderLocation.resolvePath(".actionScriptProperties");
				// Write settings
				IDEModel.getInstance().flexCore.exportFlashBuilder(this, settingsFile);
				}
				else
				{*/

                var projectFileName:String = this.isVisualEditorProject ? projectName+".veditorproj" : projectName+".as3proj";
                var settingsFile:FileLocation = folderLocation.resolvePath(projectFileName);
				// Write settings
				IDEModel.getInstance().flexCore.exportFlashDevelop(this, settingsFile);
				//}
			}
			
			if (targetPlatformSettings) targetPlatformSettings.removeEventListener(Event.CHANGE, onTargetPlatformChanged);
		}
		
		public function updateConfig():void 
		{
			/*if (configInvalid)
			{*/
			config.write(this);
			configInvalid = false;
			//}
		}
		
		private function dispatchNativeExtensionMessageRequest(event:MouseEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE));
		}

		private function getSettingsForNonFlashBuilderProject():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
                            new PathSetting(this, "AntBuildPath", "Ant Build File", false, buildOptions.antBuildPath, false),
                            additional,

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
                            new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                            new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
                            new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
                            new PathListSetting(this, "libraries", "Libraries", folderLocation),
                            nativeExtensionPath
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
                            targetPlatformSettings,
                            htmlFilePath,
							outputPathSetting,
                            additional,
                            mobileRunSettings
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

			return settings;
		}

		private function getSettingsForOtherTypeOfProjects():Vector.<SettingsWrapper>
		{
            return Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
                            new PathSetting(this, "AntBuildPath", "Ant Build File", false, buildOptions.antBuildPath, false),
                            additional,

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
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                            new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
                            new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
                            new PathListSetting(this, "libraries", "Libraries", folderLocation),
							nativeExtensionPath
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
                            new ListSetting(this, "targetPlatform", "Platform", platformTypes, "name"),
                            htmlFilePath,
							outputPathSetting,
                            additional,
                            mobileRunSettings
                        ])
                )
            ]);
		}

		private function getSettingsForVisualEditorTypeOfProjects():Vector.<SettingsWrapper>
		{
            return Vector.<SettingsWrapper>([
					new SettingsWrapper("Paths",
							Vector.<ISetting>([
								new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                                new PathSetting(this, "visualEditorExportPath", "Export Path", true, visualEditorExportPath, false, true)
							])
					)
				]);
		}

		private function getExtensionsSettings():PathListSetting
		{
            var nativeExtensionSettings:PathListSetting = new PathListSetting(this, "nativeExtensions", "Native extensions folder", folderLocation, false, true);
            var tmpLinkLabel:LinkButton = new LinkButton();
            tmpLinkLabel.label = "(See how Moonshine supports native extensions)";
            tmpLinkLabel.setStyle("color", 0x8e3b4e);
            tmpLinkLabel.addEventListener(MouseEvent.CLICK, dispatchNativeExtensionMessageRequest, false, 0, true);
            nativeExtensionSettings.customMessage = tmpLinkLabel;

			return nativeExtensionSettings;
        }

		public function clone():Object
		{
			var as3Project:AS3ProjectVO = new AS3ProjectVO(this.folderLocation, this.projectName, true);

            as3Project.fromTemplate = this.fromTemplate;
            as3Project.sourceFolder = new FileLocation(this.sourceFolder.fileBridge.nativePath);

			if (this.visualEditorSourceFolder)
            {
                as3Project.visualEditorSourceFolder = new FileLocation(this.visualEditorSourceFolder.fileBridge.nativePath);
            }

            as3Project.swfOutput = this.swfOutput;
            as3Project.buildOptions = this.buildOptions;

			if (this.htmlPath)
            {
                as3Project.htmlPath = new FileLocation(this.htmlPath.fileBridge.nativePath);
            }

            as3Project.classpaths = this.classpaths.slice(0, this.classpaths.length);
            as3Project.resourcePaths = this.resourcePaths.slice(0, this.resourcePaths.length);
            as3Project.includeLibraries = this.includeLibraries.slice(0, this.includeLibraries.length);
            as3Project.libraries = this.libraries.slice(0, this.libraries.length);
            as3Project.externalLibraries = this.externalLibraries.slice(0, this.externalLibraries.length);
            as3Project.nativeExtensions = this.nativeExtensions.slice(0, this.nativeExtensions.length);
            as3Project.runtimeSharedLibraries = this.runtimeSharedLibraries.splice(0, this.runtimeSharedLibraries.length);
            as3Project.intrinsicLibraries = this.intrinsicLibraries.slice(0, this.intrinsicLibraries.length);
            as3Project.assetLibrary = this.assetLibrary.copy();
            as3Project.targets = this.targets.slice(0, this.targets.length);
            as3Project.hiddenPaths = this.hiddenPaths.slice(0, this.hiddenPaths.length);

			if (this.projectWithExistingSourcePaths)
            {
                as3Project.projectWithExistingSourcePaths = this.projectWithExistingSourcePaths.slice(0, this.projectWithExistingSourcePaths.length);
            }

			as3Project.showHiddenPaths = this.showHiddenPaths;

            as3Project.prebuildCommands = this.prebuildCommands;
            as3Project.postbuildCommands = this.postbuildCommands;
            as3Project.postbuildAlways = this.postbuildAlways;
            as3Project.isFlexJS = this.isFlexJS;
            as3Project.isMDLFlexJS = this.isMDLFlexJS;
            as3Project.isRoyale = this.isRoyale;

            as3Project.testMovie = this.testMovie;
            as3Project.testMovieCommand = this.testMovieCommand;
            as3Project.defaultBuildTargets = this.defaultBuildTargets;

            as3Project.config = new MXMLCConfigVO(new FileLocation(this.config.file.fileBridge.nativePath));

            as3Project.flashBuilderProperties = this.flashBuilderProperties ? this.flashBuilderProperties.copy() : null;
            as3Project.flashDevelopObjConfig = this.flashDevelopObjConfig ? this.flashDevelopObjConfig.copy() : null;
            as3Project.isFlashBuilderProject = this.isFlashBuilderProject;
            as3Project.flashBuilderDOCUMENTSPath = this.flashBuilderDOCUMENTSPath;

            as3Project.isMobile = this.isMobile;
            as3Project.isProjectFromExistingSource = this.isProjectFromExistingSource;
            as3Project.isVisualEditorProject = this.isVisualEditorProject;
            as3Project.isLibraryProject = this.isLibraryProject;
            as3Project.isActionScriptOnly = this.isActionScriptOnly;
            as3Project.isPrimeFacesVisualEditorProject = this.isPrimeFacesVisualEditorProject;
			as3Project.isExportedToExistingSource = this.isExportedToExistingSource;
			as3Project.visualEditorExportPath = this.visualEditorExportPath;

			as3Project.additional = this.additional;

			if (this.htmlFilePath)
            {
                as3Project.htmlFilePath = new PathSetting(this.htmlFilePath.provider,
                        this.htmlFilePath.name, this.htmlFilePath.label,
                        this.htmlFilePath.directory, this.htmlFilePath.path);
            }

			if (this.outputPathSetting)
            {
                as3Project.outputPathSetting = new PathSetting(this.outputPathSetting.provider,
                        this.outputPathSetting.name, this.outputPathSetting.label,
                        this.outputPathSetting.directory, this.outputPathSetting.path);
            }

			if (this.nativeExtensionPath)
            {
                as3Project.nativeExtensionPath = new PathListSetting(this.nativeExtensionPath.provider,
                        this.nativeExtensionPath.name, this.nativeExtensionPath.label, this.nativeExtensionPath.relativeRoot,
                        this.nativeExtensionPath.allowFiles, this.nativeExtensionPath.allowFolders, this.nativeExtensionPath.fileMustExist,
                        this.nativeExtensionPath.displaySourceFolder);
            }

			if (this.mobileRunSettings && !this.isVisualEditorProject)
            {
                as3Project.mobileRunSettings = new RunMobileSetting(this.mobileRunSettings.provider,
                        this.mobileRunSettings.label, new FileLocation(this.mobileRunSettings.relativeRoot.fileBridge.nativePath));
                as3Project.mobileRunSettings.project = as3Project;
            }

			if (this.targetPlatformSettings)
            {
                as3Project.targetPlatformSettings = new ListSetting(this.targetPlatformSettings.provider,
                        this.targetPlatformSettings.name, this.targetPlatformSettings.label,
                        this.targetPlatformSettings.dataProvider, this.targetPlatformSettings.labelField);
            }

			return as3Project;
		}
	}
}