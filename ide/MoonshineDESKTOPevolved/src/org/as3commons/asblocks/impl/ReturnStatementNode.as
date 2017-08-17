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

import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IReturnStatement;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IReturnStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ReturnStatementNode extends ScriptNode 
	implements IReturnStatement
{
	//--------------------------------------------------------------------------
	//
	//  Private :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function get hasExpression():Boolean
	{
		return node.numChildren > 0;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IReturnStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  expression
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IReturnStatement#expression
	 */
	public function get expression():IExpression
	{
		if (!hasExpression)
			return null;
		
		return ExpressionBuilder.build(node.getFirstChild());
	}
	
	/**
	 * @private
	 */
	public function set expression(value:IExpression):void
	{
		if (!hasExpression)
		{
			node.addChild(value.node);
			return;
		}
		node.setChildAt(value.node, 0);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ReturnStatementNode(node:IParserNode)
	{
		super(node);
	}
}
}