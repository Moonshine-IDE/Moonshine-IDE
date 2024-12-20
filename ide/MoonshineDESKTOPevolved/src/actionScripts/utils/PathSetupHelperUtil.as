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
package actionScripts.utils
{
	import actionScripts.plugins.haxe.HaxeBuildPlugin;
	import actionScripts.plugins.macports.MacPortsPlugin;
	import actionScripts.plugins.vagrant.VagrantPlugin;

	import flash.filesystem.File;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.providers.Java8SettingsProvider;
	import actionScripts.plugin.settings.providers.JavaSettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.domino.DominoPlugin;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.plugins.svn.SVNPlugin;
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.HelperConstants;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;
	
	import moonshine.events.HelperEvent;

	public class PathSetupHelperUtil
	{
		private static var model:IDEModel = IDEModel.getInstance();
		private static var environmentSetupUtils:EnvironmentSetupUtils = EnvironmentSetupUtils.getInstance();
		private static var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

		public static function getRelativePathAgainstProject(projectPath:Object, sourcePath:Object, forceRelativePath:Boolean=false):String
		{
			if (!projectPath)
			{
				throw Error("Path against project parameters must be non null.");
				return null;
			}
			if (!sourcePath)
				return "";

			var projectPathFile:File;
			var sourcePathFile:File;

			// type checks
			if (projectPath is File) projectPathFile = projectPath as File;
			else if (projectPath is FileLocation) projectPathFile = (projectPath as FileLocation).fileBridge.getFile as File;
			else if (projectPath is String) projectPathFile = new File(projectPath as String);

			if (sourcePath is File) sourcePathFile = sourcePath as File;
			else if (sourcePath is FileLocation) sourcePathFile = (sourcePath as FileLocation).fileBridge.getFile as File;
			else if (sourcePath is String) sourcePathFile = new File(sourcePath as String);

			var projectPathString:String = projectPathFile.nativePath.toLowerCase();
			var sourcePathString:String = sourcePathFile.nativePath.toLowerCase();
			var isDriveDifferenceOnWindows:Boolean;

			// specific drive-check case on Windows
			if (!ConstantsCoreVO.IS_MACOS)
			{
				if (projectPathString.charAt(0) != sourcePathString.charAt(0))
				{
					isDriveDifferenceOnWindows = true;
				}
			}

			// relative path conditions applicable for all platforms
			if (!isDriveDifferenceOnWindows || ConstantsCoreVO.IS_MACOS)
			{
				var sourceRelativePath:String = projectPathFile.getRelativePath(sourcePathFile, true);
				// if only non-null
				if (sourceRelativePath || sourceRelativePath == "")
				{
					if (sourcePathString.indexOf(projectPathString + File.separator) != -1)
					{
						// source path is inside the project directory
						return sourceRelativePath;
					}
					else
					{
						// source path is outside from the project directory
						// - we want to support only one ../ case
						var parentCount:int = sourceRelativePath.match(/(\.\.\/)/g).length;
						if (parentCount == 1)
						{
							return sourceRelativePath;
						}
						else if (parentCount == 0)
						{
							return ".";
						}
					}
				}
			}

			// if above matches not triggers, send absolute path
			return sourcePathFile.nativePath;
		}

		public static function getAbsolutePathAgainstProject(projectPath:Object, sourceRelativePathString:String):String
		{
			if (!projectPath)
			{
				throw Error("Absolute path against project parameters must be non null.");
				return null;
			}
			if (!sourceRelativePathString) 
				return "";

			var projectPathFile:File;
			var sourcePathFile:File;
			var isSourceRelativePathStringIsAbsolutePathString:Boolean;
			try
			{
				sourcePathFile = new File(sourceRelativePathString);
				isSourceRelativePathStringIsAbsolutePathString = true;
			} catch (e:Error){}

			// type checks
			if (projectPath is File) projectPathFile = projectPath as File;
			else if (projectPath is FileLocation) projectPathFile = (projectPath as FileLocation).fileBridge.getFile as File;
			else if (projectPath is String) projectPathFile = new File(projectPath as String);

			var isDottedSyntax:Boolean = (sourceRelativePathString.indexOf("../") != -1);
			var isDottedSyntaxWithSingleDot:Array = sourceRelativePathString.match(/^.\//g);
			if (sourceRelativePathString == ".")
			{
				return projectPathFile.nativePath;
			}
			else if (isDottedSyntax)
			{
				var parentCount:int = sourceRelativePathString.match(/(\.\.\/)/g).length;
				sourceRelativePathString = sourceRelativePathString.replace(/(\.\.\/)/g, "");
				while (parentCount != 0)
				{
					sourcePathFile = (sourcePathFile && sourcePathFile.parent) || projectPathFile.parent;
					parentCount --;
				}
				return sourcePathFile.nativePath + File.separator + sourceRelativePathString;
			}
			else if (isDottedSyntaxWithSingleDot.length > 0)
			{
				sourceRelativePathString = sourceRelativePathString.replace(/^.\//g, File.separator);
				return projectPathFile.nativePath + sourceRelativePathString;
			}

			// in case of full path
			if (isSourceRelativePathStringIsAbsolutePathString) 
				return sourceRelativePathString;
			
			// in case of path that relative to the project
			return (projectPathFile.nativePath + File.separator + sourceRelativePathString);
		}
		
		public static function openSettingsViewFor(type:String):void
		{
			var pluginClass:String;
			switch (type)
			{
				case SDKTypes.FLEX:
				case SDKTypes.FLEX_HARMAN:
				case SDKTypes.ROYALE:
				case SDKTypes.FLEXJS:
				case SDKTypes.FEATHERS:
				case SDKTypes.OPENJAVA:
				case SDKTypes.OPENJAVA8:
					pluginClass = "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin";
					break;
				case ComponentTypes.TYPE_ANT:
					pluginClass = "actionScripts.plugins.ant::AntBuildPlugin";
					break;
				case ComponentTypes.TYPE_GIT:
					pluginClass = GitHubPlugin.NAMESPACE;
					break;
				case ComponentTypes.TYPE_MAVEN:
					pluginClass = "actionScripts.plugins.maven::MavenBuildPlugin";
					break;
				case ComponentTypes.TYPE_GRADLE:
					pluginClass = "actionScripts.plugins.gradle::GradleBuildPlugin";
					break;
				case ComponentTypes.TYPE_GRAILS:
					pluginClass = "actionScripts.plugins.grails::GrailsBuildPlugin";
					break;
				case ComponentTypes.TYPE_SVN:
					pluginClass = SVNPlugin.NAMESPACE;
					break;
				case ComponentTypes.TYPE_NODEJS:
					pluginClass = "actionScripts.plugins.js::JavaScriptPlugin";
					break;
				case ComponentTypes.TYPE_NOTES:
					pluginClass = DominoPlugin.NAMESPACE;
					break;
				case ComponentTypes.TYPE_VAGRANT:
					pluginClass = VagrantPlugin.NAMESPACE;
					break;
				case ComponentTypes.TYPE_MACPORTS:
					pluginClass = MacPortsPlugin.NAMESPACE;
					break;
				case ComponentTypes.TYPE_HAXE:
				case ComponentTypes.TYPE_NEKO:
					pluginClass = HaxeBuildPlugin.NAMESPACE;
					break;
			}
			
			if (pluginClass) GlobalEventDispatcher.getInstance().dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, pluginClass));
		}
		
		public static function updateFieldPath(type:String, path:String):void
		{
			switch (type)
			{
				case SDKTypes.FLEX:
				case SDKTypes.FLEX_HARMAN:
				case SDKTypes.ROYALE:
				case SDKTypes.FLEXJS:
				case SDKTypes.FEATHERS:
					addProgramingSDK(path, type);
					break;
				case SDKTypes.OPENJAVA:
					updateJavaPath(path, !path ? true : false);
					break;
				case SDKTypes.OPENJAVA8:
					updateJava8Path(path, !path ? true : false);
					break;
				case ComponentTypes.TYPE_ANT:
					updateAntPath(path);
					break;
				case ComponentTypes.TYPE_GIT:
					updateGitPath(path);
					break;
				case ComponentTypes.TYPE_MAVEN:
					updateMavenPath(path);
					break;
				case ComponentTypes.TYPE_GRADLE:
					updateGradlePath(path);
					break;
				case ComponentTypes.TYPE_GRAILS:
					updateGrailsPath(path);
					break;
				case ComponentTypes.TYPE_SVN:
					updateSVNPath(path);
					break;
				case ComponentTypes.TYPE_NODEJS:
					updateNodeJsPath(path);
					break;
				case ComponentTypes.TYPE_NOTES:
					updateNotesPath(path);
					break;
				case ComponentTypes.TYPE_VAGRANT:
					updateVagrantPath(path);
					break;
				case ComponentTypes.TYPE_MACPORTS:
					updateMacPortsPath(path);
					break;
				case ComponentTypes.TYPE_HAXE:
					updateHaxePath(path);
					break;
				case ComponentTypes.TYPE_NEKO:
					updateNekoPath(path);
					break;
			}
		}
		
		public static function updateAntPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isAntAvailable())
			{
				model.antHomePath = new FileLocation(path);
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({antHomePath: path}, 'antHomePath', 'Ant Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.ant::AntBuildPlugin", settings));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
		}
		
		public static function updateMavenPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isMavenAvailable())
			{
				model.mavenPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({mavenPath: path}, 'mavenPath', 'Maven Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.maven::MavenBuildPlugin", settings));
			}
		}
		
		public static function updateGradlePath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isGradleAvailable())
			{
				model.gradlePath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({gradlePath: path}, 'gradlePath', 'Gradle Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.gradle::GradleBuildPlugin", settings));
			}
		}
		
		public static function updateGrailsPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isGrailsAvailable())
			{
				model.grailsPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({grailsPath: path}, 'grailsPath', 'Grails Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.grails::GrailsBuildPlugin", settings));
			}
		}
		
		public static function updateNodeJsPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isNodeAvailable())
			{
				model.nodePath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({nodePath: path}, 'nodePath', 'Node.js Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.js::JavaScriptPlugin", settings));
			}
		}
		
		public static function updateJavaPath(path:String, isForceUpdate:Boolean=false):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isJavaForTypeaheadAvailable() || isForceUpdate)
			{
				var javaSettingsProvider:JavaSettingsProvider = new JavaSettingsProvider();
				javaSettingsProvider.currentJavaPath = path;
				
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({currentJavaPath: path}, 'currentJavaPath', 'Java Development Kit Root Path', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin", settings));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
			else
			{
				//checkJavaVersionAndUpdateOnlyIfRequires(path, model.javaVersionForTypeAhead, updateJavaPath);
			}
		}
		
		public static function updateJava8Path(path:String, isForceUpdate:Boolean=false):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!UtilsCore.isJava8Present() || isForceUpdate)
			{
				var javaSettingsProvider:Java8SettingsProvider = new Java8SettingsProvider();
				javaSettingsProvider.currentJava8Path = path;
				
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({currentJava8Path: path}, 'currentJava8Path', 'Java Development Kit 8 Root Path', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin", settings));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
		}
		
		public static function updateSVNPath(path:String, forceUpdate:Boolean=false):void
		{
			if (!UtilsCore.isSVNPresent() || forceUpdate)
			{
				if (path && !ConstantsCoreVO.IS_MACOS && path.indexOf("svn.exe") == -1)
				{
					path += (File.separator +'bin'+ File.separator +'svn.exe');
				}

				model.svnPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({svnBinaryPath: model.svnPath}, 'svnBinaryPath', 'SVN Binary', false)
				]);

				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, SVNPlugin.NAMESPACE, settings));
			}
		}
		
		public static function updateGitPath(path:String, forceUpdate:Boolean=false):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			var isGitPresent:Boolean = UtilsCore.isGitPresent();
			var providedPath:String = path == null ? "" : path;

			if (!isGitPresent)
			{
				if (ConstantsCoreVO.IS_MACOS)
				{
					//dispatcher.dispatchEvent(new HelperEvent(HelperConstants.WARNING, {type: ComponentTypes.TYPE_GIT, message: "Feature available. Click on Configure to allow"}));
				}
				else
				{
					updateMoonshineConfiguration();
				}
			}
			
			if (forceUpdate)
			{
				updateMoonshineConfiguration();
			}
			
			/*
			 * @local
			 */
			function updateMoonshineConfiguration():void
			{
				if (!ConstantsCoreVO.IS_MACOS && (providedPath == null || providedPath.indexOf("git.exe") == -1))
				{
					providedPath += (File.separator +'bin'+ File.separator +'git.exe');
				}
				
				model.gitPath = providedPath;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({gitBinaryPathOSX: model.gitPath}, 'gitBinaryPathOSX', 'Git Path', true)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, GitHubPlugin.NAMESPACE, settings));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
		}
		
		public static function updateNotesPath(path:String, forceUpdate:Boolean=false):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			var isNotesDominoAvailable:Boolean = UtilsCore.isNotesDominoAvailable(); 
			if (!isNotesDominoAvailable)
			{
				if (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION && 
					!isNotesDominoAvailable)
				{
					dispatcher.dispatchEvent(new HelperEvent(HelperConstants.WARNING, 
						{type: ComponentTypes.TYPE_NOTES, message: "Feature available. Click on Configure to allow permission."}
					));
				}
				else
				{
					updateMoonshineConfiguration();
				}
			}
			
			if (forceUpdate)
			{
				updateMoonshineConfiguration();
			}
			
			/*
			 * @local
			 */
			function updateMoonshineConfiguration():void
			{
				model.notesPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({notesPath: model.notesPath}, 'notesPath', 'HCL Notes Installation', false)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, DominoPlugin.NAMESPACE, settings));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
		}

		public static function updateVagrantPath(path:String, forceUpdate:Boolean=false):void
		{
			if (!UtilsCore.isVagrantAvailable() || forceUpdate)
			{
				model.vagrantPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({vagrantPath: model.vagrantPath}, 'vagrantPath', 'Vagrant Home', true)
				]);

				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, VagrantPlugin.NAMESPACE, settings));
			}
		}

		public static function updateMacPortsPath(path:String, forceUpdate:Boolean=false):void
		{
			if (!UtilsCore.isMacPortsAvailable() || forceUpdate)
			{
				model.macportsPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({macportsPath: model.macportsPath}, 'macportsPath', 'MacPorts Home', true)
				]);

				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, MacPortsPlugin.NAMESPACE, settings));
			}
		}

		public static function updateHaxePath(path:String, forceUpdate:Boolean=false):void
		{
			if (!UtilsCore.isHaxeAvailable() || forceUpdate)
			{
				model.haxePath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({haxePath: model.haxePath}, 'haxePath', 'Haxe Home', true),
					new PathSetting({nekoPath: model.nekoPath}, 'nekoPath', 'Neko Home', true)
				]);

				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, HaxeBuildPlugin.NAMESPACE, settings));
			}
		}

		public static function updateNekoPath(path:String, forceUpdate:Boolean=false):void
		{
			if (!UtilsCore.isNekoAvailable() || forceUpdate)
			{
				model.nekoPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({haxePath: model.haxePath}, 'haxePath', 'Haxe Home', true),
					new PathSetting({nekoPath: model.nekoPath}, 'nekoPath', 'Neko Home', true)
				]);

				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, HaxeBuildPlugin.NAMESPACE, settings));
			}
		}
		
		public static function updateXCodePath(path:String):void
		{
			var settings:Vector.<ISetting> = Vector.<ISetting>([
				new PathSetting({xcodePath: path}, 'xcodePath', 'Xocde-CommandLine', true)
			]);
			
			// save as moonshine settings
			dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
				null, "actionScripts.plugins.versionControl::VersionControlPlugin", settings));
		}
		
		public static function addProgramingSDK(path:String, type:String=null):void
		{
			var sdkPath:FileLocation = new FileLocation(path);
			if (!sdkPath.fileBridge.exists) return;
			
			var tmpSDK:SDKReferenceVO = SDKUtils.getSDKReference(sdkPath, type);
			if (!tmpSDK) return;
			tmpSDK.status = SDKUtils.BUNDLED;
			SDKUtils.isSDKAlreadySaved(tmpSDK);
			
			// if only not already set
			if (!model.defaultSDK || !model.defaultSDK.fileBridge.exists)
			{
				model.defaultSDK = sdkPath;
				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, tmpSDK));
				
				// update local env.variable
				environmentSetupUtils.updateToCurrentEnvironmentVariable();
			}
		}
		
		private static function checkJavaVersionAndUpdateOnlyIfRequires(path:String, currentVersion:String, updateFn:Function):void
		{
			if (!FileUtils.isPathExists(path) || !currentVersion) 
				return;
			
			var javaVersionReader:JavaVersionReader = new JavaVersionReader();
			javaVersionReader.readVersion(path, onJavaVersionReadCompletes);
			
			function onJavaVersionReadCompletes(value:String):void
			{
				if (HelperUtils.isNewUpdateVersion(currentVersion, value) == 1)
				{
					updateFn(path, true);
				}
			}
		}
	}
}