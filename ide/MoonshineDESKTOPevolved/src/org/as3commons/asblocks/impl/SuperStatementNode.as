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
import org.as3commons.asblocks.api.ISuperStatement;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.utils.ArgumentUtil;

/**
 * The <code>ISuperStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class SuperStatementNode extends ScriptNode implements ISuperStatement
{
	//--------------------------------------------------------------------------
	//
	//  ISuperStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get target():IExpression
	{
		var ast:IParserNode = findCall();
		if (ast == null)
			return null;
		
		return ExpressionBuilder.build(ast);
	}
	
	/**
	 * @private
	 */	
	public function set target(value:IExpression):void
	{
		var ast:IParserNode = findCall();
		if (ast == null)
		{
		}
		else
		{
			var dot:LinkedListToken = TokenBuilder.newDot();
			ast.startToken.prepend(dot);
			ast.startToken = dot;
			ast.setChildAt(value.node, 0);
		}
	}
	
	//----------------------------------
	//  arguments
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.ISuperStatement#arguments
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
		return ArgumentUtil.setArguments(findCall(), value);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function SuperStatementNode(node:IParserNode)
	{
		super(node);
	}
	
	private function findCall():IParserNode
	{
		return node.getKind(AS3NodeKind.CALL);
	}
	
	private function findArguments():IParserNode
	{
		var ast:IParserNode = findCall();
		if (ast == null)
		{
			return node.getKind(AS3NodeKind.ARGUMENTS);
		}
		return ast.getLastChild();
	}
}
}