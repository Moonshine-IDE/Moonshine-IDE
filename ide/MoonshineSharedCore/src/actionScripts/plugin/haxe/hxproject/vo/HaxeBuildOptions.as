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
    import actionScripts.utils.SerializeUtil;

    import mx.utils.StringUtil;

	public class HaxeBuildOptions 
	{
		public static var defaultOptions:HaxeBuildOptions = new HaxeBuildOptions();
		
		public var directives:Vector.<String>;
		public var flashStrict:Boolean = false;
		public var noInlineOnDebug:Boolean = false;
		public var mainClass:String;
		public var enabledebug:Boolean = false;
		public var additional:String;
		
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
			if(directives)
			{
				for each(var directive:String in directives)
				{
					args += " -D " + directive;
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
			
			mainClass							= SerializeUtil.deserializeString(options.@mainClass);
			enabledebug							= SerializeUtil.deserializeBoolean(options.@enabledebug);
			noInlineOnDebug						= SerializeUtil.deserializeBoolean(options.@noInlineOnDebug);
			flashStrict							= SerializeUtil.deserializeBoolean(options.@flashStrict);
			directives							= SerializeUtil.deserializeDelimitedString(options.@directives);
			additional							= SerializeUtil.deserializeString(options.@additional);
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			var pairs:Object = {
				mainClass							:	SerializeUtil.serializeString(mainClass),
				enabledebug							:	SerializeUtil.serializeBoolean(enabledebug),
				noInlineOnDebug						:	SerializeUtil.serializeBoolean(noInlineOnDebug),
				flashStrict							:	SerializeUtil.serializeBoolean(flashStrict),
				directives							:	SerializeUtil.serializeDelimitedString(directives),
				additional							:	SerializeUtil.serializeString(additional)
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
                "flash-strict"							:	flashStrict,
				"main"									:	mainClass
            }
        }
    }
}