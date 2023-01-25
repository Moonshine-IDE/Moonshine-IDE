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
		protected var invalidPaths:Array;

		protected function checkProjectForInvalidPaths(project:ProjectVO):void
		{
			invalidPaths = [];
			onProjectPathsValidated(null);
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
		
		protected function checkPathFileLocation(value:FileLocation, type:String):void
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