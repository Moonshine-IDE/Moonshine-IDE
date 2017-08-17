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
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectReferenceVO;

	public class BuildOptions 
	{
		public static var defaultOptions:BuildOptions = new BuildOptions();
		public static const TYPE_FB:String = "TYPE_FB";
		public static const TYPE_FD:String = "TYPE_FD";
		
		public var accessible:Boolean = false;
		public var allowSourcePathOverlap:Boolean = false;
		public var benchmark:Boolean = false;
		public var es:Boolean = false;
		public var locale:String;
		public var loadConfig:String;
		public var optimize:Boolean = true;
		public var showActionScriptWarnings:Boolean = true;
		public var showBindingWarnings:Boolean = true;
		public var showDeprecationWarnings:Boolean = true;
		public var showUnusedTypeSelectorWarnings:Boolean = true;
		public var strict:Boolean = true;
		public var useNetwork:Boolean = true;
		public var useResourceBundleMetadata:Boolean = true;
		public var warnings:Boolean = true;
		public var verboseStackTraces:Boolean = false;
		public var linkReport:String;
		public var loadExterns:String;
		public var staticLinkRSL:Boolean = false;
		public var additional:String;
		public var compilerConstants:String;
		public var antBuildPath:String;
		public var customSDKPath:String;
		public var currentDefaultSDKPath:String;
		public var oldDefaultSDKPath:String;
		public var isCleanRequiresBeforeBuild:Boolean;
		
		public function get customSDK():FileLocation
		{ 
			if (customSDKPath) 
			{
				var sdkReference:ProjectReferenceVO = UtilsCore.getUserDefinedSDK(customSDKPath, "path");
				if (sdkReference)
				{
					var tmpSDK:FileLocation = new FileLocation(sdkReference.path);
					tmpSDK.fileBridge.canonicalize();
					return tmpSDK;
				}
			}
			return null;
		}
		
		/**
		 * @return mxmlc arguments with defaults removed
		 */
		public function getArguments():String {
			var pairs:Object = getArgumentPairs();
			var dpairs:Object = defaultOptions.getArgumentPairs();
			var args:String = "";
			for (var p:String in pairs) {
				if (pairs[p] != dpairs[p]) {
					args += " -"+p+"="+pairs[p];
				}
			}
			if (additional) args += " "+additional.replace("\n", " ");
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
			}
			return args;
		}
		private function getArgumentPairs():Object {
			return {
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
				"static-link-runtime-shared-libraries"	:	staticLinkRSL
			}
		}
		
		public function parse(build:XMLList, parseType:String=TYPE_FD):void 
		{
			if (parseType == TYPE_FD)
			{
				var options:XMLList = build.option;
				
				accessible							= UtilsCore.deserializeBoolean(options.@accessible);
				allowSourcePathOverlap				= UtilsCore.deserializeBoolean(options.@allowSourcePathOverlap);
				benchmark							= UtilsCore.deserializeBoolean(options.@benchmark);
				es									= UtilsCore.deserializeBoolean(options.@es);
				optimize							= UtilsCore.deserializeBoolean(options.@optimize);
				showActionScriptWarnings			= UtilsCore.deserializeBoolean(options.@showActionScriptWarnings);
				showBindingWarnings					= UtilsCore.deserializeBoolean(options.@showBindingWarnings);
				showDeprecationWarnings				= UtilsCore.deserializeBoolean(options.@showDeprecationWarnings);
				showUnusedTypeSelectorWarnings		= UtilsCore.deserializeBoolean(options.@showUnusedTypeSelectorWarnings);
				strict								= UtilsCore.deserializeBoolean(options.@strict);
				useNetwork							= UtilsCore.deserializeBoolean(options.@useNetwork);
				useResourceBundleMetadata			= UtilsCore.deserializeBoolean(options.@useResourceBundleMetadata);
				warnings							= UtilsCore.deserializeBoolean(options.@warnings);
				verboseStackTraces					= UtilsCore.deserializeBoolean(options.@verboseStackTraces);
				staticLinkRSL						= UtilsCore.deserializeBoolean(options.@staticLinkRSL);
				
				locale								= UtilsCore.deserializeString(options.@locale);
				loadConfig							= UtilsCore.deserializeString(options.@loadConfig);
				linkReport							= UtilsCore.deserializeString(options.@linkReport);
				additional							= UtilsCore.deserializeString(options.@additional);
				compilerConstants					= UtilsCore.deserializeString(options.@compilerConstants);
				customSDKPath						= UtilsCore.deserializeString(options.@customSDK);
				antBuildPath						= UtilsCore.deserializeString(options.@antBuildPath);
			}
			else if (parseType == TYPE_FB)
			{
				additional = StringUtil.trim(build.@additionalCompilerArguments);
				// FB seems to keep it as -switch value, while mxmlc takes -switch=value
				//additional = tmpAdditional.replace(/\s+/g,",").replace(/-([^,]+),([^-]+)/g,"-$1=$2");
				warnings = UtilsCore.deserializeBoolean(build.@warn);
				accessible = UtilsCore.deserializeBoolean(build.@generateAccessible);
				strict = UtilsCore.deserializeBoolean(build.@strict);
				customSDKPath = UtilsCore.deserializeString(build.@flexSDK);
			}
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			var pairs:Object = {
				accessible							:	UtilsCore.serializeBoolean(accessible),
				allowSourcePathOverlap				:	UtilsCore.serializeBoolean(allowSourcePathOverlap),
				benchmark							:	UtilsCore.serializeBoolean(benchmark),
				es									:	UtilsCore.serializeBoolean(es),
				optimize							:	UtilsCore.serializeBoolean(optimize),
				showActionScriptWarnings			:	UtilsCore.serializeBoolean(showActionScriptWarnings),
				showBindingWarnings					:	UtilsCore.serializeBoolean(showBindingWarnings),
				showDeprecationWarnings				:	UtilsCore.serializeBoolean(showDeprecationWarnings),
				showUnusedTypeSelectorWarnings		:	UtilsCore.serializeBoolean(showUnusedTypeSelectorWarnings),
				strict								:	UtilsCore.serializeBoolean(strict),
				useNetwork							:	UtilsCore.serializeBoolean(useNetwork),
				useResourceBundleMetadata			:	UtilsCore.serializeBoolean(useResourceBundleMetadata),
				warnings							:	UtilsCore.serializeBoolean(warnings),
				verboseStackTraces					:	UtilsCore.serializeBoolean(verboseStackTraces),
				staticLinkRSL						:	UtilsCore.serializeBoolean(staticLinkRSL),

				locale								:	UtilsCore.serializeString(locale),
				loadConfig							:	UtilsCore.serializeString(loadConfig),
				linkReport							:	UtilsCore.serializeString(linkReport),
				additional							:	UtilsCore.serializeString(additional),
				compilerConstants					:	UtilsCore.serializeString(compilerConstants),
				customSDK							:	UtilsCore.serializeString(customSDKPath),
				antBuildPath						:	UtilsCore.serializeString(antBuildPath)
			}
			
			build.appendChild(UtilsCore.serializePairs(pairs, <option/>));
			
			return build;
		}
		
	}
}