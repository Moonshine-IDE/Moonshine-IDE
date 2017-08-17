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

import org.as3commons.asblocks.parser.api.ISourceCodeScanner;
import org.as3commons.asblocks.parser.core.Token;

/**
 * A port of the Java PMD de.bokelberg.flex.parser.AS3Scanner.
 * 
 * <p>Initial Implementation; Adobe Systems, Incorporated</p>
 * 
 * @author Michael Schmalle
 */
public class AS3Scanner extends ScannerBase implements ISourceCodeScanner
{
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var _inVector:Boolean = false;
	
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
	
	public function moveTo(line:int, column:int):void
	{
		this.line = line;
		this.column = column;
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
	public function AS3Scanner()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Moves the scanner to the next token.
	 * 
	 * @return The next <code>Token</code>.
	 */
	override public function nextToken():Token
	{
		var currentCharacter:String;
		var lastCharacter:String;
		
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
			return new Token(END, line, column);
		}
		
		if (currentCharacter == END)
		{
			return new Token(END, line, column);
		}
		if (currentCharacter == "\n")
		{
			return new Token("\n", line, column);
		}
		if (currentCharacter == " ")
		{
			return new Token(" ", line, column);
		}
		if (currentCharacter == "\t")
		{
			return new Token("\t", line, column);
		}
		if (currentCharacter == '/')
		{
			return scanCommentRegExpOrOperator();
		}
		if (currentCharacter == '"')
		{
			return scanString(currentCharacter);
		}
		if (currentCharacter == '\'')
		{
			return scanString(currentCharacter);
		}
		
		if (currentCharacter == '<')
		{
			return scanXMLOrOperator(currentCharacter);
		}
		
		var code:Number = currentCharacter.charCodeAt(0);
		
		// number or dot
		if (code > 47 && code < 58 || currentCharacter == '.')
		{
			return scanNumberOrDots(currentCharacter);
		}
		if (currentCharacter == '{'
			|| currentCharacter == '}' || currentCharacter == '(' || currentCharacter == ')'
			|| currentCharacter == '[' || currentCharacter == ']'
			// a number can start with a dot as well, see number || c == '.'
			|| currentCharacter == ';' || currentCharacter == ',' || currentCharacter == '?'
			|| currentCharacter == '~')
		{
			return scanSingleCharacterToken(currentCharacter);
		}
		if (currentCharacter == ':')
		{
			return scanCharacterSequence(currentCharacter, ["::"]);
		}
		if (currentCharacter == '*')
		{
			// specail case for the atrix type :*
			if (lastNonWhiteSpaceCharacter == ":")
			{
				return scanSingleCharacterToken(currentCharacter);
			}
			
			return scanCharacterSequence(currentCharacter, ["*="]);
		}
		if (currentCharacter == '+')
		{
			return scanCharacterSequence(currentCharacter, ["++", "+="]);
		}
		if (currentCharacter == '-')
		{
			return scanCharacterSequence(currentCharacter, ["--", "-=", "-Infinity"]);
		}
		if (currentCharacter == '%')
		{
			return scanCharacterSequence(currentCharacter, ["%="]);
		}
		if (currentCharacter == '&')
		{
			return scanCharacterSequence(currentCharacter, ["&&=", "&&", "&="]);
		}
		if (currentCharacter == '|')
		{
			return scanCharacterSequence(currentCharacter, ["||=", "||", "|="]);
		}
		if (currentCharacter == '^')
		{
			return scanCharacterSequence(currentCharacter, ["^="]);
		}
		if (currentCharacter == '>')
		{
			if (_inVector)
			{
				_inVector = false;
			}
			else
			{
				return scanCharacterSequence(currentCharacter,
					[">>>=",">>>",">>=",">>",">="]);
			}
		}
		if (currentCharacter == '=')
		{
			return scanCharacterSequence(currentCharacter, ["===", "=="]);
		}
		if (currentCharacter == '!')
		{
			return scanCharacterSequence(currentCharacter, ["!==", "!="]);
		}
		if (currentCharacter == '@')
		{
			return scanSingleCharacterToken(currentCharacter);
		}
		
		return scanWord(currentCharacter);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private Utility :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function isProcessingInstruction(text:String):Boolean
	{
		return text.indexOf("<?") == 0;
	}
	
	/**
	 * @private
	 */
	private function isValidXML(text:String):Boolean
	{
		try 
		{
			new XML(text);
		}
		catch (e:Error)
		{
			return false;
		}
		
		return true;
	}
	
	/**
	 * @private
	 */
	private function isValidRegExp(pattern:String):Boolean
	{
		try
		{
			new RegExp(pattern);
		}
		catch (e:Error)
		{
			return false;
		}
		
		return true;
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Private Scanner :: Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  Comments
	//----------------------------------
	
	/**
	 * @private
	 * Something started with a slash This might be a comment, a regexp or an
	 * operator.
	 */
	private function scanCommentRegExpOrOperator():Token
	{
		var firstCharacter:String = peekChar(1);
		
		if (firstCharacter == '/') // '//'
		{
			return scanSingleLineComment();
		}
		if (firstCharacter == '*') // '/*'
		{
			return scanMultiLineComment();
		}
		
		var result:Token = scanRegExp();
		
		if (result != null)
		{
			return result;
		}
		
		if (firstCharacter == '=')
		{
			result = new Token("/=", line, column);
			skipChars(1); // skip the '='
			return result;
		}
		
		// it is a simple divide symbol
		result = new Token("/", line, column);
		return result;
	}
	
	/**
	 * @private
	 * Scans the rest of a line knowing it's a single line comment.
	 * It will then skip all those characters.
	 */
	private function scanSingleLineComment():Token
	{
		var result:Token = new Token(getRemainingLine(), line, column);
		skipChars(result.text.length - 1);
		return result;
	}
	
	/**
	 * @private
	 * Scans a multiline comment, knowing we are at '/~' scan until '~/'
	 * is reached.
	 */
	private function scanMultiLineComment():Token
	{
		var buffer:String = "/*";
		
		var currentCharacter:String = " ";
		var previousCharacter:String = " ";
		
		// Token adds one
		commentLine = line + 1;
		commentColumn = column + 1;
		
		skipChar();
		
		// run the loop until '*/' sequence is encountered
		do
		{
			previousCharacter = currentCharacter;
			currentCharacter = nextChar();
			buffer += currentCharacter;
		}
		while (currentCharacter != null 
			&& !(previousCharacter == "*" && currentCharacter == "/"));
		
		return new Token(buffer, line, column);
	}	
	
	//----------------------------------
	//  Regular Expression
	//----------------------------------
	
	/**
	 * @private
	 * Scan a regular expression and test it by calling new RegExp(test).
	 */
	private function scanRegExp():Token
	{
		var token:Token = scanUntilDelimiter('/');
		
		if (token != null && isValidRegExp(token.text))
		{
			return token;
		}
		
		return null;
	}
	
	//----------------------------------
	//  XML
	//----------------------------------
	
	/**
	 * Something started with a lower sign <
	 * 
	 * @param startingCharacterc
	 * @return
	 */
	private function scanXMLOrOperator(startingCharacterc:String):Token
	{
		var xmlToken:Token = scanXML();
		
		if (xmlToken != null && isValidXML(xmlToken.text))
		{
			return xmlToken;
		}
		return scanCharacterSequence(startingCharacterc,
			[ "<<<=","<<<","<<=","<<","<=" ]);
	}
	
	/**
	 * Try to parse a XML document
	 * 
	 * @return
	 */
	private function scanXML():Token
	{
		var currentLine:int = line;
		var currentColumn:int = column;
		var level:int = 0;
		var buffer:String = "";
		
		var foundInstruction:Boolean = false;
		var currentCharacter:String = '<';
		
		for ( ;; )
		{
			var currentToken:Token = null;
			do
			{
				currentToken = scanUntilDelimiter('<', '>');
				
				// test that this could actually be a tag
				// < 11 && b >
				if (currentToken)
				{
					if (!foundInstruction && currentToken.text.indexOf("<?") != 0)
					{
						try 
						{
							// Error #1090: XML parser failure: element is malformed.
							var x:XML = new XML(currentToken.text.replace(">", "/>"));
						}
						catch (e:Error)
						{
							line = currentLine;
							column = currentColumn;
							return null;
						}
					}
				}
				else
				{
					line = currentLine;
					column = currentColumn;
					return null;
				}
				
				buffer += currentToken.text;
				
				if (isProcessingInstruction(currentToken.text))
				{
					foundInstruction = true;
					
					currentCharacter = nextChar();
					if (currentCharacter == '\n')
					{
						buffer += "\n";
						skipChar();
					}
					currentToken = null;
				}
			}
			while (currentToken == null);
			
			if (currentToken.text.indexOf("</") == 0)
			{
				level--;
			}
			else if (!(currentToken.text.indexOf("/>") == 
				currentToken.text.length - 2))
			{
				level++;
			}
			
			if (level <= 0)
			{
				return new Token(buffer, line, column);
			}
			
			for ( ;; )
			{
				try
				{
					// if for some weird reason the scanner gets passed
					// a non valid spot and finds the end, do a reset
					currentCharacter = nextChar();
				}
				catch (e:RangeError)
				{
					line = currentLine;
					column = currentColumn;
					return null;
				}
				
				if (currentCharacter == '<')
				{
					break;
				}
				
				buffer += currentCharacter;
			}
		}
		return null;
	}
	
	/**
	 * Something started with a number or a dot.
	 * 
	 * @param characterToBeScanned
	 * @return
	 */
	private function scanNumberOrDots(characterToBeScanned:String):Token
	{
		var firstCharacter:String;
		
		if (characterToBeScanned == '.')
		{
			var result:Token = scanDots();
			if (result != null)
			{
				return result;
			}
			
			firstCharacter = peekChar(1);
			if (!isDecimalChar(firstCharacter))
			{
				return new Token(".", line, column);
			}
		}
		if (characterToBeScanned == '0')
		{
			firstCharacter = peekChar(1);
			if (firstCharacter == 'x')
			{
				return scanHex();
			}
		}
		return scanDecimal(characterToBeScanned);
	}	
	
	/**
	 * The first dot has been scanned Are the next chars dots as well?
	 * 
	 * @return
	 */
	private function scanDots():Token
	{
		var secondCharacter:String = peekChar(1);
		var result:Token;
		
		if (secondCharacter == '.')
		{
			var thirdCharacter:String = peekChar(2);
			var text:String = thirdCharacter == '.' ? "..."	: "..";
			result = new Token(text, line, column);
			
			skipChars(text.length - 1);
			
			return result;
		}
		else if (secondCharacter == '<')
		{
			result = new Token(".<", line, column);
			
			skipChars(1);
			
			_inVector = true;
			
			return result;
		}
		
		return null;
	}
	
	/**
	 * we have seen the 0x prefix
	 * 
	 * @return
	 */
	private function scanHex():Token
	{
		var buffer:String = "";
		buffer += "0x";
		
		var peekPos:int = 2;
		for ( ;; )
		{
			var character:String = peekChar(peekPos++);
			
			if (!isHexChar(character))
			{
				break;
			}
			
			buffer += character;
		}
		//var result:Token = new Token(buffer, line, column, true);
		var result:Token = new Token(buffer, line, column);
		skipChars(result.text.length - 1);
		return result;
	}
	
	/**
	 * c is either a dot or a number
	 * 
	 * @return
	 */
	private function scanDecimal(currentCharacter:String):Token
	{
		var currentChar:String = currentCharacter;
		var buffer:String = "";
		
		var peekPos:int = 1;
		// before dot
		while (isDecimalChar(currentChar))
		{
			buffer += currentChar;
			
			currentChar = peekChar(peekPos++);
		}
		// the optional dot
		if (currentChar == '.')
		{
			buffer += currentChar;
			currentChar = peekChar(peekPos++);
			// after the dot
			while (isDecimalChar(currentChar))
			{
				buffer += currentChar;
				currentChar = peekChar(peekPos++);
			}
			// the optional exponent
			if (currentChar == 'E')
			{
				buffer += currentChar;
				currentChar = peekChar(peekPos++);
				while (isDecimalChar(currentChar))
				{
					buffer += currentChar;
					currentChar = peekChar(peekPos++);
				}
			}
		}
		//var result:Token = new Token(buffer, line, column, true);
		var result:Token = new Token(buffer, line, column);
		skipChars(result.text.length - 1);
		return result;
	}
}
}