////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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