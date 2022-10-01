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
package actionScripts.plugin.actionscript.as3project.vo
{
    import mx.utils.StringUtil;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.MobileDeviceVO;
    import actionScripts.valueObjects.SDKReferenceVO;

	public class BuildOptions 
	{
		public static var defaultOptions:BuildOptions = new BuildOptions();
		public static const TYPE_FB:String = "TYPE_FB";
		public static const TYPE_FD:String = "TYPE_FD";
		
		//https://help.adobe.com/en_US/flashbuilder/using/WSe4e4b720da9dedb5-6caff02f136a645e895-7ffe.html
		//standard takes longer to package is suitable for submission to the app store
		public static const IOS_PACKAGING_STANDARD:String = "IOS_PACKAGING_STANDARD";
		//fast bypasses bytecode translation interprets the SWF
		public static const IOS_PACKAGING_FAST:String = "IOS_PACKAGING_FAST";

		public static const CONNECT_TYPE_WIFI:String = "WiFi";
		public static const CONNECT_TYPE_USB:String = "USB";
		
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
		public var staticLinkRSL:Boolean = false;
		public var additional:String;
		public var compilerConstants:String;
		public var sourceMap:Boolean;
		public var customSDKPath:String;
		public var certAndroid:String;
		public var certAndroidPassword:String;
		public var certIos:String;
		public var certIosPassword:String;
		public var certIosProvisioning:String;
		public var iosPackagingMode:String = IOS_PACKAGING_FAST;

        public var antBuildPath:String;

		private var _targetPlatform:String;
        public var oldDefaultSDKPath:String;

		public function set targetPlatform(value:String):void
		{
			_targetPlatform = value;
		}
		public function get targetPlatform():String
		{
			return _targetPlatform;
		}
		
		private var _isMobileRunOnSimulator:Boolean = true;
		public function set isMobileRunOnSimulator(value:Boolean):void
		{
			_isMobileRunOnSimulator = value;
		}
		public function get isMobileRunOnSimulator():Boolean
		{
			return _isMobileRunOnSimulator;
		}
		
		private var _isMobileHasSimulatedDevice:MobileDeviceVO;
		public function set isMobileHasSimulatedDevice(value:MobileDeviceVO):void
		{
			_isMobileHasSimulatedDevice = value;
		}
		public function get isMobileHasSimulatedDevice():MobileDeviceVO
		{
			return _isMobileHasSimulatedDevice;
		}
		
		private var _isMobileConnectType:String = CONNECT_TYPE_USB;
		public function set isMobileConnectType(value:String):void
		{
			_isMobileConnectType = value;
		}
		public function get isMobileConnectType():String
		{
			return _isMobileConnectType;
		}
		
		public function get customSDK():FileLocation
		{ 
			if (customSDKPath) 
			{
				var sdkReference:SDKReferenceVO = UtilsCore.getUserDefinedSDK(customSDKPath, "path");
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

		public function parse(build:XMLList, parseType:String=TYPE_FD):void 
		{
			if (parseType == TYPE_FD)
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
			}
		}
		
		public function toXML():XML
		{
			var build:XML = <build/>;
			
			var pairs:Object = {
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
            }
        }
    }
}