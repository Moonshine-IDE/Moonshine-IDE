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
package actionScripts.plugin.haxe.hxproject.utils
{
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public function getHaxeProjectOutputFileExtension(project:HaxeProjectVO):String
	{
		var platform:String = project.haxeOutput.platform;
		if(OUTPUT_PLATFORM_TO_FILE_EXTENSION.hasOwnProperty(platform))
		{
			return OUTPUT_PLATFORM_TO_FILE_EXTENSION[platform];
		}
		return null;
	}
}

import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;

const OUTPUT_PLATFORM_TO_FILE_EXTENSION:Object = {};
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_AIR] = ".swf";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_AIR_MOBILE] = ".swf";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_FLASH_PLAYER] = ".swf";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_HASHLINK] = ".hl";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_JAVASCRIPT] = ".js";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_NEKO] = ".n";
OUTPUT_PLATFORM_TO_FILE_EXTENSION[HaxeOutputVO.PLATFORM_PYTHON] = ".py";