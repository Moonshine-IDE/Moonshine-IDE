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

	public function getHaxeProjectTarget(project:HaxeProjectVO):String
	{
		var platform:String = project.haxeOutput.platform;
		if(OUTPUT_PLATFORM_TO_HAXE_TARGET.hasOwnProperty(platform))
		{
			return OUTPUT_PLATFORM_TO_HAXE_TARGET[platform];
		}
		return null;
	}
}

import actionScripts.plugin.haxe.hxproject.vo.HaxeOutputVO;
import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

const OUTPUT_PLATFORM_TO_HAXE_TARGET:Object = {};

OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_AIR] = HaxeProjectVO.HAXE_TARGET_SWF;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_AIR_MOBILE] = HaxeProjectVO.HAXE_TARGET_SWF;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_CPP] = HaxeProjectVO.HAXE_TARGET_CPP;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_CSHARP] = HaxeProjectVO.HAXE_TARGET_CS;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_FLASH_PLAYER] = HaxeProjectVO.HAXE_TARGET_SWF;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_HASHLINK] = HaxeProjectVO.HAXE_TARGET_HL;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_JAVASCRIPT] = HaxeProjectVO.HAXE_TARGET_JS;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_JAVA] = HaxeProjectVO.HAXE_TARGET_JAVA;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_NEKO] = HaxeProjectVO.HAXE_TARGET_NEKO;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_PHP] = HaxeProjectVO.HAXE_TARGET_PHP;
OUTPUT_PLATFORM_TO_HAXE_TARGET[HaxeOutputVO.PLATFORM_PYTHON] = HaxeProjectVO.HAXE_TARGET_PYTHON;