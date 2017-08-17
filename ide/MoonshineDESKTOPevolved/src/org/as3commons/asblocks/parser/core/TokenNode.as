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
 * A parser node that holds start and stop tokens.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TokenNode extends Node
{
	public var absolute:Boolean = false;
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  token
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _token:LinkedListToken;
	
	/**
	 * doc
	 */
	public function get token():LinkedListToken
	{
		return _token;
	}
	
	/**
	 * @private
	 */	
	public function set token(value:LinkedListToken):void
	{
		_token = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function set kind(value:String):void
	{
		super.kind = value;
		
		if (token)
		{
			token.kind = value;
		}
	}
	
	/**
	 * @private
	 */
	override public function set stringValue(value:String):void
	{
		super.stringValue = value;
		
		if (token)
		{
			token.text = value;
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
	public function TokenNode(kind:String,
							  stringValue:String,
							  line:int,
							  column:int)
	{
		super(kind, line, column, stringValue);
	}
	
	/**
	 * called when one of this node's children updates it's start-token,
	 * so that this node can potentially take action; maybe by setting
	 * the same start-token IF the child was the very-first in this node's
	 * list of children.
	 */
	internal function notifyChildStartTokenChange(child:IParserNode, 
												  newStart:LinkedListToken):void
	{
		if (isFirst(child) && isSameStartToken(child)) 
		{
			startToken = newStart;
		}
		
	}
	
	/**
	 * called when one of this node's children updates it's stop-token,
	 * so that this node can potentially take action; maybe by setting
	 * the same stop-token IF the child was the very-last in this node's
	 * list of children.
	 */
	internal function notifyChildStopTokenChange(child:IParserNode, 
												 newStop:LinkedListToken):void
	{
		if (isLast(child) && (isSameStopToken(child) || isNoStopToken(child)))
		{
			stopToken = newStop;
		}
	}
	
	/**
	 * @private
	 */
	private function isSameStartToken(child:IParserNode):Boolean
	{
		return child.startToken == startToken;
	}
	
	/**
	 * @private
	 */
	private function isFirst(child:IParserNode):Boolean
	{
		return child == getFirstChild();
	}
	
	/**
	 * @private
	 */
	private function isNoStopToken(child:IParserNode):Boolean
	{
		return child.stopToken == null;
	}
	
	/**
	 * @private
	 */
	private function isSameStopToken(child:IParserNode):Boolean
	{
		return child.stopToken == stopToken;
	}
	
	/**
	 * @private
	 */
	private function isLast(child:IParserNode):Boolean
	{
		return child == getLastChild();
	}
}
}