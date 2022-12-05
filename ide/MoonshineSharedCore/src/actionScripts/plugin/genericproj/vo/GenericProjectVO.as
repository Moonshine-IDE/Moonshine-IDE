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
package actionScripts.plugin.genericproj.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.genericproj.exporter.GenericProjectExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.plugin.settings.vo.StringSetting;
	import actionScripts.valueObjects.ProjectVO;

	import mx.collections.ArrayCollection;

	public class GenericProjectVO extends ProjectVO
	{
		public var mavenBuildOptions:MavenBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;
		public var isAntFileAvailable:Boolean;
		public var buildOptions:GenericProjectBuildOptions;

		public function get antBuildPath():String
		{
			return buildOptions.antBuildPath;
		}
		public function set antBuildPath(value:String):void
		{
			buildOptions.antBuildPath = value;
		}

		public function GenericProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);

			buildOptions = new GenericProjectBuildOptions();
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
			gradleBuildOptions.commandLine = "clean run";
		}

		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = new Vector.<SettingsWrapper>();

			var pathSetting:StringSetting = new StringSetting(this, 'folderPath', 'Path');
			pathSetting.isEditable = false;

			settings.push(
					new SettingsWrapper(
							"Name & Location",
							Vector.<ISetting>([pathSetting])
					)
			);

			if (buildOptions.antBuildPath || isAntFileAvailable)
			{
				settings.push(
					new SettingsWrapper("Ant Build", Vector.<ISetting>([
						new PathSetting(this, "antBuildPath", "Ant Build File", false, antBuildPath, false)
					]))
				);
			}

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

		override public function saveSettings():void
		{
			GenericProjectExporter.export(this);
		}

		public function hasPom():Boolean
		{
			var pomFile:FileLocation = projectFolder.file.fileBridge.resolvePath("pom.xml");
			return pomFile.fileBridge.exists;
		}

		public function hasGradleBuild():Boolean
		{
			var gradleFile:FileLocation = projectFolder.file.fileBridge.resolvePath("build.gradle");
			return gradleFile.fileBridge.exists;
		}

		public function hasAnt():Boolean
		{
			if (buildOptions.antBuildPath)
					return model.fileCore.isPathExists(buildOptions.antBuildPath);

			var antFiles:ArrayCollection = model.flexCore.searchAntFile(this);
			if (antFiles.length > 0)
			{
				buildOptions.antBuildPath = (antFiles[0] as FileLocation).fileBridge.nativePath;
			}
			return ((antFiles.length > 0) ? true : false);
		}
	}
}
