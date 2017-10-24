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
	import mx.core.IVisualElement;
	
	import actionScripts.events.ChangeLineEncodingEvent;
	import actionScripts.events.NewProjectEvent;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IFlexCoreBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.clean.CleanProject;
	import actionScripts.plugin.actionscript.as3project.save.SaveFilesPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsolePlugin;
	import actionScripts.plugin.core.compiler.CompilerEventBase;
	import actionScripts.plugin.findreplace.FindReplacePlugin;
	import actionScripts.plugin.fullscreen.FullscreenPlugin;
	import actionScripts.plugin.help.HelpPlugin;
	import actionScripts.plugin.project.ProjectPlugin;
	import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
	import actionScripts.plugin.settings.SettingsPlugin;
	import actionScripts.plugin.splashscreen.SplashScreenPlugin;
	import actionScripts.plugin.startup.StartupHelperPlugin;
	import actionScripts.plugin.syntax.AS3SyntaxPlugin;
	import actionScripts.plugin.syntax.CSSSyntaxPlugin;
	import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
	import actionScripts.plugin.syntax.JSSyntaxPlugin;
	import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
	import actionScripts.plugin.syntax.XMLSyntaxPlugin;
	import actionScripts.plugin.templating.TemplatingPlugin;
	import actionScripts.plugins.ant.AntBuildPlugin;
	import actionScripts.plugins.ant.AntBuildScreen;
	import actionScripts.plugins.as3project.CreateProject;
	import actionScripts.plugins.as3project.exporter.FlashBuilderExporter;
	import actionScripts.plugins.as3project.exporter.FlashDevelopExporter;
	import actionScripts.plugins.as3project.importer.FlashBuilderImporter;
	import actionScripts.plugins.as3project.importer.FlashDevelopImporter;
	import actionScripts.plugins.as3project.mxmlc.MXMLCJavaScriptPlugin;
	import actionScripts.plugins.as3project.mxmlc.MXMLCPlugin;
	import actionScripts.plugins.away3d.Away3DPlugin;
	import actionScripts.plugins.fdb.FDBPlugin;
	import actionScripts.plugins.fdb.event.FDBEvent;
	import actionScripts.plugins.help.view.TourDeFlexContentsView;
	import actionScripts.plugins.problems.ProblemsPlugin;
	import actionScripts.plugins.references.ReferencesPlugin;
	import actionScripts.plugins.rename.RenamePlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import actionScripts.plugins.swflauncher.SWFLauncherPlugin;
	import actionScripts.plugins.symbols.SymbolsPlugin;
	import actionScripts.plugins.ui.editor.TourDeTextEditor;
	import actionScripts.plugins.vscodeDebug.VSCodeDebugProtocolPlugin;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SHClassTest;
	import actionScripts.utils.SWFTrustPolicyModifier;
	import actionScripts.utils.SoftwareVersionChecker;
	import actionScripts.utils.TypeAheadProcess;
	import actionScripts.utils.Untar;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	import actionScripts.valueObjects.Settings;
	
	import components.containers.DownloadNewFlexSDK;
	import components.popup.DefineFolderAccessPopup;
	import components.popup.SoftwareInformation;
	
	public class IFlexCoreBridgeImp implements IFlexCoreBridge
	{
		public var newProjectSourcePaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		
		private var model:IDEModel = IDEModel.getInstance();
		private var createProject:CreateProject;
		
		private var _folderPath:String;
		
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
		
		public function createAS3Project(event:NewProjectEvent):void
		{
			createProject = new CreateProject(event);
		}
		
		public function deleteProject(projectWrapper:FileWrapper, finishHandler:Function):void
		{
			try
			{
				projectWrapper.file.fileBridge.deleteDirectory(true);
			} 
			catch (e:Error)
			{
				projectWrapper.file.fileBridge.deleteDirectoryAsync(true);
			}
			
			// when done call the finish handler
			finishHandler(projectWrapper);
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
				TemplatingPlugin,
				HelpPlugin,
				FindReplacePlugin,
				RecentlyOpenedPlugin,
				ConsolePlugin,
				//AntConfigurePlugin,
				FullscreenPlugin,
				AntBuildPlugin,
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
				JSSyntaxPlugin,
				HTMLSyntaxPlugin,
				MXMLSyntaxPlugin,
				XMLSyntaxPlugin,
				SplashScreenPlugin,
				CleanProject,
				SVNPlugin,
				VSCodeDebugProtocolPlugin,
				SaveFilesPlugin,
				ProblemsPlugin,
				SymbolsPlugin,
				ReferencesPlugin,
				StartupHelperPlugin,
				RenamePlugin,
				Away3DPlugin
			];
		}
		
		public function getPluginsNotToShowInSettings():Array
		{
			return [ProjectPlugin, HelpPlugin, FindReplacePlugin, RecentlyOpenedPlugin, SWFLauncherPlugin, AS3ProjectPlugin, CleanProject, VSCodeDebugProtocolPlugin, MXMLCJavaScriptPlugin, ProblemsPlugin, SymbolsPlugin, ReferencesPlugin, StartupHelperPlugin, RenamePlugin];
		}
		
		public function getQuitMenuItem():MenuItem
		{
			return (new MenuItem("Quit", null, MenuPlugin.MENU_QUIT_EVENT, "q", [Keyboard.COMMAND], "f4", [Keyboard.ALTERNATE]));
		}
		
		public function getSettingsMenuItem():MenuItem
		{
			return (new MenuItem("Settings", null, SettingsEvent.EVENT_OPEN_SETTINGS, ",", [Keyboard.COMMAND]));
		}
		
		public function getAboutMenuItem():MenuItem
		{
			return (new MenuItem("About", null, MenuPlugin.EVENT_ABOUT));
		}
		
		public function getWindowsMenu():Vector.<MenuItem>
		{
			var wmn:Vector.<MenuItem> = Vector.<MenuItem>([
				new MenuItem("File", [
					new MenuItem("New",[]),
					new MenuItem("Open", null, OpenFileEvent.OPEN_FILE,
						'o', [Keyboard.COMMAND],
						'o', [Keyboard.CONTROL]),
					new MenuItem(null),
					new MenuItem("Save", null, MenuPlugin.MENU_SAVE_EVENT,
						's', [Keyboard.COMMAND],
						's', [Keyboard.CONTROL]),
					new MenuItem("Save As", null, MenuPlugin.MENU_SAVE_AS_EVENT,
						's', [Keyboard.COMMAND, Keyboard.SHIFT],
						's', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem("Close", null, CloseTabEvent.EVENT_CLOSE_TAB,
						'w', [Keyboard.COMMAND],
						'w', [Keyboard.CONTROL]),
					/*new MenuItem("Define Workspace", null, ProjectEvent.SET_WORKSPACE),*/
					new MenuItem(null),
					new MenuItem("Line Endings", [
						new MenuItem("Windows (CRLF - \\r\\n)", null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_WIN),
						new MenuItem("UNIX (LF - \\n)", null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_UNIX),
						new MenuItem("OS9 (CR - \\r)", null, ChangeLineEncodingEvent.EVENT_CHANGE_TO_OS9)
					])
				]),
				new MenuItem("Edit", [
					new MenuItem("Find", null, FindReplacePlugin.EVENT_FIND_NEXT,
						'f', [Keyboard.COMMAND],
						'f', [Keyboard.CONTROL]),
					new MenuItem("Find previous", null, FindReplacePlugin.EVENT_FIND_PREV,
						'f', [Keyboard.COMMAND, Keyboard.SHIFT],
						'f', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem(null),
					new MenuItem("Find Resource", null, FindReplacePlugin.EVENT_FIND_RESOURCE,
						'r', [Keyboard.COMMAND, Keyboard.SHIFT],
						'r', [Keyboard.CONTROL, Keyboard.SHIFT]),
					new MenuItem('Rename symbol', null, RenamePlugin.EVENT_OPEN_RENAME_VIEW),
				]),
				new MenuItem("View", [
					new MenuItem('Project view', null, ProjectEvent.SHOW_PROJECT_VIEW),
					new MenuItem('Fullscreen', null, FullscreenPlugin.EVENT_FULLSCREEN),
					new MenuItem('Problems view', null, ProblemsPlugin.EVENT_PROBLEMS),
					new MenuItem('Debug view', null, VSCodeDebugProtocolPlugin.EVENT_SHOW_DEBUG_VIEW),
					new MenuItem('Home', null, SplashScreenPlugin.EVENT_SHOW_SPLASH),
					new MenuItem(null), //separator
					new MenuItem('Document symbols', null, SymbolsPlugin.EVENT_OPEN_DOCUMENT_SYMBOLS_VIEW),
					new MenuItem('Workspace symbols', null, SymbolsPlugin.EVENT_OPEN_WORKSPACE_SYMBOLS_VIEW),
					new MenuItem('Find References', null, ReferencesPlugin.EVENT_OPEN_FIND_REFERENCES_VIEW),
				]),
				new MenuItem("Project",[
					new MenuItem('Open/Import Flex Project', null, ProjectEvent.EVENT_IMPORT_FLASHBUILDER_PROJECT),
					new MenuItem(null),
					new MenuItem("Build Project", null, CompilerEventBase.BUILD,
						'b', [Keyboard.COMMAND],
						'b', [Keyboard.CONTROL]),
					new MenuItem("Build & Run", null, CompilerEventBase.BUILD_AND_RUN, 
						"\n", [Keyboard.COMMAND],
						"\n", [Keyboard.CONTROL]),
					new MenuItem("Build as JavaScript", null, CompilerEventBase.BUILD_AS_JAVASCRIPT,
						'j', [Keyboard.COMMAND],
						'j', [Keyboard.CONTROL]),
					new MenuItem("Build & Run as JavaScript",null,CompilerEventBase.BUILD_AND_RUN_JAVASCRIPT),
					new MenuItem("Build Release", null, CompilerEventBase.BUILD_RELEASE),
					new MenuItem("Clean Project", null,  CompilerEventBase.CLEAN_PROJECT),
					new MenuItem("Build with Apache® Ant", null,  AntBuildPlugin.SELECTED_PROJECT_ANTBUILD)
				]),
				new MenuItem("Debug",[
					new MenuItem("Build & Debug", null, CompilerEventBase.BUILD_AND_DEBUG, 
						"d", [Keyboard.COMMAND],
						"d", [Keyboard.CONTROL]),
					new MenuItem(null),
					new MenuItem("Step Over", null, CompilerEventBase.DEBUG_STEPOVER, 
						"e",[Keyboard.COMMAND],
						"f6", []),
					new MenuItem("Resume", null, CompilerEventBase.CONTINUE_EXECUTION,
						"r",[Keyboard.COMMAND],
						"f8", []),
					new MenuItem("Stop", null, CompilerEventBase.TERMINATE_EXECUTION,
						"t",[Keyboard.COMMAND],
						"t", [Keyboard.CONTROL])
				]),
				new MenuItem("Ant", [
					new MenuItem('Build Apache® Ant File', null, AntBuildPlugin.EVENT_ANTBUILD)
					/*	new MenuItem('Configure', null, AntConfigurePlugin.EVENT_ANTCONFIGURE)*/
				]),
				new MenuItem("Subversion", [
					new MenuItem("Checkout", null, SVNPlugin.CHECKOUT_REQUEST)
				]),
				new MenuItem("Others", [
					new MenuItem("Build an Away3D Model", null, Away3DPlugin.OPEN_AWAY3D_BUILDER)
				]),
				new MenuItem("Help", Settings.os == "win"? [ 
					new MenuItem('About', null, MenuPlugin.EVENT_ABOUT),
					new MenuItem('Useful Links', null, HelpPlugin.EVENT_AS3DOCS),
					new MenuItem('Tour De Flex', null, HelpPlugin.EVENT_TOURDEFLEX)]:
					[new MenuItem('Useful Links', null, HelpPlugin.EVENT_AS3DOCS),
						new MenuItem('Tour De Flex', null, HelpPlugin.EVENT_TOURDEFLEX)
					])
			]);
			
			// add a new menuitem after Access Manager
			// in case of osx and if bundled with sdks
			CONFIG::OSX
				{
					var firstMenuItems:Vector.<MenuItem> = wmn[0].items;
					for (var i:int; i < firstMenuItems.length; i++)
					{
						if (firstMenuItems[i].label == "Close")
						{
							firstMenuItems.splice(i+1, 0, (new MenuItem(null)));
							firstMenuItems.splice(i+2, 0, (new MenuItem("Access Manager", null, ProjectEvent.ACCESS_MANAGER)));
							firstMenuItems.splice(i+3, 0, (new MenuItem(ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT ? "Extract Bundled SDK" : "Moonshine Helper Application", null, ConstantsCoreVO.IS_BUNDLED_SDK_PRESENT ? StartupHelperPlugin.EVENT_SDK_UNZIP_REQUEST : StartupHelperPlugin.EVENT_MOONSHINE_HELPER_DOWNLOAD_REQUEST)));
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
		
		public function getSoftwareInformationView():IVisualElement
		{
			return (new SoftwareInformation());
		}
		
		public function getJavaPath(completionHandler:Function):void
		{
			var versionChecker: SoftwareVersionChecker = new SoftwareVersionChecker();
			versionChecker.getJavaPath(completionHandler);
		}
		
		public function startTypeAheadWithJavaPath(path:String):void
		{
			new TypeAheadProcess(path);
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
		
		public function exitApplication():void
		{
			NativeApplication.nativeApplication.exit();
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
	}
}