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
package actionScripts.utils
{
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public function getProjectSDKPath(project:ProjectVO, model:IDEModel):String
	{
		if(project is AS3ProjectVO)
		{
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			if(as3Project.buildOptions.customSDK)
			{
				return as3Project.buildOptions.customSDK.fileBridge.nativePath;
			}
			else if(model.defaultSDK)
			{
				return model.defaultSDK.fileBridge.nativePath;
			}
		}
		else if(project is JavaProjectVO)
		{
			var javaProject:JavaProjectVO = JavaProjectVO(project);
			if(model.javaPathForTypeAhead)
			{
				return model.javaPathForTypeAhead.fileBridge.nativePath;
			}
		}
		else if(project is GrailsProjectVO)
		{
			var grailsProject:GrailsProjectVO = GrailsProjectVO(project);
			if(model.javaPathForTypeAhead)
			{
				return model.javaPathForTypeAhead.fileBridge.nativePath;
			}
		}
		else if(project is HaxeProjectVO)
		{
			var haxeProject:HaxeProjectVO = HaxeProjectVO(project);
			if(model.haxePath)
			{
				return model.haxePath;
			}
		}
		return null;
	}
}
