/**
 *    Copyright (c) 2009, Adobe Systems, Incorporated
 *    All rights reserved.
 *
 *    Redistribution  and  use  in  source  and  binary  forms, with or without
 *    modification,  are  permitted  provided  that  the  following  conditions
 *    are met:
 *
 *      * Redistributions  of  source  code  must  retain  the  above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions  in  binary  form  must reproduce the above copyright
 *        notice,  this  list  of  conditions  and  the following disclaimer in
 *        the    documentation   and/or   other  materials  provided  with  the
 *        distribution.
 *      * Neither the name of the Adobe Systems, Incorporated. nor the names of
 *        its  contributors  may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 *
 *    THIS  SOFTWARE  IS  PROVIDED  BY THE  COPYRIGHT  HOLDERS AND CONTRIBUTORS
 *    "AS IS"  AND  ANY  EXPRESS  OR  IMPLIED  WARRANTIES,  INCLUDING,  BUT NOT
 *    LIMITED  TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *    PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 *    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,  INCIDENTAL,  SPECIAL,
 *    EXEMPLARY,  OR  CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT  LIMITED TO,
 *    PROCUREMENT  OF  SUBSTITUTE   GOODS  OR   SERVICES;  LOSS  OF  USE,  DATA,
 *    OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *    LIABILITY,  WHETHER  IN  CONTRACT,  STRICT  LIABILITY, OR TORT (INCLUDING
 *    NEGLIGENCE  OR  OTHERWISE)  ARISING  IN  ANY  WAY  OUT OF THE USE OF THIS
 *    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.as3commons.asblocks.parser.impl
{

import flash.utils.Dictionary;

import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.api.ITokenizer;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.core.Token;
import org.as3commons.asblocks.parser.core.TokenEntry;
import org.as3commons.asblocks.parser.core.Tokens;

public class AS3Tokenizer implements ITokenizer
{
	protected static var IGNORED_TOKENS:Dictionary = new Dictionary();
	
	protected static var IGNORING_LINE_TOKENS:Dictionary = new Dictionary();
	
	public function AS3Tokenizer()
	{
		//IGNORED_TOKENS[Operators.SEMI_COLUMN] = true;
		//IGNORED_TOKENS[Operators.LEFT_CURLY_BRACKET] = true;
		//IGNORED_TOKENS[Operators.RIGHT_CURLY_BRACKET] = true;
		IGNORED_TOKENS[AS3Parser.NEW_LINE] = true;
		
		//IGNORING_LINE_TOKENS[KeyWords.IMPORT] = true;
		//IGNORING_LINE_TOKENS[KeyWords.PACKAGE] = true;
	}
	
	public function tokenize(tokens:ISourceCode, tokenEntries:Tokens):void
	{
		var scanner:IScanner = initializeScanner(tokens);
		var currentToken:Token = scanner.nextToken();
		
		var inSkipLine:int = 0;
		
		try 
		{
			while (currentToken != null	&& currentToken.text != KeyWords.EOF)
			{
				var currentTokenText:String = currentToken.text;
				var currentTokenLine:int = currentToken.line;
				
				if (!isTokenIgnored(currentTokenText))
				{
					if (isTokenIgnoringLine(currentTokenText))
					{
						inSkipLine = currentTokenLine;
					}
					else
					{
						if (inSkipLine == 0 || inSkipLine != currentTokenLine)
						{
							inSkipLine = 0;
							tokenEntries.add(new TokenEntry(
								currentTokenText,
								tokens.filePath,
								currentTokenLine));
						}
					}
				}
				
				currentToken = scanner.nextToken();
			}
		}
		catch (e:Error)
		{
		}
		finally 
		{
			tokenEntries.add(TokenEntry.getEOF());
		}
	}
	
	protected function initializeScanner(tokens:ISourceCode):IScanner
	{
		var scanner:AS3Scanner = new AS3Scanner();
		scanner.setLines(Vector.<String>(tokens.code.split(AS3Parser.NEW_LINE)));
		return scanner;
	}
	
	protected function isTokenIgnored(tokenText:String):Boolean
	{
		//return IGNORED_TOKENS[tokenText]
		//|| tokenText.indexOf(AS3Parser.MULTIPLE_LINES_COMMENT) == 0
		//	|| tokenText.indexOf(AS3Parser.SINGLE_LINE_COMMENT) == 0;
		return IGNORED_TOKENS[tokenText]
	}
	
	protected function isTokenIgnoringLine(tokenText:String):Boolean
	{
		return IGNORING_LINE_TOKENS[tokenText];
	}
}
}