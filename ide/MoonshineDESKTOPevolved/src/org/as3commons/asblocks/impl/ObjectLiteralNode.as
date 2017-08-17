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
import org.as3commons.asblocks.api.IObjectLiteral;
import org.as3commons.asblocks.api.IPropertyField;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IObjectLiteral</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ObjectLiteralNode extends LiteralNode 
	implements IObjectLiteral
{
	//--------------------------------------------------------------------------
	//
	//  IObjectLiteral API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  entries
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IObjectLiteral#fields
	 */
	public function get fields():Vector.<IPropertyField>
	{
		var result:Vector.<IPropertyField> = new Vector.<IPropertyField>();
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext()) 
		{
			result.push(new PropertyFieldNode(i.next()));
		}
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ObjectLiteralNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IObjectLiteral API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IObjectLiteral#newField()
	 */
	public function newField(name:String, expression:IExpression):IPropertyField
	{
		var ast:IParserNode = ASTLiteralBuilder.newObjectField(name, expression.node);
		var indent:String = ASTUtil.findIndent(node) + "\t";
		ASTUtil.increaseIndent(ast, indent);
		if (node.numChildren > 0)
		{
			node.appendToken(TokenBuilder.newComma());
		}
		node.appendToken(TokenBuilder.newNewline());
		node.addChild(ast);
		return new PropertyFieldNode(ast);
	}
}
}