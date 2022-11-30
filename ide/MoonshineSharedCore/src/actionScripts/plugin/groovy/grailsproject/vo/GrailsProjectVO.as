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
package actionScripts.plugin.groovy.grailsproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IJavaProject;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.GradleBuildOptions;
	import actionScripts.plugin.actionscript.as3project.vo.GrailsBuildOptions;
	import actionScripts.plugin.groovy.grailsproject.exporter.GrailsExporter;
	import actionScripts.plugin.java.javaproject.vo.JavaTypes;
	import actionScripts.plugin.settings.vo.BuildActionsListSettings;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.MultiOptionSetting;
	import actionScripts.plugin.settings.vo.NameValuePair;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
import actionScripts.valueObjects.ProjectVO;
	import actionScripts.languageServer.LanguageServerProjectVO;

	public class GrailsProjectVO extends LanguageServerProjectVO implements IJavaProject
	{
		private static const TARGET_BYTECODE_VALUES:Array = ["1.4", "1.5", "1.6", "1.7", "1.8", "9", "10", "11", "12", "13"];

		public var classpaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var grailsBuildOptions:GrailsBuildOptions;
		public var gradleBuildOptions:GradleBuildOptions;

		private var _jdkType:String = JavaTypes.JAVA_8;
		public function get jdkType():String									{	return _jdkType;	}
		public function set jdkType(value:String):void							{	_jdkType = value;	}
		
		public function GrailsProjectVO(folder:FileLocation, projectName:String = null, updateToTreeView:Boolean = true) 
		{
			super(folder, projectName, updateToTreeView);

            projectReference.hiddenPaths = new <FileLocation>[];
			grailsBuildOptions = new GrailsBuildOptions(folder.fileBridge.nativePath);
			gradleBuildOptions = new GradleBuildOptions(projectFolder.nativePath);
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
				new SettingsWrapper("Grails Build", Vector.<ISetting>([
					new BuildActionsListSettings(this.grailsBuildOptions, grailsBuildOptions.buildActions, "commandLine", "Grails Build Actions"),
					new BuildActionsListSettings(this.gradleBuildOptions, gradleBuildOptions.buildActions, "commandLine", "Gradle Build Actions")
				])),
				new SettingsWrapper("Java Project", new <ISetting>[
					new MultiOptionSetting(this, 'jdkType', "JDK",
						Vector.<NameValuePair>([
							new NameValuePair("Use Default JDK", JavaTypes.JAVA_DEFAULT),
							new NameValuePair("Use JDK 8", JavaTypes.JAVA_8)
						])
					)
				]),
				new SettingsWrapper("Paths",
						Vector.<ISetting>([
							new PathListSetting(this, "classpaths", "Class paths", folderLocation, false, true, true, true)
						])
				)
			]);
			settings.sort(order);
			return settings;
		}

		private function order(a:SettingsWrapper, b:SettingsWrapper):int
		{ 
			if (a.name < b.name) { return -1; } 
			else if (a.name > b.name) { return 1; }
			return 0;
		}

		override public function saveSettings():void
		{
			GrailsExporter.export(this);
		}

		override public function getProjectFilesToDelete():Array
		{
			var filesList:Array = [];
			filesList.unshift(classpaths);
			return filesList;
		}
	}
}