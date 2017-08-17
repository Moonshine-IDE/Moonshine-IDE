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

package org.as3commons.mxmlblocks.parser.impl
{

import org.as3commons.asblocks.parser.api.ISourceCodeScanner;
import org.as3commons.asblocks.parser.core.Token;
import org.as3commons.asblocks.parser.impl.ScannerBase;

/**
 * A scanner that is .mxml domain aware.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MXMLScanner extends ScannerBase implements ISourceCodeScanner
{
	//--------------------------------------------------------------------------
	//
	//  ISourceCodeScanner API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  commentLine
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _commentLine:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.ISourceCodeScanner#commentLine
	 */
	public function get commentLine():int
	{
		return _commentLine;
	}
	
	/**
	 * @private
	 */	
	public function set commentLine(value:int):void
	{
		_commentLine = value;
	}
	
	//----------------------------------
	//  commentColumn
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _commentColumn:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.ISourceCodeScanner#commentColumn
	 */
	public function get commentColumn():int
	{
		return _commentColumn;
	}
	
	/**
	 * @private
	 */	
	public function set commentColumn(value:int):void
	{
		_commentColumn = value;
	}
	
	//----------------------------------
	//  inBlock
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _inBlock:Boolean = false;
	
	/**
	 * @copy org.as3commons.as3parser.api.ISourceCodeScanner#inBlock
	 */
	public function get inBlock():Boolean
	{
		return _inBlock;
	}
	
	/**
	 * @private
	 */	
	public function set inBlock(value:Boolean):void
	{
		_inBlock = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function MXMLScanner()
	{
		super();
		
		allowWhiteSpace = true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function nextToken():Token
	{
		var currentCharacter:String;
		var token:Token;
		
		// while we have lines and are not at the end
		if (lines != null && line < lines.length)
		{
			if (allowWhiteSpace)
			{
				currentCharacter = nextChar();
			}
			else
			{
				currentCharacter = nextNonWhitespaceCharacter();
			}
		}
		else
		{
			// at the end, send the line terminator
			return new Token(END, line, column);
		}
		
		if (line == lines.length)
		{
			return new Token(END, line, column);
		}
		
		if (currentCharacter == '"')
		{
			return scanString(currentCharacter);
		}
		
		if (currentCharacter == '\'')
		{
			return scanString(currentCharacter);
		}
		
		if (allowWhiteSpace)
		{
			if (currentCharacter == ' ' || currentCharacter == '\t'
				|| currentCharacter == '\n')
			{
				return scanSingleCharacterToken(currentCharacter);
			}
		}
		
		if (currentCharacter == ' ' && allowWhiteSpace)
		{
			return scanSingleCharacterToken(currentCharacter);
		}
		
		if (currentCharacter == ':' || currentCharacter == '.')
		{
			return scanSingleCharacterToken(currentCharacter);
		}
		
		if (currentCharacter == '/')
		{
			token =	scanCharacterSequence(currentCharacter, ["/>"]);
			
			return token;
		}
		
		if (currentCharacter == '<')
		{
			token =	scanCharacterSequence(currentCharacter,
				["</", "<!---", "<!--", "<?", "<![CDATA["]);
			
			if (token.text == "<!--")
			{
				return scanMultiLineComment();
			}
			
			if (token.text == "<!---")
			{
				return scanDocMultiLineComment();
			}
			
			if (token.text == "<![CDATA[")
			{
				return scanCData();
			}
			
			return token;
		}
		
		if (currentCharacter == ']')
		{
			token =	scanCharacterSequence(currentCharacter, ["]]>"]);
			
			allowWhiteSpace = false;
			
			return token;
		}
		
		if (currentCharacter == '-')
		{
			token =	scanCharacterSequence(currentCharacter, ["-->"]);
			
			allowWhiteSpace = false;
			
			return token;
		}
		
		if (currentCharacter == '?')
		{
			token =	scanCharacterSequence(currentCharacter, ["?>"]);
			
			return token;
		}
		
		return scanWord(currentCharacter);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function nextNonWhitespaceCharacter():String
	{
		if (allowWhiteSpace)
		{
			return nextChar();
		}
		
		var result:String;
		do
		{
			result = nextChar();
		}
		while ((result == ' ' && !allowWhiteSpace) || result == '\t'
			|| result == '\n');
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function scanMultiLineComment():Token
	{
		var buffer:String = "";
		var currentCharacter:String = " ";
		var previousCharacter:String = " ";
		
		buffer += "<!--";
		//skipChar();
		do
		{
			previousCharacter = currentCharacter;
			currentCharacter = nextChar();
			buffer += currentCharacter;
		}
		while (currentCharacter != null
			&& !(currentCharacter == ">" && previousCharacter == "-"));
		
		return new Token(buffer, line, column);
	}
	
	/**
	 * @private
	 */
	private function scanDocMultiLineComment():Token
	{
		var buffer:String = "";
		var currentCharacter:String = " ";
		var previousCharacter:String = " ";
		
		commentLine = line + 1;
		commentColumn = column - 3;
		
		buffer += "<!---";
		//skipChar();
		do
		{
			previousCharacter = currentCharacter;
			currentCharacter = nextChar();
			buffer += currentCharacter;
		}
		while (currentCharacter != null
			&& !(currentCharacter == '>' && previousCharacter == '-'));
		
		return new Token(buffer, line, column);
	}
	
	/**
	 * @private
	 */
	private function scanCData():Token
	{
		var buffer:String = "";
		var currentCharacter:String = " ";
		var previousCharacter:String = " ";
		
		do
		{
			previousCharacter = currentCharacter;
			currentCharacter = nextChar();
			buffer += currentCharacter;
		}
		while (currentCharacter != null
			&& !(currentCharacter == '>' && previousCharacter == ']'));
		
		var token:Token = new Token(buffer.replace("]]>", ""), line, column);
		token.kind = "cdata";
		return token;
	}
}
}