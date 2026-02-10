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
package actionScripts.utils
{
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class CommandLineUtil
	{
		// Source: https://learn.microsoft.com/en-us/previous-versions//cc723564(v=technet.10)
		private static const WINDOWS_RESERVED_SHELL_CHARACTERS:String = " %&|()<>^";
	
		/**
		 * Escapes a command line option so that it cannot be interpreted as
		 * multiple options when joined with others in a single string. For
		 * instance, if a path on the file systems contains spaces or other
		 * reserved characters, this function escapes the option for the current
		 * platform.
		 */
		public static function escapeSingleOption(option:String):String
		{
			if(!ConstantsCoreVO.IS_WINDOWS)
			{
				//on macOS, a backslash can be used to escape a space character
				return option.replace(/ /g, "\\ ");
			}
			var foundCmdSpecialCharacter:Boolean = false;
			for(var i:int = 0; i < option.length; i++)
			{
				var character:String = option.charAt(i);
				if(WINDOWS_RESERVED_SHELL_CHARACTERS.indexOf(character) != -1)
				{
					foundCmdSpecialCharacter = true;
					break;
				}
			}
			if(!foundCmdSpecialCharacter)
			{
				return option;
			}
			//on Windows, options containing certain special chracters should be
			//wrapped in quotes
			return "\"" + option + "\"";
		}
		
		/**
		 * Joins a set of options into a single command.
		 */
		public static function joinOptions(options:Vector.<String>):String
		{
			var result:String = "";
			var optionCount:int = options.length;
			for(var i:int = 0; i < optionCount; i++)
			{
				var option:String = options[i];
				if(i > 0)
				{
					result += " ";
				}
				result += escapeSingleOption(option);
			}
			return result;
		}
	}
}