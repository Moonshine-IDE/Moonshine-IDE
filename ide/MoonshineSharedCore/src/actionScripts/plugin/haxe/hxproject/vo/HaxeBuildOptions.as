////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
		public var additional:String = "";
		
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
			var options:XMLList = build.elements("option");
			
			mainClass							= SerializeUtil.deserializeString(options.attribute("mainClass").toString());
			enabledebug							= SerializeUtil.deserializeBoolean(options.attribute("enabledebug").toString());
			noInlineOnDebug						= SerializeUtil.deserializeBoolean(options.attribute("noInlineOnDebug").toString());
			flashStrict							= SerializeUtil.deserializeBoolean(options.attribute("flashStrict").toString());
			directives							= SerializeUtil.deserializeDelimitedString(options.attribute("directives").toString());
			additional							= SerializeUtil.deserializeString(options.attribute("additional").toString());
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