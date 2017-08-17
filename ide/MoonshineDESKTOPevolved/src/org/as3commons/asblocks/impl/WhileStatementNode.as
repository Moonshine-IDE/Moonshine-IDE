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
import org.as3commons.asblocks.api.IStatement;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.api.IWhileStatement;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IWhileStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class WhileStatementNode extends ContainerDelegate 
	implements IWhileStatement
{
	//--------------------------------------------------------------------------
	//
	//  IWhileStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  condition
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IWhileStatement#condition
	 */
	public function get condition():IExpression
	{
		return ExpressionBuilder.build(findCondition().getFirstChild());
	}
	
	/**
	 * @private
	 */
	public function set condition(value:IExpression):void
	{
		findCondition().setChildAt(value.node, 0);
	}
	
	//----------------------------------
	//  body
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IWhileStatement#body
	 */
	public function get body():IStatement
	{
		return StatementBuilder.build(findBlock());
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function get statementContainer():IStatementContainer
	{
		return new StatementList(findBlock());
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function WhileStatementNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function findCondition():IParserNode
	{
		return node.getFirstChild();
	}
	
	/**
	 * @private
	 */
	private function findBlock():IParserNode
	{
		return node.getLastChild();
	}
}
}