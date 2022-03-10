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
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;

	import flash.events.Event;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayCollection;
    import mx.controls.LinkButton;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.ICloneable;
    import actionScripts.interfaces.IVisualEditorProjectVO;
    import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
    import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
    import actionScripts.plugin.run.RunMobileSetting;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.BuildActionsListSettings;
    import actionScripts.plugin.settings.vo.ColorSetting;
    import actionScripts.plugin.settings.vo.DropDownListSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.IntSetting;
    import actionScripts.plugin.settings.vo.NameValuePair;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;
    import actionScripts.plugin.settings.vo.StringSetting;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.utils.SDKUtils;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.MobileDeviceVO;
    import actionScripts.languageServer.LanguageServerProjectVO;
	
	public class AS3ProjectVO extends LanguageServerProjectVO implements ICloneable, IVisualEditorProjectVO
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";
		public static const NATIVE_EXTENSION_MESSAGE:String = "NATIVE_EXTENSION_MESSAGE";
		
		public static const TEST_MOVIE_EXTERNAL_PLAYER:String = "ExternalPlayer";
		public static const TEST_MOVIE_CUSTOM:String = "Custom";
		public static const TEST_MOVIE_OPEN_DOCUMENT:String = "OpenDocument";
		public static const TEST_MOVIE_AIR:String = "AIR";

		[Bindable] public var isLibraryProject:Boolean;
		
		public var fromTemplate:FileLocation;
		
		public var swfOutput:SWFOutputVO;
		public var buildOptions:BuildOptions;
        public var mavenBuildOptions:MavenBuildOptions;
		public var mavenDominoBuildOptions:MavenDominoBuildOptions;
		public var flashModuleOptions:FlashModuleOptions;
		public var customHTMLPath:String;
		
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
		public var showHiddenPaths:Boolean = false;
		
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
		public var isActionScriptOnly:Boolean;
		//public var isPrimeFacesVisualEditorProject:Boolean;
		//public var isDominoVisualEditorProject:Boolean;
		//public var isPreviewRunning:Boolean;
		public var isExportedToExistingSource:Boolean;
		public var visualEditorExportPath:String;

		private var additional:StringSetting;
		private var htmlFilePath:PathSetting;
		private var customHTMLFilePath:StringSetting;
		private var outputPathSetting:PathSetting;
		private var jsOutputPathSetting:PathSetting;
		private var nativeExtensionPath:PathListSetting;
		private var mobileRunSettings:RunMobileSetting;
		private var webBrowserSettings:DropDownListSetting;
		private var targetPlatformSettings:DropDownListSetting;

        private var _jsOutputPath:String;
		private var _urlToLaunch:String;

		private var _jdkType:String = JavaTypes.JAVA_DEFAULT;
		public function get jdkType():String
		{	return _jdkType;	}
		public function set jdkType(value:String):void
		{	_jdkType = value;	}

		override public function set folderLocation(value:FileLocation):void
		{
			super.folderLocation = value;
			if (flashModuleOptions) flashModuleOptions.projectFolderLocation = value;
		}
		
		override public function set sourceFolder(value:FileLocation):void
		{
			super.sourceFolder = value;
			if (flashModuleOptions) flashModuleOptions.sourceFolderLocation = value;
		}
		
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
			swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion(value);
			this.dispatchEvent(new Event(CHANGE_CUSTOM_SDK));
		}

		public function get antBuildPath():String
		{
			return buildOptions.antBuildPath;
		}
		public function set antBuildPath(value:String):void
		{
			buildOptions.antBuildPath = value;
		}

		public function get isSVN():Boolean
		{
			if (menuType.indexOf(ProjectMenuTypes.SVN_PROJECT) != -1) return true;
			return false;
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
		
		private var _runWebBrowser:String;
		public function set runWebBrowser(value:String):void
		{
			_runWebBrowser = value;
		}
		public function get runWebBrowser():String
		{
			return _runWebBrowser;
		}
		
		private var _isVisualEditorProject:Boolean;
		public function get isVisualEditorProject():Boolean
		{
			return _isVisualEditorProject;
		}
		public function set isVisualEditorProject(value:Boolean):void
		{
			_isVisualEditorProject = value;
		}
		
		private var _isPrimeFacesVisualEditorProject:Boolean;
		public function get isPrimeFacesVisualEditorProject():Boolean
		{
			return _isPrimeFacesVisualEditorProject;
		}
		public function set isPrimeFacesVisualEditorProject(value:Boolean):void
		{
			_isPrimeFacesVisualEditorProject = value;
		}


		private var _isDominoVisualEditorProject:Boolean;
		public function get isDominoVisualEditorProject():Boolean
		{
			return _isDominoVisualEditorProject;
		}
		public function set isDominoVisualEditorProject(value:Boolean):void
		{
			_isDominoVisualEditorProject = value;
		}


		private var _isFlexJSRoyalProject:Boolean;
		public function get isFlexJSRoyalProject():Boolean
		{
			return _isFlexJSRoyalProject;
		}
		public function set isFlexJSRoyalProject(value:Boolean):void
		{
			_isFlexJSRoyalProject = value;
		}
		
		private var _isPreviewRunning:Boolean;
		public function get isPreviewRunning():Boolean
		{
			return _isPreviewRunning;
		}
		public function set isPreviewRunning(value:Boolean):void
		{
			_isPreviewRunning = value;
		}
		
		private var _visualEditorSourceFolder:FileLocation;
		public function get visualEditorSourceFolder():FileLocation
		{
			return _visualEditorSourceFolder;
		}
		public function set visualEditorSourceFolder(value:FileLocation):void
		{
			_visualEditorSourceFolder = value;
		}
		
		private var _filesList:ArrayCollection;
		[Bindable]
		public function get filesList():ArrayCollection
		{
			return _filesList;
		}
		public function set filesList(value:ArrayCollection):void
		{
			_filesList = value;
		}
		
		public function get platformTypes():ArrayCollection
		{
			var tmpCollection:ArrayCollection;
			//additional.isEditable = air;
			htmlFilePath.editable = !air && !isLibraryProject;
			customHTMLFilePath.isEditable = !air && !isLibraryProject;
			nativeExtensionPath.isEditable = air;
			mobileRunSettings.visible = isMobile;
			
			if (isRoyale)
			{
				tmpCollection = new ArrayCollection([
					new NameValuePair("JS", AS3ProjectPlugin.AS3PROJ_JS_WEB),
					new NameValuePair("SWF", AS3ProjectPlugin.AS3PROJ_AS_WEB)
				]);
			}
			else if (!air)
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
		
		public function get urlToLaunch():String
		{
			if (!_urlToLaunch)
			{
				if (!air && !isLibraryProject)
				{
					var html:FileLocation = !isRoyale ?
							folderLocation.fileBridge.resolvePath(folderLocation.fileBridge.separator
									+ "bin-debug" + folderLocation.fileBridge.separator +
									swfOutput.path.fileBridge.name.split(".")[0] + ".html")
							: new FileLocation(getRoyaleDebugPath());

					_urlToLaunch = html.fileBridge.nativePath;
				}
			}

			return _urlToLaunch;
		}

		public function set urlToLaunch(value:String):void
		{
			_urlToLaunch = value;
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

        public function get jsOutputPath():String
        {
            var tmpPath:String = this.folderLocation.fileBridge.getRelativePath(new FileLocation(_jsOutputPath));
            if (tmpPath)
			{
				return tmpPath;
            }

            return _jsOutputPath;
        }

        public function set jsOutputPath(value:String):void
        {
			if (!value) return;

            _jsOutputPath = value;
        }

		public function getRoyaleDebugPath():String
		{
			var indexHtmlPath:String = folderLocation.fileBridge.separator.concat("bin",
					                   folderLocation.fileBridge.separator, "js-debug",
					                   folderLocation.fileBridge.separator, "index.html");
			return jsOutputPath.concat(indexHtmlPath);
		}

		private function onTargetPlatformChanged(event:Event):void
		{
			if (mobileRunSettings) 
			{
				mobileRunSettings.updateDevices(targetPlatformSettings.stringValue);
				buildOptions.isMobileHasSimulatedDevice = (!targetPlatformSettings.stringValue || targetPlatformSettings.stringValue == "Android") ? ConstantsCoreVO.TEMPLATES_ANDROID_DEVICES[0] : ConstantsCoreVO.TEMPLATES_IOS_DEVICES[0];
			}
			if (webBrowserSettings)
			{
				webBrowserSettings.isEditable = targetPlatformSettings.stringValue == "JS";
			}
		}
		
		public function AS3ProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

			swfOutput = new SWFOutputVO();
			buildOptions = new BuildOptions();
            mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
			flashModuleOptions = new FlashModuleOptions(folder, sourceFolder);
			
			config = new MXMLCConfigVO();

            projectReference.hiddenPaths = this.hiddenPaths;
			projectReference.showHiddenPaths = this.showHiddenPaths = model.showHiddenPaths;
			jsOutputPath = projectFolder.nativePath;
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			// TODO more categories / better setting UI
			var settings:Vector.<SettingsWrapper>;
			
			if (additional) additional = null;
			if (htmlFilePath) htmlFilePath = null;
			if (outputPathSetting) outputPathSetting = null;
			if (jsOutputPathSetting) jsOutputPathSetting = null;
			if (nativeExtensionPath) nativeExtensionPath = null;
			if (mobileRunSettings) mobileRunSettings = null;
			if (targetPlatformSettings) targetPlatformSettings = null;
			if (webBrowserSettings) webBrowserSettings = null;
			
			additional = new StringSetting(buildOptions, "additional", "Additional compiler options");
			htmlFilePath = new PathSetting(this, "urlToLaunch", "URL to Launch", false, urlToLaunch);
			customHTMLFilePath = new StringSetting(this, "customHTMLPath", "Custom URL to Launch");
			customHTMLFilePath.setMessage("Leave this blank if you don't override 'URL to Launch'\nIf calling a server, prefix the URL with http:// or https://");
			
			outputPathSetting = new PathSetting(this, "outputPath", "Output Path", true, outputPath);
			nativeExtensionPath = getExtensionsSettings();
			mobileRunSettings = new RunMobileSetting(buildOptions, "Launch Method");
			targetPlatformSettings = new DropDownListSetting(buildOptions, "targetPlatform", "Platform", platformTypes, "name");
			webBrowserSettings = new DropDownListSetting(this, "runWebBrowser", "Web Browser", ConstantsCoreVO.TEMPLATES_WEB_BROWSERS, "name");
			webBrowserSettings.isEditable = targetPlatformSettings.stringValue == "JS";

			if (isRoyale)
			{
				jsOutputPathSetting = new PathSetting(this, "jsOutputPath", "JavaScript Output Path", true, jsOutputPath);
			}

			if (isLibraryProject)
			{
				targetPlatformSettings.isEditable = false;
            }
			else
			{
				targetPlatformSettings.addEventListener(Event.CHANGE, onTargetPlatformChanged, false, 0, true);
            }

			if (isVisualEditorProject)
			{
				if(isDominoVisualEditorProject){
					settings = getSettingsForVisualEditorDominoTypeOfProjects();
				}else{
					settings = getSettingsForVisualEditorTypeOfProjects();
				}
			}
			else if (isRoyale)
			{
				settings = getSettingsForRoyale();
			}
			else if (!isFlashBuilderProject)
			{
				settings = getSettingsForNonFlashBuilderProject();
			}
			else
			{
				settings = getSettingsForOtherTypeOfProjects();
			}
			
			generateSettingsForSVNProject(settings);
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

                var projectFileName:String = this.isVisualEditorProject ? projectName+".veditorproj" : projectName+".as3proj";
                var settingsFile:FileLocation = folderLocation.resolvePath(projectFileName);
				// Write settings
				model.flexCore.exportFlashDevelop(this, settingsFile);
				//}
			}
			
			if (targetPlatformSettings) targetPlatformSettings.removeEventListener(Event.CHANGE, onTargetPlatformChanged);
		}
		
		override public function cancelledSettings():void
		{
			flashModuleOptions.cancelledSettings();
		}
		
		override public function closedSettings():void
		{
			flashModuleOptions.cancelledSettings();
		}
		
		override public function projectFileDelete(fw:FileWrapper):void
		{
			if (flashModuleOptions)
			{
				flashModuleOptions.onRemoveModuleEvent(fw, this);
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
		
		private function dispatchNativeExtensionMessageRequest(event:MouseEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(AS3ProjectVO.NATIVE_EXTENSION_MESSAGE));
		}

		private function getSettingsForRoyale():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

				new SettingsWrapper("Build options",
						Vector.<ISetting>([
							new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
							additional,

							new BooleanSetting(buildOptions, "sourceMap", "Source map"),
							new StringSetting(buildOptions, "compilerConstants", "Compiler constants"),
							new StringSetting(buildOptions, "loadConfig", "Load config")
						])
				),
				new SettingsWrapper("Ant Build", Vector.<ISetting>([
					new PathSetting(this, "antBuildPath", "Ant Build File", false, this.antBuildPath, false)
				])),
				new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
					new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
				])),
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
				)
			]);

			var runSettingsContent:Vector.<ISetting> = Vector.<ISetting>([
				targetPlatformSettings,
				htmlFilePath,
				customHTMLFilePath,
				outputPathSetting,
				webBrowserSettings
			]);

			var runSettings:SettingsWrapper = new SettingsWrapper("Run", runSettingsContent);
			runSettingsContent.insertAt(4, jsOutputPathSetting);

			settings.push(runSettings);

			return settings;
		}

		private function getSettingsForNonFlashBuilderProject():Vector.<SettingsWrapper>
		{
            var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([

                new SettingsWrapper("Build options",
                        Vector.<ISetting>([
                            new PathSetting(this, "customSDKPath", "Custom SDK", true, buildOptions.customSDKPath, true),
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
				new SettingsWrapper("Ant Build", Vector.<ISetting>([
                    new PathSetting(this, "antBuildPath", "Ant Build File", false, this.antBuildPath, false)
                ])),
                new SettingsWrapper("Maven Build", Vector.<ISetting>([
                    new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
                    new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
					new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
                ])),
                new SettingsWrapper("Paths",
                        Vector.<ISetting>([
                            new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                            new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
                            new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
                            new PathListSetting(this, "libraries", "Libraries", folderLocation),
                            nativeExtensionPath
                        ])
                ),
				new SettingsWrapper("Modules",
					flashModuleOptions.getSettings()
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
                )
            ]);

            var runSettingsContent:Vector.<ISetting> = Vector.<ISetting>([
                    targetPlatformSettings,
                    htmlFilePath,
                    customHTMLFilePath,
                    outputPathSetting
            ]);

            var runSettings:SettingsWrapper = new SettingsWrapper("Run", runSettingsContent);
            if (this.isRoyale)
            {
                runSettingsContent.insertAt(4, jsOutputPathSetting);
            }
			else
			{
				runSettingsContent.push(mobileRunSettings);
			}

            settings.push(runSettings);

            if (!isMDLFlexJS)
            {
                settings.unshift(new SettingsWrapper("Output",
                        Vector.<ISetting>([
                            new IntSetting(swfOutput,	"frameRate", 	"Framerate (FPS)"),
                            new IntSetting(swfOutput,	"width", 		"Width"),
                            new IntSetting(swfOutput,	"height",	 	"Height"),
                            new ColorSetting(swfOutput,	"background",	"Background color"),
                            new IntSetting(swfOutput,	"swfVersion",	"Minimum player version"),
							new StringSetting(swfOutput, "swfVersionStrict",	"Strict player version (manual)")
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
                new SettingsWrapper("Ant Build", Vector.<ISetting>([
                    new PathSetting(this, "antBuildPath", "Ant Build File", false, this.antBuildPath, false)
                ])),
                new SettingsWrapper("Maven Build", Vector.<ISetting>([
                    new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
                    new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
                    new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
                ])),
                new SettingsWrapper("Paths",
                        Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                            new PathListSetting(this, "resourcePaths", "Resource folders", folderLocation, false),
                            new PathListSetting(this, "externalLibraries", "External libraries", folderLocation, true, false),
                            new PathListSetting(this, "libraries", "Libraries", folderLocation),
							nativeExtensionPath
                        ])
                ),
				new SettingsWrapper("Modules",
					flashModuleOptions.getSettings()
				),
                new SettingsWrapper("Warnings & Errors",
                        Vector.<ISetting>([
                            new BooleanSetting(buildOptions, "warnings",						"Show all warnings"),
                            new BooleanSetting(buildOptions, "strict",							"Strict error checking"),
                        ])
                ),
                new SettingsWrapper("Run",
                        Vector.<ISetting>([
                            new DropDownListSetting(this, "targetPlatform", "Platform", platformTypes, "name"),
                            htmlFilePath,
                            customHTMLFilePath,
                            outputPathSetting,
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
                                new PathSetting(this, "visualEditorExportPath", "Export Path", true, visualEditorExportPath)
							])
					),
					new SettingsWrapper("Maven Build", Vector.<ISetting>([
						new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
						new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
						new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
					]))
				]);
		}
		
		private function getSettingsForVisualEditorDominoTypeOfProjects():Vector.<SettingsWrapper>
		{
			//1. fix the default to clean and install .
			var setting_new:BuildActionsListSettings=new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions");
			//setting_new.stringValue="clean install";
			
            return Vector.<SettingsWrapper>([
					new SettingsWrapper("Paths",
							Vector.<ISetting>([
								new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
                                new PathSetting(this, "visualEditorExportPath", "Export Path", true, visualEditorExportPath)
							])
					),
					new SettingsWrapper("Java Project", new <ISetting>[
						new MultiOptionSetting(this, 'jdkType', "JDK",
								Vector.<NameValuePair>([
									new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
								])
						)
					]),
					new SettingsWrapper("Maven Build", Vector.<ISetting>([
						new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
						setting_new,	
						new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
					]))
				]);
		}

		private function generateSettingsForSVNProject(value:Vector.<SettingsWrapper>):void
		{
			if (isSVN)
			{
				value.insertAt(value.length - 2, new SettingsWrapper("Subversion",
					Vector.<ISetting>([
						new BooleanSetting(this, "isTrustServerCertificateSVN", "Trust server certificate")
					])
				));
			}
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

			if (this.urlToLaunch)
            {
                as3Project.urlToLaunch = this.urlToLaunch;
            }
			
			as3Project.customHTMLPath = this.customHTMLPath;
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
			as3Project.isDominoVisualEditorProject = this.isDominoVisualEditorProject;
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
                as3Project.targetPlatformSettings = new DropDownListSetting(this.targetPlatformSettings.provider,
                        this.targetPlatformSettings.name, this.targetPlatformSettings.label,
                        this.targetPlatformSettings.dataProvider, this.targetPlatformSettings.labelField);
            }

			return as3Project;
		}
	}
}