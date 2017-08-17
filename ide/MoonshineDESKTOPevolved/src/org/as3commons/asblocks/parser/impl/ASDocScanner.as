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

import org.as3commons.asblocks.parser.core.Token;

/**
 * A scanner that is (/~~ ~/) or (<!--- -->) asdoc domain aware.
 *
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ASDocScanner extends ScannerBase
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * An end of file.
	 */
	public static const EOF:String = "__END__";
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	internal var isWhiteSpace:Boolean = false;
	
	/**
	 * @private
	 */
	private var length:int = -1;
	
	/**
	 * @private
	 */
	private var map:Object;
	
	/**
	 * @private
	 */
	private var inPre:Boolean = false;
	
	/**
	 * @private
	 */
	private var inInlineTag:Boolean = false;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ASDocScanner()
	{
		super();
		
		allowWhiteSpace = true;
	}
	
	//--------------------------------------------------------------------------
	//
	// Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function setLines(lines:Vector.<String>):void
	{
		super.setLines(lines);
		
		inPre = false;
		inInlineTag = false;
		isWhiteSpace = true;
		length = getLength();
		
		map = {};
		
		map["/**"] = "ml-start";
		map["*/"] = "ml-end";
		map["*"] = "astrix";
		map[" "] = "ws";
		map["\t"] = "ws";
		map["\n"] = "nl";
		map["__END__"] = "eof";
	}
	
	/**
	 * @private
	 */
	override public function nextToken():Token
	{
		var currentCharacter:String;
		var token:Token;
		
		if (lines != null && line < lines.length)
		{
			currentCharacter = nextChar();
		}
		
		if (currentCharacter == EOF)
		{
			token = new Token(EOF, line, column);
		}
		
		if (currentCharacter == "<")
		{
			token = scanCharacterSequence(currentCharacter, 
				["</", "<listing", "<pre", "<code", "<p",
					"<strong", "<i", "<ul", "<li"]);
			
			if (token.text == "<pre" || token.text == "<listing")
			{
				inPre = true;
			}
		}
		
		if (currentCharacter == " "
			|| currentCharacter == "\n"
			|| currentCharacter == ">"
			|| currentCharacter == "@")
		{
			token = scanSingleCharacterToken(currentCharacter);
		}
		
		if (currentCharacter == "/")
		{
			token = scanCharacterSequence(currentCharacter, ["/**", "/>"]);
			
			if (token.text == "/>")
			{
				inPre = false;
			}
		}
		
		if (currentCharacter == "*")
		{
			token = scanCharacterSequence(currentCharacter, ["*/"]);
		}
		
		if (currentCharacter == "{")
		{
			token = scanCharacterSequence(currentCharacter, ["{@"]);
			
			if (token.text == "{@")
			{
				inInlineTag = true;
			}
		}
		
		if (inInlineTag && currentCharacter == "}")
		{
			token = scanSingleCharacterToken(currentCharacter);
			inInlineTag = false;
		}
		
		if (token == null)
		{
			token = scanWord(currentCharacter);
			if (token != null)
			{
				isWhiteSpace = false;
			}
		}
		
		if (token.text == "\n")
		{
			isWhiteSpace = true;
		}
		
		commitKind(token);
		
		return token;
	}
	
	/**
	 * @private
	 */
	private function commitKind(token:Token):void
	{
		var result:String = map[token.text];
		if (token.text == "/**" || token.text == "*/" || token.text == "__END__")
		{
			token.kind = result;
			return;
		}
		
		if (result == null || !isWhiteSpace)
		{
			result = "text";
		}
		
		if (inPre && token.text == "*")
		{
			isWhiteSpace = false;
		}
		
		token.kind = result;
	}
	
	/**
	 * @private
	 */
	private function getLength():int
	{
		var len:int = 0;
		for each (var line:String in lines)
		{
			len += line.length;
		}
		return len;
	}
}
}