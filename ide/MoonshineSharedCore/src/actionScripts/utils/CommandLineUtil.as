////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
			if(ConstantsCoreVO.IS_MACOS)
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