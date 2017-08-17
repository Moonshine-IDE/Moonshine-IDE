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
import org.as3commons.asblocks.api.IINvocation;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.ArgumentUtil;

/**
 * The <code>IINvocation</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class InvocationNode extends ExpressionNode implements IINvocation
{
	//--------------------------------------------------------------------------
	//
	//  IINvocation API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IINvocation#target
	 */
	public function get target():IExpression
	{
		return ExpressionBuilder.build(findCall().getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set target(value:IExpression):void
	{
		findCall().setChildAt(value.node, 0);
	}
	
	//----------------------------------
	//  arguments
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IINvocation#arguments
	 */
	public function get arguments():Vector.<IExpression>
	{
		return ArgumentUtil.getArguments(findArguments());
	}
	
	/**
	 * @private
	 */	
	public function set arguments(value:Vector.<IExpression>):void
	{
		setArguments(value);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function InvocationNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function findCall():IParserNode
	{
		return node;
	}
	
	/**
	 * @private
	 */
	protected function findTarget():IParserNode
	{
		return findCall().getFirstChild();
	}
	
	/**
	 * @private
	 */
	protected function findArguments():IParserNode
	{
		return findCall().getLastChild();
	}
	
	/**
	 * @private
	 */
	protected function get hasArguments():Boolean
	{
		return findArguments() != null;
	}
	
	/**
	 * @private
	 */
	protected function setArguments(value:Vector.<IExpression>):void
	{
		ArgumentUtil.setArguments(findCall(), value);
	}
}
}