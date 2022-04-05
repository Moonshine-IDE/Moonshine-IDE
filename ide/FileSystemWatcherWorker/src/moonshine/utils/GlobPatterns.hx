/*
	Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
	SPDX-License-Identifier: Apache-2.0

	Source: https://github.com/vegardit/haxe-files/blob/a341ea5/src/hx/files/GlobPatterns.hx
 */

package moonshine.utils;

class GlobPatterns {
	private static final ASTERISK:String = "*";

	private static final BACKSLASH:String = "\\";
	private static final BRACKET_CURLY_LEFT:String = "{";
	private static final BRACKET_CURLY_RIGHT:String = "}";
	private static final BRACKET_ROUND_LEFT:String = "(";
	private static final BRACKET_ROUND_RIGHT:String = ")";
	private static final BRACKET_SQUARE_LEFT:String = "[";
	private static final CARET:String = "^";
	private static final COMMA:String = ",";
	private static final DOT:String = ".";
	private static final EXCLAMATION_MARK:String = "!";
	private static final DOLLAR:String = "$";
	private static final PIPE:String = "|";
	private static final QUESTION_MARK:String = "?";
	private static final SLASH:String = "/";

	public static function toEReg(globPattern:String):EReg {
		return new EReg(toERegString(globPattern), "");
	}

	public static function toERegString(globPattern:String):String {
		if (globPattern == null || globPattern.length == 0) {
			return globPattern;
		}

		var result:String = CARET;
		final charsLenMinus1:Int = globPattern.length - 1;
		var chPrev:String = null;
		var groupDepth:Int = 0;
		var idx:Int = -1;
		while (idx < charsLenMinus1) {
			idx++;
			var ch:String = globPattern.charAt(idx);
			switch (ch) {
				case BACKSLASH:
					if (chPrev == BACKSLASH)
						result += "\\\\"; // "\\" => "\\"
				case SLASH:
					// "/" => "[\/\\]"
					result += "[\\/\\\\]";
				case DOLLAR:
					// "$" => "\$"
					result += "\\$";
				case QUESTION_MARK:
					if (chPrev == BACKSLASH)
						result += "\\?"; // "\?" => "\?"
					else
						result += "[^\\\\^\\/]"; // "?" => "[^\\^\/]"
				case DOT:
					// "." => "\."
					result += "\\.";
				case BRACKET_ROUND_LEFT:
					// "(" => "\("
					result += "\\(";
				case BRACKET_ROUND_RIGHT:
					// ")" => "\)"
					result += "\\)";
				case BRACKET_CURLY_LEFT:
					if (chPrev == BACKSLASH)
						result += "\\{"; // "\{" => "\{"
					else {
						groupDepth++;
						result += BRACKET_ROUND_LEFT;
					}
				case BRACKET_CURLY_RIGHT:
					if (chPrev == BACKSLASH)
						result += "\\}"; // "\}" => "\}"
					else {
						groupDepth--;
						result += BRACKET_ROUND_RIGHT;
					}
				case COMMA:
					if (chPrev == BACKSLASH)
						result += "\\,"; // "\," => "\,"
					else {
						// "," => "|" if in group or => "," if not in group
						result += (groupDepth > 0 ? PIPE : COMMA);
					}
				case EXCLAMATION_MARK:
					if (chPrev == BRACKET_SQUARE_LEFT)
						result += CARET; // "[!" => "[^"
					else
						result += ch;
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
