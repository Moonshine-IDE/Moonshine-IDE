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

package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.api.IContinueStatement;
import org.as3commons.asblocks.api.IExpression;

/**
 * The <code>IContinueStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ContinueStatementNode extends ScriptNode 
	implements IContinueStatement
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  label
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IContinueStatement.label
	 */
	public function get label():IExpression
	{
		if (node.numChildren == 0)
			return null;
		
		return ExpressionBuilder.build(node.getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set label(value:IExpression):void
	{
		if (value == null && node.numChildren > 0)
		{
			node.removeChildAt(0);
		}
		
		if (value == null)
			return;
		
		if (node.numChildren == 0)
		{
			node.appendToken(TokenBuilder.newSpace());
			node.addChild(value.node);
		}
		else
		{
			node.appendToken(TokenBuilder.newSpace());
			node.setChildAt(value.node, 0);
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
	public function ContinueStatementNode(node:IParserNode)
	{
		super(node);
	}
}
}