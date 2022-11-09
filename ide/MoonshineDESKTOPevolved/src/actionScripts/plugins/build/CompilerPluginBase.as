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
package actionScripts.plugins.build
{
	import flash.filesystem.File;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.valueObjects.ProjectVO;

	public class CompilerPluginBase extends PluginBase implements IPlugin
	{
		private var invalidPaths:Array;
		
		protected function checkProjectForInvalidPaths(project:ProjectVO):void
		{
			if (project is AS3ProjectVO)
			{
				validateAS3VOPaths(project as AS3ProjectVO);
			}
			else if (project is JavaProjectVO)
			{
				validateJavaVOPaths(project as JavaProjectVO);
			}
			else if (project is HaxeProjectVO)
			{
				validateHaxeVOPaths(project as HaxeProjectVO);
			}
		}
		
		protected function onProjectPathsValidated(paths:Array):void
		{
			
		}
		
		protected function getWindowsCompilerFile(sdk:File, compilerPath:String):File
		{
			var tmpFile:File = sdk.resolvePath(compilerPath +".exe");
			if (tmpFile.exists) return tmpFile;
			
			return sdk.resolvePath(compilerPath +".bat");
		}
		
		private function validateAS3VOPaths(project:AS3ProjectVO):void
		{
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(project.folderLocation, "Location");
			if (project.sourceFolder) checkPathFileLocation(project.sourceFolder, "Source Folder");
			if (project.visualEditorSourceFolder) checkPathFileLocation(project.visualEditorSourceFolder, "Source Folder");
			
			if (project.buildOptions.customSDK)
			{
				checkPathFileLocation(project.buildOptions.customSDK, "Custom SDK");
			}
			
			for each (tmpLocation in project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			for each (tmpLocation in project.resourcePaths)
			{
				checkPathFileLocation(tmpLocation, "Resource");
			}
			for each (tmpLocation in project.externalLibraries)
			{
				checkPathFileLocation(tmpLocation, "External Library");
			}
			for each (tmpLocation in project.libraries)
			{
				checkPathFileLocation(tmpLocation, "Library");
			}
			for each (tmpLocation in project.nativeExtensions)
			{
				checkPathFileLocation(tmpLocation, "Extension");
			}
			for each (tmpLocation in project.runtimeSharedLibraries)
			{
				checkPathFileLocation(tmpLocation, "Shared Library");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
		
		private function validateJavaVOPaths(project:JavaProjectVO):void
		{
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(project.folderLocation, "Location");
			if (project.sourceFolder) checkPathFileLocation(project.sourceFolder, "Source Folder");
			
			for each (tmpLocation in project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
		
		private function validateHaxeVOPaths(project:HaxeProjectVO):void
		{
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(project.folderLocation, "Location");
			if (project.sourceFolder) checkPathFileLocation(project.sourceFolder, "Source Folder");
			
			for each (tmpLocation in project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
		
		private function checkPathString(value:String, type:String):void
		{
			if (!model.fileCore.isPathExists(value))
			{
				invalidPaths.push(type +": "+ value);
			}
		}
		
		private function checkPathFileLocation(value:FileLocation, type:String):void
		{
			if (value.fileBridge.nativePath.indexOf("{locale}") != -1)
			{
				var localePath:String = OSXBookmarkerNotifiers.isValidLocalePath(value);
				if (!localePath || !model.fileCore.isPathExists(localePath))
				{
					storeInvalidPath(localePath);
				}
			}
			else if (!value.fileBridge.exists)
			{
				storeInvalidPath(value.fileBridge.nativePath);
			}
			
			/*
			 * @local
			 */
			function storeInvalidPath(path:String):void
			{
				invalidPaths.push(type +": "+ path);
			}
		}
	}
}