
/*
Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
SPDX-License-Identifier: Apache-2.0

Source: https://github.com/vegardit/haxe-files/blob/a341ea5/src/hx/files/GlobPatterns.hx
*/
package actionScripts.utils
{
	public class GlobPatterns
	{
		private static const ASTERISK:String = "*";
		private static const BACKSLASH:String = "\\";
		private static const BRACKET_CURLY_LEFT:String = "{";
		private static const BRACKET_CURLY_RIGHT:String = "}";
		private static const BRACKET_ROUND_LEFT:String = "(";
		private static const BRACKET_ROUND_RIGHT:String = ")";
		private static const BRACKET_SQUARE_LEFT:String = "[";
		private static const CARET:String = "^";
		private static const COMMA:String = ",";
		private static const DOT:String = ".";
		private static const EXCLAMATION_MARK:String = "!";
		private static const DOLLAR:String = "$";
		private static const PIPE:String = "|";
		private static const QUESTION_MARK:String = "?";
		private static const SLASH:String = "/";

		public static function toRegExp(globPattern:String):RegExp {
			return new RegExp(toRegExpString(globPattern));
		}

		public static function toRegExpString(globPattern:String):String {
			if (!globPattern) {
				return globPattern;
			}

			var result:String = CARET;
			const charsLenMinus1:int = globPattern.length - 1;
			var chPrev:String = null;
			var groupDepth:int = 0;
			var idx:int = -1;
			while(idx < charsLenMinus1) {
				idx++;
				var ch:String = globPattern.charAt(idx);
				switch (ch) {
					case BACKSLASH:
						if (chPrev == BACKSLASH)
							result += "\\\\"; // "\\" => "\\"
						break;
					case SLASH:
						// "/" => "[\/\\]"
						result += "[\\/\\\\]";
						break;
					case DOLLAR:
						// "$" => "\$"
						result += "\\$";
						break;
					case QUESTION_MARK:
						if (chPrev == BACKSLASH)
							result += "\\?"; // "\?" => "\?"
						else
							result += "[^\\\\^\\/]"; // "?" => "[^\\^\/]"
						break;
					case DOT:
						// "." => "\."
						result += "\\.";
						break;
					case BRACKET_ROUND_LEFT:
						// "(" => "\("
						result += "\\(";
						break;
					case BRACKET_ROUND_RIGHT:
						// ")" => "\)"
						result += "\\)";
						break;
					case BRACKET_CURLY_LEFT:
						if (chPrev == BACKSLASH)
							result += "\\{"; // "\{" => "\{"
						else {
							groupDepth++;
							result += BRACKET_ROUND_LEFT;
						}
						break;
					case BRACKET_CURLY_RIGHT:
						if (chPrev == BACKSLASH)
							result += "\\}"; // "\}" => "\}"
						else {
							groupDepth--;
							result += BRACKET_ROUND_RIGHT;
						}
						break;
					case COMMA:
						if (chPrev == BACKSLASH)
							result += "\\,"; // "\," => "\,"
						else {
							// "," => "|" if in group or => "," if not in group
							result += (groupDepth > 0 ? PIPE : COMMA);
						}
						break;
					case EXCLAMATION_MARK:
						if (chPrev == BRACKET_SQUARE_LEFT)
							result += CARET;  // "[!" => "[^"
						else
							result += ch;
						break;
					case ASTERISK:
						if (globPattern.charAt(idx + 1) == ASTERISK) { // **
							if (globPattern.charAt(idx + 2) == SLASH) { // **/
								if (globPattern.charAt(idx + 3) == ASTERISK) {
									// "**/*" => ".*"
									result += ".*";
									idx += 3;
								} else {
									// "**/" => "(.*[\/\\])?"
									result += "(.*[\\/\\\\])?";
									idx += 2;
									ch = SLASH;
								}
							} else {
								result += ".*"; // "**" => ".*"
								idx++;
							}
						} else {
							result += "[^\\\\^\\/]*"; // "*" => "[^\\^\/]*"
						}
						break;
					default:
						if (chPrev == BACKSLASH) {
							result += BACKSLASH;
						}
						result += ch;
				}

				chPrev = ch;
			}
			result += DOLLAR;
			return result;
		}
	}
}