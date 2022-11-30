////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin.java.javaproject.vo
{
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.java.javaproject.exporter.JavaExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ButtonSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MainClassSetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
import actionScripts.valueObjects.ProjectVO;
	import actionScripts.languageServer.LanguageServerProjectVO;

	public class JavaProjectVO extends LanguageServerProjectVO implements IJavaProject
	{
		public static const CHANGE_CUSTOM_SDK:String = "CHANGE_CUSTOM_SDK";

		public var mavenBuildOptions:MavenBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;
		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		
		private var _jdkType:String = JavaTypes.JAVA_DEFAULT;
		public function get jdkType():String									{	return _jdkType;	}
		public function set jdkType(value:String):void							{	_jdkType = value;	}

		private var _projectType:String;
		public function get projectType():String									{	return _projectType;	}
		public function set projectType(value:String):void							{	_projectType = value;	}

		private var _mainClassName:String;
		private var _mainClassPath:String;

		public function JavaProjectVO(folder:FileLocation, projectName:String=null, updateToTreeView:Boolean=true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths.splice(0, projectReference.hiddenPaths.length);
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
		}

		public function get mainClassName():String
		{
			return _mainClassName;
		}

		public function set mainClassName(value:String):void
		{
			_mainClassName = value;
		}

		public function get mainClassPath():String
		{
			return _mainClassPath;
		}

		public function set mainClassPath(value:String):void
		{
			_mainClassPath = value;
		}

		public function hasPom():Boolean
		{
			var pomFile:FileLocation = new FileLocation(mavenBuildOptions.buildPath).resolvePath("pom.xml");
			return pomFile.fileBridge.exists;
		}

		public function hasGradleBuild():Boolean
		{
			var gradleFile:FileLocation = projectFolder.file.fileBridge.resolvePath("build.gradle");
			return gradleFile.fileBridge.exists;
		}

		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = getJavaSettings();
			settings.sort((function order(a:Object, b:Object):Number
			{
				if (a.name < b.name) { return -1; }
				else if (a.name > b.name) { return 1; }
				return 0;
			}));

			return settings;
		}

		override public function saveSettings():void
		{
			JavaExporter.export(this);
		}

		override public function get customSDKs():EnvironmentUtilsCusomSDKsVO
		{
			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
			if (jdkType == JavaTypes.JAVA_8)
			{
				envCustomJava.jdkPath = model.java8Path ? model.java8Path.fileBridge.nativePath : null;
			}
			else
			{
				envCustomJava.jdkPath = model.javaPathForTypeAhead ? model.javaPathForTypeAhead.fileBridge.nativePath : null;
			}

			return envCustomJava;
		}

		public var cleanWorkspaceButtonLabel:String = "Clean";

		public function cleanJavaWorkspaceButtonClickHandler():void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
				new ExecuteLanguageServerCommandEvent(ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
				this, "java.clean.workspace"));
		}

		override public function getProjectFilesToDelete():Array
		{
			var filesList:Array = [];
			filesList.unshift(folderLocation.fileBridge.resolvePath("src"), folderLocation.fileBridge.resolvePath("bin"), 
				folderLocation.fileBridge.resolvePath("pom.xml"), folderLocation.fileBridge.resolvePath("build.gradle"), 
				folderLocation.fileBridge.resolvePath(".gradle"), folderLocation.fileBridge.resolvePath(".settings"),
				folderLocation.fileBridge.resolvePath(".classpath"), folderLocation.fileBridge.resolvePath(".project"),
				folderLocation.fileBridge.resolvePath(name +".javaproj"), 
				folderLocation.fileBridge.resolvePath("target"), folderLocation.fileBridge.resolvePath("build"));
			filesList.concat(projectFolder.projectReference.hiddenPaths);
			return filesList;
		}

		private function getJavaSettings():Vector.<SettingsWrapper>
		{
			var pathsSettings:Vector.<ISetting> = new Vector.<ISetting>();
			pathsSettings.push(new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true));

			if (!hasGradleBuild())
			{
				var defaultMainClassPath:String = this._mainClassPath;
				if (!_mainClassPath)
				{
					defaultMainClassPath = this.folderLocation.fileBridge.nativePath;
				}

				pathsSettings.push(new MainClassSetting(this, "mainClassName", "Main class", this.mainClassName, defaultMainClassPath));
			}
			
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Java Project", new <ISetting>[
					new ButtonSetting(this, "cleanWorkspaceButtonLabel", "Clean Java Project Workspace Cache", "cleanJavaWorkspaceButtonClickHandler"),
					new MultiOptionSetting(this, 'jdkType', "JDK", 
						Vector.<NameValuePair>([
							new NameValuePair("Use Default JDK", JavaTypes.JAVA_DEFAULT),
							new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
						])
					)
				]),
				new SettingsWrapper("Paths", pathsSettings)
			]);

			if (hasPom())
			{
				settings.push(new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions")
				])));
			}
			
			if (hasGradleBuild())
			{
				settings.push(new SettingsWrapper("Gradle Build", Vector.<ISetting>([
					new BuildActionsListSettings(this.gradleBuildOptions, gradleBuildOptions.buildActions, "commandLine", "Build Actions")
				])));
			}

			return settings;
		}
	}
}