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
import org.as3commons.asblocks.api.IDeclaration;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class Declaration extends ScriptNode	implements IDeclaration
{
	//--------------------------------------------------------------------------
	//
	//  IDeclaration API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclaration#name
	 */
	public function get name():String
	{
		return ASTUtil.nameText(node.getKind(AS3NodeKind.NAME));
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
	}
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclaration#type
	 */
	public function get type():String
	{
		return ASTUtil.typeText(node.getKind(AS3NodeKind.TYPE));
	}
	
	/**
	 * @private
	 */	
	public function set type(value:String):void
	{
	}
	
	//----------------------------------
	//  initializer
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDeclaration#initializer
	 */
	public function get initializer():IExpression
	{
		var init:IParserNode = node.getKind(AS3NodeKind.INIT);
		if (!init)
			return null;
		return ExpressionBuilder.build(init.getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set initializer(value:IExpression):void
	{
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function Declaration(node:IParserNode)
	{
		super(node);
	}
}
}