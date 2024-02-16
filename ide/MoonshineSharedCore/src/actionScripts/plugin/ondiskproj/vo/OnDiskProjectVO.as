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
package actionScripts.plugin.ondiskproj.vo
{
	import actionScripts.interfaces.IDeployDominoDatabaseProject;
	import actionScripts.plugin.settings.vo.StringSetting;
import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;

import mx.collections.ArrayCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugin.ondiskproj.exporter.OnDiskExporter;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.IClasspathProject;

	public class OnDiskProjectVO extends ProjectVO implements IVisualEditorProjectVO, IJavaProject, IDeployDominoDatabaseProject, IClasspathProject
	{
		public static const DOMINO_EXPORT_PATH:String = "nsfs/nsf-moonshine";
		
		public var buildOptions:OnDiskBuildOptions;
		public var mavenBuildOptions:MavenBuildOptions;

		private var _classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public function get classpaths():Vector.<FileLocation>
		{
			return _classpaths;
		}
		public function set classpaths(value:Vector.<FileLocation>):void
		{
			_classpaths = value;
		}
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var targets:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var showHiddenPaths:Boolean = false;

		public var prebuildCommands:String;
		public var postbuildCommands:String;
		public var postbuildAlways:Boolean;
		public var visualEditorExportPath:String;
		
		private var _isVisualEditorProject:Boolean;
		public function get isVisualEditorProject():Boolean						{	return _isVisualEditorProject;	}
		public function set isVisualEditorProject(value:Boolean):void			{	_isVisualEditorProject = value;	}
		
		private var _isPrimeFacesVisualEditorProject:Boolean;
		public function get isPrimeFacesVisualEditorProject():Boolean			{	return _isPrimeFacesVisualEditorProject;	}
		public function set isPrimeFacesVisualEditorProject(value:Boolean):void	{	_isPrimeFacesVisualEditorProject = value;	}

		private var _isDominoVisualEditorProject:Boolean;
		public function get isDominoVisualEditorProject():Boolean			{	return _isDominoVisualEditorProject;	}
		public function set isDominoVisualEditorProject(value:Boolean):void	{	_isDominoVisualEditorProject = value;	}
		
		private var _isPreviewRunning:Boolean;
		public function get isPreviewRunning():Boolean							{	return _isPreviewRunning;	}
		public function set isPreviewRunning(value:Boolean):void				{	_isPreviewRunning = value;	}
		
		private var _visualEditorSourceFolder:FileLocation;
		public function get visualEditorSourceFolder():FileLocation				{	return _visualEditorSourceFolder;	}
		public function set visualEditorSourceFolder(value:FileLocation):void	{	_visualEditorSourceFolder = value;	}
		
		private var _filesList:ArrayCollection;
		[Bindable] public function get filesList():ArrayCollection				{	return _filesList;	}
		public function set filesList(value:ArrayCollection):void				{	_filesList = value;	}
		
		private var _jdkType:String = JavaTypes.JAVA_8;
		public function get jdkType():String									{	return _jdkType;	}
		public function set jdkType(value:String):void							{	_jdkType = value;	}

		private var _dominoBaseAgentURL:String = "/%CleanProjectName%.nsf";
		public function get dominoBaseAgentURL():String							{	return _dominoBaseAgentURL;	}
		public function set dominoBaseAgentURL(value:String):void				{	_dominoBaseAgentURL = value;}

		private var _localDatabase:String = "%ProjectPath%/nsfs/nsf-moonshine/target/nsf-moonshine-domino-1.0.0.nsf";
		public function get localDatabase():String								{	return _localDatabase;	}
		public function set localDatabase(value:String):void					{	_localDatabase = value;	}

		private var _targetServer:String = "demo/DEMO";
		public function get targetServer():String								{	return _targetServer;	}
		public function set targetServer(value:String):void						{	_targetServer = value;	}

		private var _targetDatabase:String = "%CleanProjectName%.nsf";
		public function get targetDatabase():String								{	return _targetDatabase;	}
		public function set targetDatabase(value:String):void					{	_targetDatabase = value;	}

		public function OnDiskProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true)
		{
			super(folder, projectName, updateToTreeView);
			
			buildOptions = new OnDiskBuildOptions();
			mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);

            projectReference.hiddenPaths = this.hiddenPaths;
			projectReference.showHiddenPaths = this.showHiddenPaths = model.showHiddenPaths;
		}

		override public function get customSDKs():EnvironmentUtilsCusomSDKsVO
		{
			var envCustomJava:EnvironmentUtilsCusomSDKsVO = new EnvironmentUtilsCusomSDKsVO();
			envCustomJava.jdkPath = model.java8Path ? model.java8Path.fileBridge.nativePath : null;

			return envCustomJava;
		}
		
		override public function getSettings():Vector.<SettingsWrapper>
		{
			var settings:Vector.<SettingsWrapper> = Vector.<SettingsWrapper>([
				new SettingsWrapper("Paths",
					Vector.<ISetting>([
						new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true),
						new PathSetting(this, "visualEditorExportPath", "Export Path", true, visualEditorExportPath)
					])
				),
				new SettingsWrapper("Domino", new <ISetting>[
					new StringSetting(this, "localDatabase", "Local Database"),
					new StringSetting(this, "targetServer", "Target Server"),
					new StringSetting(this, "targetDatabase", "Target Database"),
					new StringSetting(this, "dominoBaseAgentURL", "Base Agent URL")
				]),
				new SettingsWrapper("Maven Build", Vector.<ISetting>([
					new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, "buildPath", "Maven Build File", this.mavenBuildOptions.buildPath),
					new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, "commandLine", "Build Actions"),
					new PathSetting(this.mavenBuildOptions, "settingsFilePath", "Maven Settings File", false, this.mavenBuildOptions.settingsFilePath, false)
				])),
				new SettingsWrapper("Java Project", new <ISetting>[
					new MultiOptionSetting(this, 'jdkType', "JDK", 
						Vector.<NameValuePair>([
							new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
						])
					)
				])
			]);
			
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
			OnDiskExporter.export(this);
		}
	}
}