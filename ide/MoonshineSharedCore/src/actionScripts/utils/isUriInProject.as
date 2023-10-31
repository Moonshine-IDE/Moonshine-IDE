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
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.IClasspathProject;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

	public function isUriInProject(uri:String, project:ProjectVO):Boolean
	{
		var fileForUri:FileLocation = new FileLocation(uri, true);
		var projectFile:FileLocation = new FileLocation(project.folderPath, false);
		//getRelativePath() will return null if fileForUri is not in the
		//projectFile directory
		if(projectFile.fileBridge.getRelativePath(fileForUri, false) !== null)
		{
			return true;
		}
		if(project is IClasspathProject)
		{
			var classpathProject:IClasspathProject = IClasspathProject(project);
			var classpaths:Vector.<FileLocation> = classpathProject.classpaths;
			var classpathsCount:int = classpaths.length;
			for(var i:int = 0; i < classpathsCount; i++)
			{
				var classpath:FileLocation = classpaths[i];
				if(classpath.fileBridge.getRelativePath(fileForUri, false) !== null)
				{
					return true;
				}
			}
		}
		if (project is AS3ProjectVO)
		{
			// TODO: refactor detection of source file from SDK into an
			// interface that project VOs can implement, similar to
			// IClasspathProject above
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			var sdkPath:String = null;
			if(as3Project.buildOptions.customSDK)
			{
				sdkPath = as3Project.buildOptions.customSDK.fileBridge.nativePath;
			}
			else if(IDEModel.getInstance().defaultSDK)
			{
				sdkPath = IDEModel.getInstance().defaultSDK.fileBridge.nativePath;
			}
			if(sdkPath != null)
			{
				var sdkFile:FileLocation = new FileLocation(sdkPath, false);
				if(sdkFile.fileBridge.getRelativePath(fileForUri, false) !== null)
				{
					return true;
				}
			}
		}
		return false;
	}
}
