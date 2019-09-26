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