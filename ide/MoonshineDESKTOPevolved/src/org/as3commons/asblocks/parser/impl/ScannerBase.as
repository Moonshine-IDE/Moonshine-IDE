////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.parser.impl
{

import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.core.Token;

/**
 * The default base implementation of the IScanner interface.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ScannerBase implements IScanner
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * An end line.
	 */
	public static const END:String = "__END__";
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The line Vector to scan.
	 */
	protected var lines:Vector.<String>;
	
	/**
	 * The current line scanned.
	 */
	protected var line:int;
	
	/**
	 * The current column scanned.
	 */
	protected var column:int;
	
	/**
	 * The last non whitespace charater scanned.
	 */
	protected var lastNonWhiteSpaceCharacter:String;
	
	//--------------------------------------------------------------------------
	//
	//  IScanner API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  allowWhiteSpace
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _allowWhiteSpace:Boolean;
	
	/**
	 * @copy org.as3commons.as3parser.api.IScanner#allowWhiteSpace
	 */
	public function get allowWhiteSpace():Boolean
	{
		return _allowWhiteSpace;
	}
	
	/**
	 * @private
	 */	
	public function set allowWhiteSpace(value:Boolean):void
	{
		_allowWhiteSpace = value;
	}
	
	//----------------------------------
	//  offset
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _offset:int = 0;
	
	/**
	 * @copy org.as3commons.as3parser.api.IScanner#offset
	 */
	public function get offset():int
	{
		return _offset;
	}
	
	/**
	 * @private
	 */	
	public function set offset(value:int):void
	{
		_offset = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ScannerBase()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  IScanner API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.as3parser.api.IScanner#setLines()
	 */
	public function setLines(lines:Vector.<String>):void
	{
		this.lines = lines;
		line = 0;
		column = -1;
		lastNonWhiteSpaceCharacter = null;
		
		_offset = -1;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IScanner#nextToken()
	 */
	public function nextToken():Token
	{
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected Final :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Advances the offest/column and finds the next character of 
	 * the current line.
	 */
	protected final function nextChar():String
	{
		var currentLine:String = lines[line];
		var lastColumn:int = column;
		
		_offset++;
		column++;
		
		if (currentLine.length <= column)
		{
			column = -1;
			line++;
			if (line == lines.length)
				return END;
			
			return "\n";
		}
		
		var oldCharacter:String = currentLine.charAt(lastColumn);
		if (oldCharacter != " " && oldCharacter != "\t")
		{
			lastNonWhiteSpaceCharacter = oldCharacter;
		}
		
		var character:String = currentLine.charAt(column);
		
		// move past the BOM (if any)
		while (character == "\uFEFF")
		{
			column++;
			character = currentLine.charAt(column);
		}
		
		return character;
	}
	
	/**
	 * A look ahead specified by the offset. If the offset calculates passed
	 * the line length, a \n is returned.
	 */
	protected final function peekChar(offset:int):String
	{
		var currentLine:String = lines[line];
		var index:int = column + offset;
		
		if (index >= currentLine.length)
		{
			return "\n";
		}
		
		return currentLine.charAt(index);
	}
	
	/**
	 * Skips a character by calling nextChar();
	 */
	protected final function skipChar():void
	{
		nextChar();
	}
	
	/**
	 * Skips a predetermined amount of charatcters.
	 */
	protected final function skipChars(count:int):void
	{
		var decrementCount:int = count;
		
		while (decrementCount-- > 0)
		{
			nextChar();
		}
	}
	
	/**
	 * Returns whether the character is an identifier.
	 */
	protected function isIdentifierCharacter(currentCharacter:String):Boolean
	{
		var code:int = currentCharacter.charCodeAt(0);
		var isNum:Boolean = (code > 47 && code < 58);
		var isLower:Boolean = (code > 96 && code < 123);
		var isUpper:Boolean = (code > 64 && code < 91);		
		
		return isUpper || isLower || isNum 
			|| currentCharacter == '_' || currentCharacter == '$';
	}
	
	/**
	 * Scans until delimiter is found.
	 */
	protected final function scanUntilDelimiter(start:String, 
												delimiter:String = null):Token
	{
		if (delimiter == null)
			delimiter = start;
		
		var buffer:String = "";
		
		var peekPos:int = 1;
		var numberOfBackslashes:int = 0;
		
		buffer += start;
		
		for ( ;; )
		{
			var currentCharacter:String = peekChar(peekPos++);
			
			if (currentCharacter == '\n')
			{
				return null;
			}
			
			buffer += currentCharacter;
			
			if (currentCharacter == delimiter && numberOfBackslashes == 0)
			{
				var result:Token = Token.create(buffer.toString(), line, column);
				skipChars(buffer.length - 1);
				return result;
			}
			numberOfBackslashes = currentCharacter == "\\" 
				? (numberOfBackslashes + 1) % 2 : 0;
		}
		
		return null;
	}
	
	/**
	 * Scans a single character.
	 */
	protected final function scanSingleCharacterToken(character:String):Token
	{
		return new Token(character, line, column);
	}
	
	/**
	 * Find the longest matching sequence.
	 */
	protected final function scanCharacterSequence(currentCharacter:String, 
												   possibleMatches:Array):Token
	{
		var peekPos:int = 1;
		var buffer:String = "";
		var maxLength:int = computePossibleMatchesMaxLength(possibleMatches);
		
		buffer += currentCharacter;
		
		var found:String = buffer.toString();
		while (peekPos < maxLength)
		{
			buffer += peekChar(peekPos);
			
			peekPos++;
			var len:int = possibleMatches.length;
			for (var i:int = 0; i < len; i++)
			{
				if (buffer.toString() == possibleMatches[i])
				{
					found = buffer.toString();
				}
			}
		}
		
		if (found == "")
		{
			return null;
		}
		
		var result:Token = new Token(found, line, column);
		skipChars(found.length - 1);
		return result;
	}
	
	/**
	 * @private
	 */
	protected final function computePossibleMatchesMaxLength(possibleMatches:Array):int
	{
		var max:int = 0;
		
		var len:int = possibleMatches.length;
		for (var i:int = 0; i < len; i++)
		{
			max = Math.max(max, possibleMatches[i].length);
		}
		return max;
	}
	
	//----------------------------------
	//  Strings
	//----------------------------------
	
	/**
	 * Something started with a quote or double quote consume characters until
	 * the quote/double quote shows up again and is not escaped
	 */
	protected final function scanString(startingCharacter:String):Token
	{
		return scanUntilDelimiter(startingCharacter);
	}	
	
	/**
	 * Scans a word at a start, only allowing identifier characters.
	 */
	protected final function scanWord(startingCharacter:String):Token
	{
		var currentChar:String = startingCharacter;
		
		var buffer:String = "";
		buffer += currentChar;
		
		var peekPos:int = 1;
		for ( ;; )
		{
			currentChar = peekChar(peekPos++);
			if (!isIdentifierCharacter(currentChar))
			{
				break;
			}
			
			buffer += currentChar;
		}
		var result:Token = new Token(buffer.toString(), line, column);
		skipChars(buffer.toString().length - 1);
		return result;
	}
	
	/**
	 * Returns the next character that is not a \s or \t. Newlines should
	 * not be here since we are using a line Vector.
	 */
	protected function nextNonWhitespaceCharacter():String
	{
		var result:String;
		
		do
		{
			result = nextChar();
		}
		while (result == " " || result == "\t");
		
		return result;
	}
	
	/**
	 * Returns the remaining line.
	 */
	protected final function getRemainingLine():String
	{
		return lines[line].substring(column);
	}
	
	// UTIL -----------------------------------------------------------------
	
	/**
	 * @private
	 */
	public static function isHexChar(currentCharacter:String):Boolean
	{
		var code:Number = currentCharacter.charCodeAt(0);
		var isNum:Boolean = (code > 47 && code < 58);
		var isLower:Boolean = (code > 96 && code < 123);
		var isUpper:Boolean = (code > 64 && code < 91);
		
		return isNum || isLower || isUpper;
	}
	
	/**
	 * @private
	 */
	public static function isDecimalChar(currentCharacter:String):Boolean
	{
		var code:int = currentCharacter.charCodeAt(0);
		return (code > 47 && code < 58);
	}
}
}