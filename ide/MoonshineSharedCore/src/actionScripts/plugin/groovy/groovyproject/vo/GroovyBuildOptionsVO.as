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
package actionScripts.plugin.groovy.groovyproject.vo
{
    import mx.utils.StringUtil;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.MobileDeviceVO;
    import actionScripts.valueObjects.SDKReferenceVO;

	public class GroovyBuildOptionsVO
	{
		public static var defaultOptions:GroovyBuildOptionsVO = new GroovyBuildOptionsVO();
		
		public var encoding:String = "UTF-8";
		public var temp:String = null;
		public var exception:Boolean = false;
		public var destdir:String = null;
		public var indy:Boolean = false;
		public var configscript:String = null;
		public var scriptBaseClass:String = null;
		public var parameters:Boolean = false;
		public var verbose:Boolean = false;
		public var targetBytecode:String = "1.8";
		public var additional:String;
		
		/**
		 * @return mxmlc arguments with defaults removed
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
			if (additional && (StringUtil.trim(additional).length > 0)) args += " "+additional.replace("\n", " ");
			return args;
		}

		public function parse(build:XMLList):void 
		{
			var options:XMLList = build.option;
			
			encoding							= SerializeUtil.deserializeString(options.@encoding);
			temp								= SerializeUtil.deserializeString(options.@temp);
			exception							= SerializeUtil.deserializeBoolean(options.@exception);
			indy								= SerializeUtil.deserializeBoolean(options.@indy);
			configscript						= SerializeUtil.deserializeString(options.@configscript);
			scriptBaseClass						= SerializeUtil.deserializeString(options.@scriptBaseClass);
			parameters							= SerializeUtil.deserializeBoolean(options.@parameters);
			destdir								= SerializeUtil.deserializeString(options.@destdir);
			targetBytecode						= SerializeUtil.deserializeString(options.@targetBytecode);
			verbose								= SerializeUtil.deserializeBoolean(options.@verbose);
			additional							= SerializeUtil.deserializeString(options.@additional);
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			var pairs:Object = {
				encoding						:	SerializeUtil.serializeString(encoding),
				temp							:	SerializeUtil.serializeString(temp),
				exception						:	SerializeUtil.serializeBoolean(exception),
				indy							:	SerializeUtil.serializeBoolean(indy),
				configscript					:	SerializeUtil.serializeString(configscript),
				scriptBaseClass					:	SerializeUtil.serializeString(scriptBaseClass),
				parameters						:	SerializeUtil.serializeBoolean(parameters),
				destdir							:	SerializeUtil.serializeString(destdir),
				targetBytecode					:	SerializeUtil.serializeString(targetBytecode),
				verbose							:	SerializeUtil.serializeBoolean(verbose),
				additional						:	SerializeUtil.serializeString(additional)
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
                "encoding"							:	encoding,
                "temp"								:	temp,
                "exception"							:	exception,
                "indy"								:	indy,
                "configscript"						:	configscript,
                "scriptBaseClass"					:	scriptBaseClass,
                "parameters"						:	parameters,
                "destdir"							:	destdir,
				"verbose"							:	verbose,
				"targetBytecode"					:	targetBytecode
            }
        }
    }
}