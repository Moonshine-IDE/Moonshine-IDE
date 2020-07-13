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
package actionScripts.plugin.ondiskproj.vo
{
    import mx.utils.StringUtil;
    
    import actionScripts.utils.SerializeUtil;

	public class OnDiskBuildOptions 
	{
		public static var defaultOptions:OnDiskBuildOptions = new OnDiskBuildOptions();
		
		public var additional:String;
		public var antBuildPath:String;
		public var linkReport:String;
		
		/**
		 * @return haxe arguments with defaults removed
		 */
		public function getArguments():String 
		{
			var pairs:Object = getArgumentPairs();
			var dpairs:Object = defaultOptions.getArgumentPairs();
			var args:String = "";
			for (var p:String in pairs) {
				if (isArgumentExistsInAdditionalOptions(p))
				{
					continue;
                }
				
				if (pairs[p] != dpairs[p]) {
					args += " -"+p+"="+pairs[p];
				}
			}
			if (additional && (StringUtil.trim(additional).length > 0))
			{
				args += " " + additional.replace("\n", " ");
			}
			return args;
		}

		public function parse(build:XMLList):void 
		{
			var options:XMLList = build.option;
			
			additional							= SerializeUtil.deserializeString(options.@additional);
			antBuildPath						= SerializeUtil.deserializeString(options.@antBuildPath);
			linkReport							= SerializeUtil.deserializeString(options.@linkReport);
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			var pairs:Object = {
				additional						:	SerializeUtil.serializeString(additional),
				antBuildPath					:	SerializeUtil.serializeString(antBuildPath),
				linkReport						:	SerializeUtil.serializeString(linkReport)
			}
			
			build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));
			
			return build;
		}

		private function isArgumentExistsInAdditionalOptions(name:String):Boolean
		{
			if (!additional) return false;

			var trimmedAdditionalOptions:String = StringUtil.trim(additional);
			if (trimmedAdditionalOptions.length == 0)
			{
				return false;
            }

			return trimmedAdditionalOptions.indexOf("-" + name) > -1 || trimmedAdditionalOptions.indexOf("+" + name) > -1;
		}

        private function getArgumentPairs():Object {
            return {
				"link-report"					:	linkReport
            }
        }
    }
}