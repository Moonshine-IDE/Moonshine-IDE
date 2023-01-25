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
package actionScripts.plugins.as3project.mxmlc
{
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugins.build.CompilerPluginBase;
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.ProjectVO;

	public class MXMLCPluginBase extends CompilerPluginBase
	{
		override protected function checkProjectForInvalidPaths(project:ProjectVO):void
		{
			invalidPaths = [];
			var tmpLocation:FileLocation;

			var as3Project:AS3ProjectVO = project as AS3ProjectVO;
			if (!as3Project)
			{
				return;
			}
			
			checkPathFileLocation(as3Project.folderLocation, "Location");
			if (as3Project.sourceFolder) checkPathFileLocation(as3Project.sourceFolder, "Source Folder");
			if (as3Project.visualEditorSourceFolder) checkPathFileLocation(as3Project.visualEditorSourceFolder, "Source Folder");
			
			if (as3Project.buildOptions.customSDK)
			{
				checkPathFileLocation(as3Project.buildOptions.customSDK, "Custom SDK");
			}
			
			for each (tmpLocation in as3Project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			for each (tmpLocation in as3Project.resourcePaths)
			{
				checkPathFileLocation(tmpLocation, "Resource");
			}
			for each (tmpLocation in as3Project.externalLibraries)
			{
				checkPathFileLocation(tmpLocation, "External Library");
			}
			for each (tmpLocation in as3Project.libraries)
			{
				checkPathFileLocation(tmpLocation, "Library");
			}
			for each (tmpLocation in as3Project.nativeExtensions)
			{
				checkPathFileLocation(tmpLocation, "Extension");
			}
			for each (tmpLocation in as3Project.runtimeSharedLibraries)
			{
				checkPathFileLocation(tmpLocation, "Shared Library");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
	}
}