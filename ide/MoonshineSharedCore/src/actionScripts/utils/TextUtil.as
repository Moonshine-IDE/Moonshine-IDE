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
	import flash.geom.Point;
	import flash.xml.XMLNode;

	import 	mx.utils.Base64Encoder;
    import  mx.utils.Base64Decoder;
    import  flash.utils.ByteArray;
	
	public class TextUtil
	{
		private static const NON_WORD_CHARACTERS:Vector.<String> = new <String>[" ", "\t", ".", ":", ";", ",", "?", "+", "-", "*", "/", "%", "=", "!", "&", "|", "(", ")", "[", "]", "{", "}", "<", ">"];

		public static function startOfWord(line:String, charIndex:int):int
		{
			var startChar:int = 0;
			for(var i:int = charIndex - 1; i >= 0; i--)
			{
				var char:String = line.charAt(i);
				if(NON_WORD_CHARACTERS.indexOf(char) !== -1)
				{
					//include the next character, but not this
					//one, because it's not part of the word
					startChar = i + 1;
					break;
				}
			}
			return startChar;
		}

		public static function endOfWord(line:String, charIndex:int):int
		{
			var endChar:int = line.length;
			for(var i:int = charIndex + 1; i < endChar; i++)
			{
				var char:String = line.charAt(i);
				if(NON_WORD_CHARACTERS.indexOf(char) !== -1)
				{
					endChar = i;
					break;
				}
			}
			return endChar;
			
		}
		
		// Find word boundary from the beginning of the line
		public static function wordBoundaryForward(line:String):int
		{
			return line.length - line.replace(/^(?:\s+|[^\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*|[,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*)/,"").length; 
		}
		
		// Find word boundary from the end of the line
		public static function wordBoundaryBackward(line:String):int
		{
			return line.length - line.replace(/(?:\s+|[^\s,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*|[,(){}\[\]\-+*%\/="'~!&|<>?:;.]+\s*)$/,"").length; 
		}
		
		// Get amount of indentation on line
		public static function indentAmount(line:String):int
		{
			var indent:int = line.length - line.replace(/^\t+/,"").length;
			if (indent > 0)
			{
				return indent;
			}
			
			return 0;
		}
		
		// Get amount of indention combining space and tabs on line
		public static function indentAmountBySpaceAndTab(line:String):Object
		{
			var tmpLine:String = line.replace(/^(\s+).*$/, "$1");
			var num_spaces:int = tmpLine.length - tmpLine.replace(/[ ]/g, "").length;
			var num_tabs:int = tmpLine.length - tmpLine.replace(/\t/g, "").length;
			
			return {space: num_spaces, tab: num_tabs};
		}
		
		// Count digits in decimal number
		public static function digitCount(num:int):int
		{
			return Math.floor(Math.log(num)/Math.log(10))+1;
		}
		
		// Escape a string so it can be fed into a new RegExp
		public static function escapeRegex(str:String):String {
			return str.replace(/[\$\(\)\*\+\.\[\]\?\\\^\{\}\|]/g,"\\$&");
		}
		
		// Repeats a string N times
		public static function repeatStr(str:String, count:uint):String {
			return new Array(count+1).join(str);
		}
		
		// Pad a string to 'len' length with 'char' characters
		public static function padLeft(str:String, len:uint, char:String = "0"):String {
			return repeatStr(char, len - str.length) + str;
		}
		
		// Return lineIdx/charIdx from charIdx
		public static function charIdx2LineCharIdx(str:String, charIdx:int, lineDelim:String):Point
		{
			var line:int = str.substr(0,charIdx).split(lineDelim).length - 1;
			var chr:int = line > 0 ? charIdx - str.lastIndexOf(lineDelim, charIdx - 1) - lineDelim.length : charIdx;
        	return new Point(line, chr);
		} 
		
		// Return charIdx from lineIdx/charIdx
		public static function lineCharIdx2charIdx(str:String, lineIdx:int, charIdx:int, lineDelim:String):int
		{
			return (
				str.split(lineDelim).slice(0,lineIdx).join("").length	// Predecing lines' lengths
				+ lineIdx * lineDelim.length							// Preceding delimiters' lengths
				+ charIdx												// Current line's length
			);
		}
		
		public static function htmlUnescape(str:String):String
		{
    		return new XML(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String
		{
    		return new XMLNode( 3, str ).toString();
		}


		public static function base64Encode(str:String, charset:String = "UTF-8"):String{
			if((str==null)){
				return "";
			}
			var base64:Base64Encoder = new Base64Encoder();
			base64.insertNewLines = false;
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(str, charset);
			base64.encodeBytes(byte);
			return base64.toString();
		}
		
		public static function base64Decode(str:String, charset:String = "UTF-8"):String{
			if((str==null)){
				return "";
			}
			var base64:Base64Decoder = new Base64Decoder();
			base64.decode(str);
			var byteArray:ByteArray = base64.toByteArray();
			return byteArray.readMultiByte(byteArray.length, charset);;
		}

	}
}