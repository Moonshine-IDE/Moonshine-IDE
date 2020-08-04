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
package actionScripts.plugin.actionscript.as3project.vo
{
    import mx.utils.StringUtil;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.utils.SerializeUtil;

	public class FlashModuleOptions 
	{
		public var modulePaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		
		public function addModule(path:FileLocation):void
		{
			modulePaths.push(path);
		}
		
		/**
		 * @return mxmlc arguments with defaults removed
		 */
		public function getArguments():String 
		{
			var pairs:Object = getArgumentPairs();
			/*var dpairs:Object = defaultOptions.getArgumentPairs();
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
			if (args.indexOf("-locale ") != -1)
			{
				var tmpSplit:Array = args.split(" ");
				var localeArray:Array = [];
				for (var i:int=0; i < tmpSplit.length; i ++)
				{
					if (tmpSplit[i] == "-locale" || (tmpSplit[i].indexOf("_") != -1))
					{
						if (tmpSplit[i] != "-locale") localeArray.push(tmpSplit[i]);
						tmpSplit.splice(i, 1);
						i --;
					}
				}
				
				args = tmpSplit.join(" ") + " -locale=" + localeArray.join(",");
			}*/
			return "";
		}

		public function parse(build:XMLList):void 
		{
			/*if (parseType == TYPE_FD)
			{
				var options:XMLList = build.option;
				
				accessible							= SerializeUtil.deserializeBoolean(options.@accessible);
				allowSourcePathOverlap				= SerializeUtil.deserializeBoolean(options.@allowSourcePathOverlap);
				benchmark							= SerializeUtil.deserializeBoolean(options.@benchmark);
				es									= SerializeUtil.deserializeBoolean(options.@es);
				optimize							= SerializeUtil.deserializeBoolean(options.@optimize);
				showActionScriptWarnings			= SerializeUtil.deserializeBoolean(options.@showActionScriptWarnings);
				showBindingWarnings					= SerializeUtil.deserializeBoolean(options.@showBindingWarnings);
				showDeprecationWarnings				= SerializeUtil.deserializeBoolean(options.@showDeprecationWarnings);
				showUnusedTypeSelectorWarnings		= SerializeUtil.deserializeBoolean(options.@showUnusedTypeSelectorWarnings);
				strict								= SerializeUtil.deserializeBoolean(options.@strict);
				useNetwork							= SerializeUtil.deserializeBoolean(options.@useNetwork);
				useResourceBundleMetadata			= SerializeUtil.deserializeBoolean(options.@useResourceBundleMetadata);
				warnings							= SerializeUtil.deserializeBoolean(options.@warnings);
				verboseStackTraces					= SerializeUtil.deserializeBoolean(options.@verboseStackTraces);
				staticLinkRSL						= SerializeUtil.deserializeBoolean(options.@staticLinkRSL);
				
				locale								= SerializeUtil.deserializeString(options.@locale);
				loadConfig							= SerializeUtil.deserializeString(options.@loadConfig);
				linkReport							= SerializeUtil.deserializeString(options.@linkReport);
				additional							= SerializeUtil.deserializeString(options.@additional);
				compilerConstants					= SerializeUtil.deserializeString(options.@compilerConstants);
				sourceMap 							= SerializeUtil.deserializeBoolean(options.@sourceMap);
				customSDKPath						= SerializeUtil.deserializeString(options.@customSDK);
				antBuildPath						= SerializeUtil.deserializeString(options.@antBuildPath);
			}
			else if (parseType == TYPE_FB)
			{
				additional = StringUtil.trim(build.@additionalCompilerArguments);
				// FB seems to keep it as -switch value, while mxmlc takes -switch=value
				//additional = tmpAdditional.replace(/\s+/g,",").replace(/-([^,]+),([^-]+)/g,"-$1=$2");
				warnings = SerializeUtil.deserializeBoolean(build.@warn);
				accessible = SerializeUtil.deserializeBoolean(build.@generateAccessible);
				strict = SerializeUtil.deserializeBoolean(build.@strict);
				customSDKPath = SerializeUtil.deserializeString(build.@flexSDK);
			}*/
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			/*var pairs:Object = {
				accessible							:	SerializeUtil.serializeBoolean(accessible),
				allowSourcePathOverlap				:	SerializeUtil.serializeBoolean(allowSourcePathOverlap),
				benchmark							:	SerializeUtil.serializeBoolean(benchmark),
				es									:	SerializeUtil.serializeBoolean(es),
				optimize							:	SerializeUtil.serializeBoolean(optimize),
				showActionScriptWarnings			:	SerializeUtil.serializeBoolean(showActionScriptWarnings),
				showBindingWarnings					:	SerializeUtil.serializeBoolean(showBindingWarnings),
				showDeprecationWarnings				:	SerializeUtil.serializeBoolean(showDeprecationWarnings),
				showUnusedTypeSelectorWarnings		:	SerializeUtil.serializeBoolean(showUnusedTypeSelectorWarnings),
				strict								:	SerializeUtil.serializeBoolean(strict),
				useNetwork							:	SerializeUtil.serializeBoolean(useNetwork),
				useResourceBundleMetadata			:	SerializeUtil.serializeBoolean(useResourceBundleMetadata),
				warnings							:	SerializeUtil.serializeBoolean(warnings),
				verboseStackTraces					:	SerializeUtil.serializeBoolean(verboseStackTraces),
				staticLinkRSL						:	SerializeUtil.serializeBoolean(staticLinkRSL),

				locale								:	SerializeUtil.serializeString(locale),
				loadConfig							:	SerializeUtil.serializeString(loadConfig),
				linkReport							:	SerializeUtil.serializeString(linkReport),
				additional							:	SerializeUtil.serializeString(additional),
				compilerConstants					:	SerializeUtil.serializeString(compilerConstants),
				sourceMap							: 	SerializeUtil.serializeBoolean(sourceMap),
				customSDK							:	SerializeUtil.serializeString(customSDKPath),
				antBuildPath						:	SerializeUtil.serializeString(antBuildPath)
			}
			
			build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));*/
			
			return build;
		}

        private function getArgumentPairs():Object {
            /*return {
                "load-config+"							:	loadConfig,
                "accessible"							:	accessible,
                "allow-source-path-overlap"				:	allowSourcePathOverlap,
                "benchmark"								:	benchmark,
                "es"									:	es,
                "as3"									:	!es,
                "optimize"								:	optimize,
                "show-actionscript-warnings"			:	showActionScriptWarnings,
                "show-binding-warnings"					:	showBindingWarnings,
                "show-deprecation-warnings"				:	showDeprecationWarnings,
                "show-unused-type-selector-warnings"	:	showUnusedTypeSelectorWarnings,
                "strict"								:	strict,
                "use-network"							:	useNetwork,
                "use-resource-bundle-metadata"			:	useResourceBundleMetadata,
                "warnings"								:	warnings,
                "verbose-stacktraces"					:	verboseStackTraces,
                "link-report"							:	linkReport,
                "static-link-runtime-shared-libraries"	:	staticLinkRSL,
				"source-map"							:   sourceMap
            }*/
			
			return {};
        }
    }
}