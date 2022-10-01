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
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.SerializeUtil;
	import actionScripts.utils.TextUtil;
	import actionScripts.utils.UtilsCore;

	public class SWFOutputVO 
	{
		public static const PLATFORM_AIR:String = "AIR";
		public static const PLATFORM_MOBILE:String = "AIR Mobile";
		public static const PLATFORM_DEFAULT:String = "Flash Player";
		
		public var disabled:Boolean = false;
		public var path:FileLocation;
		public var frameRate:Number = 24;
		public var swfVersion:uint = 10;
		public var swfMinorVersion:uint = 0;
		public var width:int = 100;
		public var height:int = 100;
		public var platform:String;
		
		private var _swfVersionStrict:Number = 0;
		public function get swfVersionStrict():Number
		{
			return _swfVersionStrict;
		}
		public function set swfVersionStrict(value:Number):void
		{
			if (!isNaN(value))
			{
				_swfVersionStrict = value;
			}
		}
		
		// TODO What is this? It's present as <movie input="" /> in FD .as3proj
		/** Not sure what this is */
		public var input:String = "";
		
		/** Background color */
		public var background:uint;
		
		
		public function toString():String {
			return "[SWFOutput path='"+path.fileBridge.nativePath+"' frameRate='"+frameRate+"' swfVersion='"+swfVersion+"' width='"+width+"' height='"+height+"' background='#"+backgroundColorHex+"']";
		}
		
		public function get backgroundColorHex():String {
			return TextUtil.padLeft(background.toString(16).toUpperCase(), 6);
		}
		
		public function parse(output:XMLList, project:AS3ProjectVO):void 
		{
			var params:XMLList = output.movie;
			disabled = SerializeUtil.deserializeBoolean(params.@disabled);
			path = project.folderLocation.resolvePath(UtilsCore.fixSlashes(params.@path));
			frameRate = Number(params.@fps);
			width = int(params.@width);
			height = int(params.@height);
			background = uint("0x"+String(params.@background).substr(1));
			input = String(params.@input);
			platform = String(params.@platform);
			
			// we need to do a little more than just setting SWF version value
			// from config.xml.
			// To make thing properly works without much headache, we'll 
			// check if the project does uses any specific SDK, if exists then we'll
			// continue using the config.xml value.
			// If no specific SDK is in use, we'll check if any gloabla SDK is set in Moonshine,
			// if exists then we'll update SWF version by it's version value.
			// If no global SDK exists, then just copy the config.xml value
			if (!project.buildOptions.customSDK && IDEModel.getInstance().defaultSDK)
			{
				swfVersion = SDKUtils.getSdkSwfMajorVersion(null);
			}
			else
			{
				swfVersion = uint(params.@version);
			}
		}
		
		/*
			Returns XML representation of this class.
			If root is set you will get relative paths
		*/
		public function toXML(folder:FileLocation):XML
		{
			var output:XML = <output/>;
			
			var pathStr:String = path.fileBridge.nativePath;
			if (folder) {
				pathStr = folder.fileBridge.getRelativePath(path);
			}
			
			// in case parsing relative path returns null
			// particularly in scenario when "path" is outside folder
			// of "folder"
			if (!pathStr) pathStr = path.fileBridge.nativePath;
			
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