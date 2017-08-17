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

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IForInStatement;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.api.IStatementContainer;

/**
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ForInStatementNodeBase extends ContainerDelegate 
	implements IForInStatement
{
	//--------------------------------------------------------------------------
	//
	//  IForInStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  initializer
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IForInStatement#initializer
	 */
	public function get initializer():IScriptNode
	{
		var ast:IParserNode = findInitializer();
		if (!ast)
			return null;
		
		if (ast.isKind(AS3NodeKind.DEC_LIST))
		{
			return new DeclarationStatementNode(ast);
		}
		else
		{
			return ExpressionBuilder.build(ast);
		}
		
		return null;
	}
	
	/**
	 * @private
	 */	
	public function set initializer(value:IScriptNode):void
	{
		var ast:IParserNode = node.getChild(0);
		if (!value && ast)
		{
			ast.removeChildAt(0);
		}
		else if (value)
		{
			var last:LinkedListToken = value.node.stopToken;
			if (last.text == ";")
			{
				var prev:LinkedListToken = last.previous;
				last.remove();
				value.node.stopToken = prev;
			}
			ast.setChildAt(value.node, 0);
		}
	}
	
	//----------------------------------
	//  initializer
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IForInStatement#iterated
	 */
	public function get iterated():IExpression
	{
		var ast:IParserNode = findIterated();
		if (!ast)
			return null;
		
		return ExpressionBuilder.build(ast);
	}
	
	/**
	 * @private
	 */	
	public function set iterated(value:IExpression):void
	{
		var ast:IParserNode = node.getChild(1);
		if (!value && ast)
		{
			ast.removeChildAt(0);
		}
		else if (value)
		{
			ast.setChildAt(value.node, 0);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function get statementContainer():IStatementContainer
	{
		return new StatementList(node.getLastChild()); // block
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ForInStatementNodeBase(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function findInitializer():IParserNode
	{
		return node.getChild(0).getFirstChild();
	}
	
	/**
	 * @private
	 */
	private function findIterated():IParserNode
	{
		return node.getChild(1).getFirstChild();
	}
}
}