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

package actionScripts.plugin.actionscript.as3project.importer
{
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.factory.FileLocation;
	
	public class FlashDevelopImporter extends FlashDevelopImporterBase
	{
		public static function test(file:FileLocation):FileLocation
		{
			return null;
		}
		
		public static function parse(file:FileLocation, projectName:String=null, descriptorFile:FileLocation=null, shallUpdateChildren:Boolean=true, projectTemplateType:String = null):AS3ProjectVO
		{
			return null;
		}
		
		public static function parse(p:AS3ProjectVO):AS3ProjectVO
		{
			var data:XML = ConstantsCoreVO.AS3PROJ_CONFIG_SOURCE;
			
			// Parse XML file
			if (p)
			{
				p.classpaths.length = 0;
				p.resourcePaths.length = 0;
				p.targets.length = 0;
				
				p.swfOutput.parse(data.output, p);
				
				parsePaths(data.classpaths["class"], p.classpaths, p);
				parsePaths(data.moonshineResourcePaths["class"], p.resourcePaths, p);
				
				p.buildOptions.parse(data.build);
				
				parsePaths(data.includeLibraries.element, p.includeLibraries, p);
				parsePaths(data.libraryPaths.element, p.libraries, p);
				parsePaths(data.externalLibraryPaths.element, p.externalLibraries, p);
				parsePaths(data.rslPaths.element, p.runtimeSharedLibraries, p);
				
				p.assetLibrary = data.library;
				parsePaths(data.compileTargets.compile, p.targets, p);
				parsePaths(data.hiddenPaths.hidden, p.hiddenPaths, p);
				
				p.prebuildCommands = SerializeUtil.deserializeString(data.preBuildCommand);
				p.postbuildCommands = SerializeUtil.deserializeString(data.postBuildCommand);
				p.postbuildAlways = SerializeUtil.deserializeBoolean(data.postBuildCommand.@alwaysRun);
				
				p.showHiddenPaths = SerializeUtil.deserializeBoolean(data.options.option.@showHiddenPaths);
				
				p.testMovie = data.options.option.@testMovie;
				
				if (p.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || p.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
				{
					p.testMovieCommand = data.options.option.@testMovieCommand;
				}
			}
			
			return p;
		}
	}
}