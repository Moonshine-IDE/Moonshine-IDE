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
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.api.IArrayLiteral;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IArrayLiteral</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ArrayLiteralNode extends LiteralNode 
	implements IArrayLiteral
{
	//--------------------------------------------------------------------------
	//
	//  IArrayLiteral API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  entries
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IArrayLiteral#entries
	 */
	public function get entries():Vector.<IExpression>
	{
		var entries:Vector.<IExpression> = new Vector.<IExpression>();
		var i:ASTIterator = new ASTIterator(findArray());
		while (i.hasNext()) 
		{
			entries.push(ExpressionBuilder.build(i.next()));
		}
		return entries;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ArrayLiteralNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IArrayLiteral API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IArrayLiteral#add()
	 */
	public function add(expression:IExpression):void
	{
		var ast:IParserNode = findArray();
		
		if (ast.numChildren > 0)
		{
			ast.appendToken(TokenBuilder.newComma());
			ast.appendToken(TokenBuilder.newSpace());
		}
		ast.addChild(expression.node);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IArrayLiteral#remove()
	 */
	public function remove(index:int):IExpression
	{
		var ast:IParserNode = findArray();
		
		var old:IParserNode = ast.getChild(index);
		if (ast.numChildren - 1 > index)
		{
			ASTUtil.removeTrailingWhitespaceAndComma(old.stopToken);
		} 
		else if (index > 0)
		{
			ASTUtil.removePreceedingWhitespaceAndComma(old.startToken);
		}

		ast.removeChild(old);
		return ExpressionBuilder.build(old);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function findArray():IParserNode
	{
		return node;
	}
}
}