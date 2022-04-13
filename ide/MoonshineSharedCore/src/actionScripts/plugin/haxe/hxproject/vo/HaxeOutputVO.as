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
package actionScripts.plugin.haxe.hxproject.vo
{
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;

	public class HaxeOutputVO 
	{
		public static const PLATFORM_AIR:String = "AIR";
		public static const PLATFORM_AIR_MOBILE:String = "AIR Mobile";
		public static const PLATFORM_CSHARP:String = "C#";
		public static const PLATFORM_CPP:String = "C++";
		public static const PLATFORM_FLASH_PLAYER:String = "Flash Player";
		public static const PLATFORM_HASHLINK:String = "HashLink";
		public static const PLATFORM_JAVASCRIPT:String = "JavaScript";
		public static const PLATFORM_JAVA:String = "Java";
		public static const PLATFORM_LIME:String = "Lime";
		public static const PLATFORM_NEKO:String = "Neko";
		public static const PLATFORM_PHP:String = "PHP";
		public static const PLATFORM_PYTHON:String = "Python";
		
		public var disabled:Boolean = false;
		public var path:FileLocation = null;
		public var frameRate:Number = 0;
		public var swfVersion:uint = 0;
		public var swfMinorVersion:uint = 0;
		public var width:int = 0;
		public var height:int = 0;
		public var platform:String = PLATFORM_JAVASCRIPT;
		
		// TODO What is this? It's present as <movie input="" /> in FD .hxproj
		/** Not sure what this is */
		public var input:String = "";
		
		/** Background color */
		public var background:uint = 0xFFFFFF;
		
		
		public function toString():String {
			return "[HaxeOutput path='"+path.fileBridge.nativePath+"' frameRate='"+frameRate+"' swfVersion='"+swfVersion+"' width='"+width+"' height='"+height+"' background='#"+backgroundColorHex+"']";
		}
		
		public function get backgroundColorHex():String {
			return TextUtil.padLeft(background.toString(16).toUpperCase(), 6);
		}
		
		public function parse(output:XMLList, project:HaxeProjectVO):void 
		{
			var params:XMLList = output.movie;
			disabled = SerializeUtil.deserializeBoolean(params.@disabled);
			var pathParam:String = params.@path;
			if (pathParam)
			{
				path = project.folderLocation.resolvePath(UtilsCore.fixSlashes(pathParam));
			}
			frameRate = Number(params.@fps);
			width = int(params.@width);
			height = int(params.@height);
			background = uint("0x"+String(params.@background).substr(1));
			input = String(params.@input);
			platform = String(params.@platform);
			swfVersion = uint(params.@version);
		}
		
		/*
			Returns XML representation of this class.
			If root is set you will get relative paths
		*/
		public function toXML(folder:FileLocation):XML
		{
			var output:XML = <output/>;
			
			var pathStr:String = "";
			if (path)
			{
				pathStr = path.fileBridge.nativePath;
				if (folder) {
					pathStr = folder.fileBridge.getRelativePath(path);
				}
				
				// in case parsing relative path returns null
				// particularly in scenario when "path" is outside folder
				// of "folder"
				if (!pathStr) pathStr = path.fileBridge.nativePath;
			}
			
			var outputPairs:Object = {
				'disabled'	: 	SerializeUtil.serializeBoolean(disabled),
				'fps'		:	frameRate,
				'path'		:	pathStr,
				'width'		:	width,
				'height'	:	height,
				'version'	:	swfVersion,
				'background':	"#"+backgroundColorHex,
				'input'		:	input,
				'platform'	:	platform
			}
			
			output.appendChild(SerializeUtil.serializePairs(outputPairs, <movie/>));
				
			return output;
		}
	}
}