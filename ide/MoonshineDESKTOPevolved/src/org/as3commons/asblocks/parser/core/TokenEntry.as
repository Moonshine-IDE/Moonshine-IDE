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

package org.as3commons.asblocks.parser.core
{

/**
 * A token entry with text, sourdce id and start line. 
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TokenEntry
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  text
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _text:String;
	
	/**
	 * The token String text.
	 */
	public function get text():String
	{
		return _text;
	}
	
	/**
	 * @private
	 */	
	public function set text(value:String):void
	{
		_text = value;
	}
	
	//----------------------------------
	//  tokenSrcID
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _tokenSrcID:String;
	
	/**
	 * The token source it, usually a file name.
	 */
	public function get tokenSrcID():String
	{
		return _tokenSrcID;
	}
	
	/**
	 * @private
	 */	
	public function set tokenSrcID(value:String):void
	{
		_tokenSrcID = value;
	}
	
	//----------------------------------
	//  startLine
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _startLine:int;
	
	/**
	 * The token start line in the source.
	 */
	public function get startLine():int
	{
		return _startLine;
	}
	
	/**
	 * @private
	 */	
	public function set startLine(value:int):void
	{
		_startLine = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 * 
	 * @param text The token String text.
	 * @param tokenSrcID The token source it, usually a file name.
	 * @param startLine The token start line in the source.
	 */
	public function TokenEntry(text:String, tokenSrcID:String, startLine:int)
	{
		_text = text;
		_tokenSrcID = tokenSrcID;
		_startLine = startLine;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Returns an End Of Line TokenEntry, '__END__'.
	 * 
	 * @return An EOF TokenEntry.
	 */
	public static function getEOF():TokenEntry
	{
		return new TokenEntry("__END__", null, -1);
	}
}
}