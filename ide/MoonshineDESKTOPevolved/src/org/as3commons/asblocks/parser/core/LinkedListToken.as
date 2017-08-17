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

import flash.errors.IllegalOperationError;

import org.as3commons.asblocks.ASBlocksSyntaxError;

/**
 * A linked list token implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class LinkedListToken extends Token
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  channel
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _channel:String;
	
	/**
	 * doc
	 */
	public function get channel():String
	{
		if (_channel == null)
		{
			if (text == "\n" || text == "\n" || text == " ")
				return "hidden";
		}
		return _channel;
	}
	
	/**
	 * @private
	 */	
	public function set channel(value:String):void
	{
		_channel = value;
	}
	
	//----------------------------------
	//  previous
	//----------------------------------
	
	/**
	 * @private
	 */
	internal var _previous:LinkedListToken;
	
	/**
	 * doc
	 */
	public function get previous():LinkedListToken
	{
		return _previous;
	}
	
	/**
	 * @private
	 */	
	public function set previous(value:LinkedListToken):void
	{
		if (this == value)
			throw new ASBlocksSyntaxError("Loop detected");
		
		_previous = value;
		
		if (_previous)
		{
			_previous._next = this;
		}
	}
	
	//----------------------------------
	//  next
	//----------------------------------
	
	/**
	 * @private
	 */
	internal var _next:LinkedListToken;
	
	/**
	 * doc
	 */
	public function get next():LinkedListToken
	{
		return _next;
	}
	
	/**
	 * @private
	 */	
	public function set next(value:LinkedListToken):void
	{
		if (this == value)
			throw new ASBlocksSyntaxError("Loop detected");
		
		_next = value;
		
		if (_next)
		{
			_next._previous = this;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function LinkedListToken(kind:String, 
									text:String, 
									line:int = -1, 
									column:int = -1)
	{
		super(text, line, column);
		
		this.kind = kind;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function append(insert:LinkedListToken):void
	{
		if (insert.previous)
			throw new IllegalOperationError("append(" + insert + ") : previous was not null");
		
		if (insert.next)
			throw new IllegalOperationError("append(" + next + ") : previous was not null");
		
		insert._next = _next;
		insert._previous = this;
		
		if (_next)
		{
			_next._previous = insert;
		}
		
		_next = insert;
	}
	
	/**
	 * @private
	 */
	public function prepend(insert:LinkedListToken):void
	{
		if (insert.previous)
			throw new IllegalOperationError("prepend(" + insert + ") : previous was not null");
		
		if (insert.next)
			throw new IllegalOperationError("prepend(" + next + ") : previous was not null");
		
		insert._previous = _previous;
		insert._next = this;
		
		if (_previous)
		{
			_previous._next = insert;
		}
		
		_previous = insert;
	}
	
	/**
	 * @private
	 */
	public function remove():void
	{
		if (_previous)
		{
			_previous._next = _next;
		}
		
		if (_next)
		{
			_next._previous = _previous;
		}
		
		_next = null;
		_previous = null;
	}
}
}