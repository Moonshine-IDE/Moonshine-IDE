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
package org.as3commons.asblocks.parser.core
{

import org.as3commons.asblocks.parser.api.IToken;

/**
 * A Token represents a piece of text in a string of data with location
 * properties.
 * 
 * <p>Initial API; Adobe Systems, Incorporated</p>
 * 
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
public class Token implements IToken
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  column
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _column:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.IToken#column
	 */
	public final function get column():int
	{
		return _column;
	}
	
	/**
	 * @private
	 */
	public final function set column(value:int):void
	{
		_column = value;
	}
	
	//----------------------------------
	//  line
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _line:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.IToken#line
	 */
	public final function get line():int
	{
		return _line;
	}
	
	/**
	 * @private
	 */
	public final function set line(value:int):void
	{
		_line = value;
	}
	
	//----------------------------------
	//  kind
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _kind:String;
	
	/**
	 * The token's kind.
	 */
	public final function get kind():String
	{
		return _kind;
	}
	
	/**
	 * @private
	 */
	public final function set kind(value:String):void
	{
		_kind = value;
	}
	
	//----------------------------------
	//  text
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _text:String;
	
	/**
	 * @copy org.as3commons.as3parser.api.IToken#text
	 */
	public final function get text():String
	{
		return _text;
	}
	
	/**
	 * @private
	 */
	public final function set text(value:String):void
	{
		_text = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function Token(text:String, line:int = -1, column:int = -1)
	{
		_text = text;
		_line = line + 1;
		_column = column + 1;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new Token.
	 * 
	 * @param text The Token text String.
	 * @param line The line number the Token is found on.
	 * @param column The column the Token starts at.
	 * @return A new Token instance.
	 */
	public static function create(text:String, 
								  line:int = -1, 
								  column:int = -1):Token
	{
		return new Token(text, line, column);
	}
}
}