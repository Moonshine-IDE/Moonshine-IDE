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

import org.as3commons.asblocks.api.IDeclaration;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IDeclarationStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class DeclarationStatementNode extends ScriptNode 
	implements IDeclarationStatement
{
	//--------------------------------------------------------------------------
	//
	//  IDeclarationStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#name
	 */
	public function get name():String
	{
		return getFirstDeclaration().name;
	}
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#type
	 */
	public function get type():String
	{
		return getFirstDeclaration().type;
	}
	
	//----------------------------------
	//  initializer
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#initializer
	 */
	public function get initializer():IExpression
	{
		return getFirstDeclaration().initializer;
	}
	
	//----------------------------------
	//  declarations
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#declarations
	 */
	public function get declarations():Vector.<IDeclaration>
	{
		var result:Vector.<IDeclaration> = new Vector.<IDeclaration>();
		var i:ASTIterator = new ASTIterator(node);
		i.next(); // dec-role
		while(i.hasNext())
		{
			result.push(build(i.next()));
		}
		return result;
	}
	
	//----------------------------------
	//  isConstant
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclarationStatement#isConstant
	 */
	public function get isConstant():Boolean
	{
		// dec-list/dec-role
		return findDecRole().getFirstChild().isKind(AS3NodeKind.CONST);
	}
	
	/**
	 * @private
	 */	
	public function set isConstant(value:Boolean):void
	{
		var roleList:IParserNode = findDecRole();
		if (value && roleList.getFirstChild().isKind(AS3NodeKind.CONST))
			return;
		
		var kind:String = (value) ? AS3NodeKind.CONST : AS3NodeKind.VAR;
		var role:IParserNode = ASTBuilder.newAST(AS3NodeKind.DEC_ROLE);
		var ast:IParserNode = ASTBuilder.newAST(kind);
		role.addChild(ast);
		role.appendToken(TokenBuilder.newToken(kind, kind));
		node.setChildAt(role, 0);
		role.appendToken(TokenBuilder.newSpace());
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function DeclarationStatementNode(node:IParserNode)
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
	private function findDecRole():IParserNode
	{
		return node.getFirstChild();
	}
	
	/**
	 * @private
	 */
	private function getFirstDeclaration():IDeclaration
	{
		return build(node.getChild(1));
	}
	
	/**
	 * @private
	 */
	private function build(ast:IParserNode):IDeclaration
	{
		return new Declaration(ast);
	}
}
}