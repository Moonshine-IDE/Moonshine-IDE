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

import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * A parser node that does not contain parser node children.
 * 
 * <p>Initial API; Adobe Systems, Incorporated</p>
 * 
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
public class Node extends NestedNode implements IParserNode
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  start
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _start:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#start
	 */
	public function get start():int
	{
		return _start;
	}
	
	/**
	 * @private
	 */
	public function set start(value:int):void
	{
		_start = value;
	}
	
	//----------------------------------
	//  end
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _end:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#end
	 */
	public function get end():int
	{
		return _end;
	}
	
	/**
	 * @private
	 */
	public function set end(value:int):void
	{
		_end = value;
	}
	
	//----------------------------------
	//  column
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _column:int;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#column
	 */
	public function get column():int
	{
		return _column;
	}
	
	/**
	 * @private
	 */
	public function set column(value:int):void
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
	 * @copy org.as3commons.as3parser.api.IParserNode#line
	 */
	public function get line():int
	{
		return _line;
	}
	
	/**
	 * @private
	 */
	public function set line(value:int):void
	{
		_line = value;
	}
	
	//----------------------------------
	//  stringValue
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _stringValue:String;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#stringValue
	 */
	public function get stringValue():String
	{
		return _stringValue;
	}
	
	/**
	 * @private
	 */
	public function set stringValue(value:String):void
	{
		_stringValue = value;
	}
	
	//----------------------------------
	//  startToken
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _startToken:LinkedListToken;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#startToken
	 */
	public function get startToken():LinkedListToken
	{
		return _startToken;
	}
	
	/**
	 * @private
	 */	
	public function set startToken(value:LinkedListToken):void
	{
		if (parent)
			TokenNode(parent).notifyChildStartTokenChange(this, value);
		
		_startToken = value;
	}
	
	//----------------------------------
	//  stopToken
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _stopToken:LinkedListToken;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#stopToken
	 */
	public function get stopToken():LinkedListToken
	{
		return _stopToken;
	}
	
	/**
	 * @private
	 */	
	public function set stopToken(value:LinkedListToken):void
	{
		if (parent)
			TokenNode(parent).notifyChildStopTokenChange(this, value);
		
		_stopToken = value;
	}
	
	//----------------------------------
	//  initialInsertionAfter
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _initialInsertionAfter:LinkedListToken;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#initialInsertionAfter
	 */
	public function get initialInsertionAfter():LinkedListToken
	{
		return _initialInsertionAfter;
	}
	
	/**
	 * @private
	 */	
	public function set initialInsertionAfter(value:LinkedListToken):void
	{
		_initialInsertionAfter = value;
	}
	
	//----------------------------------
	//  initialInsertionBefore
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _initialInsertionBefore:LinkedListToken;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#initialInsertionBefore
	 */
	public function get initialInsertionBefore():LinkedListToken
	{
		return _initialInsertionBefore;
	}
	
	/**
	 * @private
	 */	
	public function set initialInsertionBefore(value:LinkedListToken):void
	{
		_initialInsertionBefore = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 * 
	 * @param kind The parser node kind.
	 * @param line The parser node line.
	 * @param column The parser node column.
	 * @param stringValue The parser node stringValue.
	 */
	public function Node(kind:String,
						 line:int,
						 column:int,
						 stringValue:String)
	{
		super(kind, null);
		
		_line = line;
		_column = column;
		_stringValue = stringValue;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function toString():String
	{
		return kind;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>Node</code> instance.
	 * 
	 * @param kind A String <code>NodeKind</code> indicating the kind of node.
	 * @param line The Integer line number.
	 * @param column The Integer column number.
	 * @param stringValue The String value of the node, can be null.
	 * @return A new <code>Node</code> instance.
	 * @deprecated
	 */
	public static function create(kind:String,
								  line:int,
								  column:int,
								  stringValue:String = null):Node
	{
		return new Node(kind, line, column, stringValue);
	}
	
	/**
	 * Creates a new <code>Node</code> instance that will parent the
	 * <code>child</code>.
	 * 
	 * @param kind A String <code>NodeKind</code> indicating the kind of node.
	 * @param line The Integer line number.
	 * @param column The Integer column number.
	 * @param child The <code>Node</code> that will be added as a child to the
	 * new <code>Node</code> created and returned.
	 * @return A new <code>Node</code> instance that is parenting the 
	 * <code>child</code> node.
	 * @deprecated
	 */
	public static function createChild(kind:String,
									   line:int,
									   column:int,
									   child:IParserNode):Node
	{
		var node:Node = new Node(kind, line, column, null);
		node.addChild(child);
		return node;
	}
}
}