////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	import mx.controls.HTML;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.ChangeLineEncodingEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.RenameEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StartupHelperEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFlexCoreBridge;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.files.HiddenFilesPlugin;
	import actionScripts.plugin.actionscript.as3project.files.SaveFilesPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsolePlugin;
	import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
	import actionScripts.plugin.core.mouse.MouseManagerPlugin;
	import actionScripts.plugin.errors.UncaughtErrorsPlugin;
	import actionScripts.plugin.findResources.FindResourcesPlugin;
	import actionScripts.plugin.findreplace.FindReplacePlugin;
	import actionScripts.plugin.fullscreen.FullscreenPlugin;
	import actionScripts.plugin.help.HelpPlugin;
	import actionScripts.plugin.organizeImports.OrganizeImportsPlugin;
	import actionScripts.plugin.project.ProjectPlugin;
	import actionScripts.plugin.projectPanel.ProjectPanelPlugin;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.plugin.rename.RenamePlugin;
	import actionScripts.plugin.search.SearchPlugin;
	import actionScripts.plugin.settings.SettingsPlugin;
	import actionScripts.plugin.splashscreen.SplashScreenPlugin;
	import actionScripts.plugin.syntax.AS3SyntaxPlugin;
	import actionScripts.plugin.syntax.CSSSyntaxPlugin;
	import actionScripts.plugin.syntax.GroovySyntaxPlugin;
	import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
	import actionScripts.plugin.syntax.JSSyntaxPlugin;
	import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
	import actionScripts.plugin.syntax.XMLSyntaxPlugin;
	import actionScripts.plugin.templating.TemplatingPlugin;
	import actionScripts.plugins.ant.AntBuildPlugin;
	import actionScripts.plugins.ant.AntBuildScreen;
	import actionScripts.plugins.as3project.exporter.FlashBuilderExporter;
	import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
	import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	import actionScripts.plugins.as3project.mxmlc.MXMLCJavaScriptPlugin;
	import actionScripts.plugins.as3project.mxmlc.MXMLCPlugin;
	import actionScripts.plugins.away3d.Away3DPlugin;
	import actionScripts.plugins.clean.CleanProject;
	import actionScripts.plugins.core.ProjectBridgeImplBase;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.gradle.GradleBuildPlugin;
	import actionScripts.plugins.help.view.TourDeFlexContentsView;
	import actionScripts.plugins.help.view.events.VisualEditorEvent;
	import actionScripts.plugins.maven.MavenBuildPlugin;
	import actionScripts.plugins.nativeFiles.FileAssociationPlugin;
	import actionScripts.plugins.nativeFiles.FilesCopyPlugin;
	import actionScripts.plugins.problems.ProblemsPlugin;
	import actionScripts.plugins.references.ReferencesPlugin;
	import actionScripts.plugins.run.RunJavaProject;
	import actionScripts.plugins.startup.StartupHelperPlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.swflauncher.SWFLauncherPlugin;
	import actionScripts.plugins.symbols.SymbolsPlugin;
	import actionScripts.plugins.ui.editor.TourDeTextEditor;
	import actionScripts.plugins.versionControl.VersionControlPlugin;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.plugins.visualEditor.PreviewPrimeFacesProjectPlugin;
	import actionScripts.plugins.vscodeDebug.VSCodeDebugProtocolPlugin;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.EnvironmentSetupUtils;
	import actionScripts.utils.HelperUtils;
	import actionScripts.utils.SHClassTest;
	import actionScripts.utils.SWFTrustPolicyModifier;
	import actionScripts.utils.SoftwareVersionChecker;
	import actionScripts.utils.Untar;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import components.containers.DownloadNewFlexSDK;
	import components.popup.DefineFolderAccessPopup;
	
	import visualEditor.plugin.ExportToFlexPlugin;
	import visualEditor.plugin.ExportToPrimeFacesPlugin;
	import visualEditor.plugin.VisualEditorRefreshFilesPlugin;

    public class IFlexCoreBridgeImp extends ProjectBridgeImplBase implements IFlexCoreBridge
	{
		//--------------------------------------------------------------------------
		//
		//  INTERFACE METHODS
		//
		//--------------------------------------------------------------------------
		
		public function parseFlashDevelop(project:AS3ProjectVO=null, file:FileLocation=null, projectName:String=null):AS3ProjectVO
		{
			return FlashDevelopImporter.parse(file, projectName);
		}
		
		public function parseFlashBuilder(file:FileLocation):AS3ProjectVO
		{
			return FlashBuilderImporter.parse(file);
		}
		
		public function testFlashDevelop(file:Object):FileLocation
		{
			return FlashDevelopImporter.test(file as File);
		}
		
		public function testFlashBuilder(file:Object):FileLocation
		{
			return FlashBuilderImporter.test(file as File);
		}
		
		public function updateFlashPlayerTrustContent(value:FileLocation):void
		{
			SWFTrustPolicyModifier.updatePolicyFile(value.fileBridge.nativePath);
		}
		
		public function swap(fromIndex:int, toIndex:int,myArray:Array):void
		{
			var temp:* = myArray[toIndex];
			myArray[toIndex] = myArray[fromIndex];
			myArray[fromIndex] = temp;	
		}

		public function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):void
		{
			FlashDevelopExporter.export(project, file);	
		}
		
		public function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):void
		{
			FlashBuilderExporter.export(project, file.fileBridge.getFile as File);
		}
		
		public function getTourDeView():IPanelWindow
		{
			return (new TourDeFlexContentsView);
		}

		public function getTourDeEditor(swfSource:String):BasicTextEditor
		{
			return (new TourDeTextEditor(swfSource));
		}
		
		public function getCorePlugins():Array
		{
			return [
				SettingsPlugin, 
				ProjectPlugin,
				ProjectPanelPlugin,
				TemplatingPlugin,
				HelpPlugin,
				FindReplacePlugin,
				FindResourcesPlugin,
				RecentlyOpenedPlugin,
				ConsolePlugin,
				FullscreenPlugin,
				AntBuildPlugin,
				MavenBuildPlugin,
				GradleBuildPlugin,
				RunJavaProject,
				PreviewPrimeFacesProjectPlugin,
				SearchPlugin,
				MouseManagerPlugin,
				ExportToFlexPlugin,
				ExportToPrimeFacesPlugin,
                VisualEditorRefreshFilesPlugin,
				FileAssociationPlugin,
				FilesCopyPlugin,
				UncaughtErrorsPlugin
			];
		}
		
		public function getDefaultPlugins():Array
		{
			return [
				MXMLCPlugin,
				MXMLCJavaScriptPlugin,
				SWFLauncherPlugin,
				AS3ProjectPlugin,
				AS3SyntaxPlugin,
				CSSSyntaxPlugin,
				GroovySyntaxPlugin,
				JSSyntaxPlugin,
				HTMLSyntaxPlugin,
				MXMLSyntaxPlugin,
				XMLSyntaxPlugin,
				OrganizeImportsPlugin,
				SplashScreenPlugin,
				CleanProject,
				VersionControlPlugin,
				SVNPlugin,
				VSCodeDebugProtocolPlugin,
				SaveFilesPlugin,
				ProblemsPlugin,
				SymbolsPlugin,
				ReferencesPlugin,
				StartupHelperPlugin,
				RenamePlugin,
				Away3DPlugin,
				GitHubPlugin,
				HiddenFilesPlugin
			];
		}
		
		public function getPluginsNotToShowInSettings():Array
		{
			return [FileAssociationPlugin, FilesCopyPlugin, ProjectPanelPlugin, ProjectPlugin, HelpPlugin, FindReplacePlugin, FindResourcesPlugin, RecentlyOpenedPlugin, SWFLauncherPlugin, AS3ProjectPlugin, CleanProject, VSCodeDebugProtocolPlugin,
					MXMLCJavaScriptPlugin, ProblemsPlugin, SymbolsPlugin, ReferencesPlugin, StartupHelperPlugin, RenamePlugin, SearchPlugin, OrganizeImportsPlugin, Away3DPlugin, MouseManagerPlugin, ExportToFlexPlugin, ExportToPrimeFacesPlugin,
					UncaughtErrorsPlugin, HiddenFilesPlugin, RunJavaProject, VisualEditorRefreshFilesPlugin, PreviewPrimeFacesProjectPlugin, VersionControlPlugin];
		}
		
		public function getQuitMenuItem():MenuItem
		{
			return (new MenuItem(ResourceManager.getInstance().getString('resources', 'QUIT'), null, null, MenuPlugin.MENU_QUIT_EVENT, "q", [Keyboard.COMMAND], "f4", [Keyboard.ALTERNATE]));
		}
		
		public function getSettingsMenuItem():MenuItem
		{
			return (new MenuItem(ResourceManager.getInstance().getString('resources', 'SETTINGS'), null, null, SettingsEvent.EVENT_OPEN_SETTINGS, ",", [Keyboard.COMMAND]));
		}
		
		public function getAboutMenuItem():MenuItem
		{
			return (new MenuItem(ResourceManager.getInstance().getString('resources', 'ABOUT'), null, null, MenuPlugin.EVENT_ABOUT));
		}
		
		public function getWindowsMenu():Vector.<MenuItem>
		{
			var resourceManager:IResourceManager = ResourceManager.getInstance();

			var wmn:Vector.<MenuItem> = Vector.<MenuItem>([
				new MenuItem(resourceManager.getString('resources','FILE'), [
					new MenuItem(resourceManager.getString('resources','NEW'),[]),
					new MenuItem(resourceManager.getString('resources','OPEN'), null, null, OpenFileEvent.OPEN_FILE,
						'o', [Keyboard.COMMAND, Keyboard.SHIFT],
						'o', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(resourceManager.getString('resources','OPEN_IMPORT_PROJECT'), null, null, ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT,
						'o', [Keyboard.COMMAND],
						'o', [Keyboard.CONTROL]),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','OPEN_RECENT_PROJECTS'),[]),
					new MenuItem(resourceManager.getString('resources','OPEN_RECENT_FILES'),[]),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','SAVE'), null, null, MenuPlugin.MENU_SAVE_EVENT,
						's', [Keyboard.COMMAND],
						's', [Keyboard.CONTROL]),
					new MenuItem(resourceManager.getString('resources','SAVE_AS'), null, null, MenuPlugin.MENU_SAVE_AS_EVENT,
						's', [Keyboard.COMMAND, Keyboard.SHIFT],
						's', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(resourceManager.getString('resources','CLOSE'), null, null, CloseTabEvent.EVENT_CLOSE_TAB,
						'w', [Keyboard.COMMAND],
						'w', [Keyboard.CONTROL]),
					new MenuItem("Close All", null, null, CloseTabEvent.EVENT_CLOSE_ALL_TABS),
					/*new MenuItem("Define Workspace", null, ProjectEvent.SET_WORKSPACE),*/
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','LINE_ENDINGS'), [
						new MenuItem(resourceManager.getString('resources','WINDOWS_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN),
						new MenuItem(resourceManager.getString('resources','UNIX_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX),
						new MenuItem(resourceManager.getString('resources','OS9_LINE_ENDINGS'), null, null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
					])
				]),
				new MenuItem(resourceManager.getString('resources','EDIT'), [
					new MenuItem(resourceManager.getString('resources','FIND'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS,
								ProjectMenuTypes.JAVA, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.VISUAL_EDITOR_FLEX, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], FindReplacePlugin.EVENT_FIND_NEXT,
						'f', [Keyboard.COMMAND],
						'f', [Keyboard.CONTROL]),
					/*new MenuItem(resourceManager.getString('resources','FINDE_PREV'), null, null, FindReplacePlugin.EVENT_FIND_PREV,
						'f', [Keyboard.COMMAND, Keyboard.SHIFT],
						'f', [Keyboard.CONTROL, Keyboard.SHIFT]),*/
					new MenuItem(resourceManager.getString('resources','FIND_RESOURCES'), null, null, FindResourcesPlugin.EVENT_FIND_RESOURCES,
						'r', [Keyboard.COMMAND, Keyboard.SHIFT],
						'r', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','GO_TO_LINE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], FindReplacePlugin.EVENT_GO_TO_LINE,
						'l', [Keyboard.COMMAND],
						'l', [Keyboard.CONTROL]),
					new MenuItem(resourceManager.getString('resources','GO_TO_DEFINITION'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION),
					new MenuItem(resourceManager.getString('resources','GO_TO_TYPE_DEFINITION'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','RENAME_SYMBOL'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS], RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW),
					new MenuItem(resourceManager.getString('resources', 'ORGANIZE_IMPORTS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS,
						'i', [Keyboard.COMMAND, Keyboard.SHIFT],
						'i', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources', 'DUPLICATE'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.VISUAL_EDITOR_FLEX], VisualEditorEvent.DUPLICATE_ELEMENT,
						'u', [Keyboard.COMMAND], 'u', [Keyboard.CONTROL])
				]),
				new MenuItem(resourceManager.getString('resources','VIEW'), [
					new MenuItem(resourceManager.getString('resources','PROJECT_VIEW'), null, null, ProjectEvent.SHOW_PROJECT_VIEW),
					new MenuItem(resourceManager.getString('resources','FULLSCREEN'), null, null, FullscreenPlugin.EVENT_FULLSCREEN),
					new MenuItem(resourceManager.getString('resources','PROBLEMS_VIEW'), null, null, ProblemsPlugin.EVENT_PROBLEMS),
					new MenuItem(resourceManager.getString('resources','DEBUG_VIEW'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], VSCodeDebugProtocolPlugin.EVENT_SHOW_HIDE_DEBUG_VIEW),
					new MenuItem(resourceManager.getString('resources','HOME'), null, null, SplashScreenPlugin.EVENT_SHOW_SPLASH),
					new MenuItem(null), //separator
					new MenuItem(resourceManager.getString('resources','DOCUMENT_SYMBOLS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], SymbolsPlugin.EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW),
					new MenuItem(resourceManager.getString('resources','WORKSPACE_SYMBOLS'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], SymbolsPlugin.EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW),
					new MenuItem(resourceManager.getString('resources','FIND_REFERENCES'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JAVA, ProjectMenuTypes.GRAILS, ProjectMenuTypes.HAXE], ReferencesPlugin.EVENT_OPEN_FIND_REFERENCES_VIEW, "f7",[Keyboard.COMMAND], "f7", [Keyboard.ALTERNATE])
				]),
				new MenuItem(resourceManager.getString('resources','PROJECT'),[
					new MenuItem(resourceManager.getString('resources','OPEN_IMPORT_PROJECT'), null, null, ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT, 
						'o', [Keyboard.COMMAND],
						'o', [Keyboard.CONTROL]),
					new MenuItem(resourceManager.getString('resources','IMPORT_ARCHIVE_PROJECT'), null, null, ProjectEvent.EVENT_IMPORT_PROJECT_ARCHIVE)
				]),
				new MenuItem(resourceManager.getString('resources','DEBUG'),[
					new MenuItem(resourceManager.getString('resources','BUILD_AND_DEBUG'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_AND_DEBUG,
						"d", [Keyboard.COMMAND],
						"d", [Keyboard.CONTROL]),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','STEP_OVER'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.DEBUG_STEPOVER,
						"e",[Keyboard.COMMAND],
						"f6", []),
					new MenuItem(resourceManager.getString('resources','RESUME'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CONTINUE_EXECUTION,
						"r",[Keyboard.COMMAND],
						"f8", []),
					new MenuItem(resourceManager.getString('resources','STOP'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.TERMINATE_EXECUTION,
						"t",[Keyboard.COMMAND],
						"t", [Keyboard.CONTROL])
				]),
				new MenuItem(resourceManager.getString('resources','SUBVERSION'), [
					new MenuItem((ConstantsCoreVO.IS_MACOS && !UtilsCore.isSVNPresent()) ? "Grant Permission" : resourceManager.getString('resources','MANAGE_REPOSITORIES'), null, null, VersionControlEvent.OPEN_MANAGE_REPOSITORIES),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.COMMIT_REQUEST),
					new MenuItem(resourceManager.getString('resources','UPDATE'), null, [ProjectMenuTypes.SVN_PROJECT], SVNPlugin.UPDATE_REQUEST)
				]),
				new MenuItem(resourceManager.getString('resources','GITHUB'), [
					new MenuItem((ConstantsCoreVO.IS_MACOS && !UtilsCore.isGitPresent()) ? "Grant Permission" : resourceManager.getString('resources','MANAGE_REPOSITORIES'), null, null, VersionControlEvent.OPEN_MANAGE_REPOSITORIES),
					/*new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','CHECKOUT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHECKOUT_REQUEST),*/
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','COMMIT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.COMMIT_REQUEST),
					new MenuItem(resourceManager.getString('resources','PUSH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PUSH_REQUEST),
					new MenuItem(resourceManager.getString('resources','PULL'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.PULL_REQUEST),
					new MenuItem(resourceManager.getString('resources','REVERT'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.REVERT_REQUEST),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources','NEW_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.NEW_BRANCH_REQUEST),
					new MenuItem(resourceManager.getString('resources','SWITCH_BRANCH'), null, [ProjectMenuTypes.GIT_PROJECT], GitHubPlugin.CHANGE_BRANCH_REQUEST)
				]),
				new MenuItem("Others", [
					new MenuItem(resourceManager.getString('resources','BUILD_AWAY3D_MODEL'), null, null, Away3DPlugin.OPEN_AWAY3D_BUILDER),
                    new MenuItem(resourceManager.getString('resources','BUILD_APACHE_ANT'), null, null, AntBuildPlugin.EVENT_ANTBUILD)
				]),
				new MenuItem(resourceManager.getString('resources', 'HELP'), [
					new MenuItem(resourceManager.getString('resources', 'ABOUT'), null, null, MenuPlugin.EVENT_ABOUT),
                    new MenuItem(resourceManager.getString('resources', 'PRIVACY_POLICY'), null, null, HelpPlugin.EVENT_PRIVACY_POLICY),
					new MenuItem(null),
					new MenuItem("Getting Started", null, null, StartupHelperPlugin.EVENT_GETTING_STARTED),
					new MenuItem(resourceManager.getString('resources', 'USEFUL_LINKS'), null, null, HelpPlugin.EVENT_AS3DOCS),
					new MenuItem(resourceManager.getString('resources', 'TOUR_DE_FLEX'), null, null, HelpPlugin.EVENT_TOURDEFLEX),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources', 'RESTORE_DEFAULT_REPOSITORIES'), null, null, VersionControlEvent.RESTORE_DEFAULT_REPOSITORIES)])
			]);
			
			// adding in-projet search for desktop only
			if (ConstantsCoreVO.IS_AIR)
			{
				var projectMenuItems:Vector.<MenuItem> = wmn[3].items;
				projectMenuItems.splice(0, 0, new MenuItem(resourceManager.getString('resources','SEARCH_IN_PROJECTS'), null, null, SearchPlugin.SEARCH_IN_PROJECTS,
					'f', [Keyboard.COMMAND, Keyboard.SHIFT],
					'f', [Keyboard.CONTROL, Keyboard.SHIFT]));
			}
			
			// add a new menuitem after Access Manager
			// in case of osx and if bundled with sdks
			CONFIG::OSX
				{
					var firstMenuItems:Vector.<MenuItem> = wmn[0].items;
					for (var i:int; i < firstMenuItems.length; i++)
					{
						if (firstMenuItems[i].label == "Close All")
						{
							firstMenuItems.splice(i+1, 0, (new MenuItem(null)));
							if (ConstantsCoreVO.IS_APP_STORE_VERSION) firstMenuItems.splice(i+2, 0, (new MenuItem("Access Manager", null, null, ProjectEvent.ACCESS_MANAGER)));
							firstMenuItems.splice(i+3, 0, (new MenuItem(ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT ? "Extract Bundled SDK" : "Moonshine Helper Application", null, null, ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT ? StartupHelperEvent.EVENT_SDK_UNZIP_REQUEST : StartupHelperEvent.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST)));
							break;
						}
					}
				}
				
				return wmn;
		}
		
		public function getHTMLView(url:String):DisplayObject
		{
			var tmpHTML:HTML = new HTML();
			tmpHTML.location = url;
			return tmpHTML;
		}
		
		public function getAccessManagerPopup():IFlexDisplayObject
		{
			return (new DefineFolderAccessPopup);
		}
		
		public function getSDKInstallerView():IFlexDisplayObject
		{
			return (new DownloadNewFlexSDK);
		}
		
		public function getJavaPath(completionHandler:Function):void
		{
			var versionChecker: SoftwareVersionChecker = new SoftwareVersionChecker();
			//versionChecker.getJavaPath(completionHandler);
		}
		
		public function reAdjustApplicationSize(width:Number, height:Number):void
		{
			var tmpStage:Stage = FlexGlobals.topLevelApplication.stage as Stage;
			tmpStage.nativeWindow.width = width;
			tmpStage.nativeWindow.height = height;
			
			tmpStage.nativeWindow.x = (Screen.mainScreen.visibleBounds.width - width)/2;
			tmpStage.nativeWindow.y = (Screen.mainScreen.visibleBounds.height - height)/2;
		}
		
		public function getNewAntBuild():IFlexDisplayObject
		{
			return (new AntBuildScreen());
		}
		
		public function getComponentByType(type:String):Object
		{
			return HelperUtils.getComponentByType(type);
		}
		
		public function isValidExecutableBy(type:String, originPath:String, validationPath:String=null):Boolean
		{
			return HelperUtils.isValidExecutableBy(type, originPath, validationPath);
		}

		public function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void
		{
			var tmpUnzip:Untar = new Untar(fileToUnzip, unzipTo, unzipCompleteFunction, unzipErrorFunction);
		}
		
		public function removeExAttributesTo(path:String):void
		{
			var tmp:SHClassTest = new SHClassTest();
			tmp.removeExAttributesTo(path);
		}
		
		public function get runtimeVersion():String
		{
			return NativeApplication.nativeApplication.runtimeVersion;
		}
		
		public function get version():String
		{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = new Namespace(appDescriptor.namespace());
			var appVersion:String = appDescriptor.ns::versionNumber;
			
			return appVersion;
		}
		
		public function updateToCurrentEnvironmentVariable():void
		{
			EnvironmentSetupUtils.getInstance().updateToCurrentEnvironmentVariable();
		}
		
		public function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDK:String=null, withCommands:Array=null):void
		{
			EnvironmentSetupUtils.getInstance().initCommandGenerationToSetLocalEnvironment(completion, customSDK, withCommands);
		}
	}
}