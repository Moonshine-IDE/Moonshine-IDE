////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.locator
{
	import flash.events.InvokeEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFlexDisplayObject;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IAboutBridge;
	import actionScripts.interfaces.IClipboardBridge;
	import actionScripts.interfaces.IContextMenuBridge;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.interfaces.IFlexCoreBridge;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.interfaces.IOSXBookmarkerBridge;
	import actionScripts.interfaces.IProjectBridge;
	import actionScripts.interfaces.IVisualEditorBridge;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.MainView;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.valueObjects.ProjectVO;

	[Bindable] public class IDEModel
	{
		private static var instance:IDEModel;

		public static function getInstance():IDEModel 
		{	
			if (!instance) instance = new IDEModel();
			return instance;
		}
		
		public var fileCore: IFileBridge;
		public var contextMenuCore: IContextMenuBridge;
		public var flexCore: IFlexCoreBridge;
		public var aboutCore: IAboutBridge;
        public var clipboardCore: IClipboardBridge;
		public var visualEditorCore:IVisualEditorBridge;
		public var projectCore:IProjectBridge;
		public var languageServerCore:ILanguageServerBridge;
		public var osxBookmarkerCore:IOSXBookmarkerBridge;
		
		// Currently active editor
		public var activeEditor:IContentWindow;
		
		// Array of current editors
		public var editors:ArrayCollection = new ArrayCollection();
		public var projects:ArrayCollection = new ArrayCollection();
		public var selectedprojectFolders:ArrayCollection = new ArrayCollection();
		public var mainView:MainView;
		
		public var activeProject:ProjectVO;
		public var defaultSDK:FileLocation;
		public var noSDKNotifier:NoSDKNotifier = NoSDKNotifier.getInstance();
		public var sdkInstallerView:IFlexDisplayObject;
		public var antHomePath:FileLocation;
		public var antScriptFile:FileLocation;
		public var mavenPath:String;
		public var gradlePath:String;
		public var grailsPath:String;
		public var haxePath:String;
		public var nekoPath:String;
		public var nodePath:String;
		public var notesPath:String;
		public var javaPathForTypeAhead:FileLocation;
		public var java8Path:FileLocation;
		public var javaVersionInJava8Path:String;
		public var svnPath:String;
		public var gitPath:String;
		public var vagrantPath:String;
		public var virtualBoxPath:String;
		public var macportsPath:String;
		public var isCodeCompletionJavaPresent:Boolean;
		public var payaraServerLocation:FileLocation;

		public var recentlyOpenedFiles:ArrayCollection = new ArrayCollection();
		public var recentlyOpenedProjects:ArrayCollection = new ArrayCollection();
		public var recentlyOpenedProjectOpenedOption:ArrayCollection = new ArrayCollection();
		public var recentSaveProjectPath:ArrayCollection = new ArrayCollection();
		public var lastSelectedProjectPath:String;
		public var userSavedSDKs:ArrayCollection = new ArrayCollection();
		public var userSavedTempSDKPath:String;
		public var individualTabAlertShowingFilePath:String;
		public var isIndividualCloseTabAlertShowing:Boolean;
		public var saveFilesBeforeBuild:Boolean;

		public var openPreviouslyOpenedProjects:Boolean;
		public var openPreviouslyOpenedProjectBranches:Boolean;
		public var openPreviouslyOpenedFiles:Boolean;
		public var confirmApplicationExit:Boolean;
		public var showHiddenPaths:Boolean;
		public var syntaxColorScheme:String;
		public var startupInvokeEvent:InvokeEvent;

		public var version: String = "1.0.0";
		public var build: String = "";

		private var _javaVersionForTypeAhead:String;

		public function get javaVersionForTypeAhead():String
		{
			return _javaVersionForTypeAhead;
		}

		public function set javaVersionForTypeAhead(value:String):void
		{
			_javaVersionForTypeAhead = value;
		}

		public function removeEditor(editor:Object):Boolean
		{
			var index:int = editors.getItemIndex(editor);
			if (index > -1)
			{
				editors.removeItemAt(index);
				return true;
			}
			
			return false;
		}

		public function refreshIdeBuildVersion():void
		{
            build = "";

            var revisionInfoFile: FileLocation = fileCore.resolveApplicationDirectoryPath("elements/appProperties.txt");
            if (revisionInfoFile.fileBridge.exists)
            {
				var buildNumber:String = String(revisionInfoFile.fileBridge.read()).split("\n")[0];
				if (buildNumber && buildNumber.indexOf("bamboo") == -1)
                {
                    build = buildNumber;
                }
            }
		}

		public function getVersionWithBuildNumber():String
		{
			if (build)
			{
				return "Version " + version + ", Build " + build;
			}

			return "Version " + version;
		}
	}
}