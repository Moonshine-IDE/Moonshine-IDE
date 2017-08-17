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

import org.as3commons.asblocks.api.IParameter;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IParameter</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ParameterNode extends ScriptNode implements IParameter
{
	//--------------------------------------------------------------------------
	//
	//  IParameter API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  description
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#description
	 */
	public function get description():String
	{
		return null;
	}
	
	/**
	 * @private
	 */	
	public function set description(value:String):void
	{
		// TODO (mschmalle) impl ParameterNode#description
	}
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#name
	 */
	public function get name():String
	{
		if (isRest)
			return findRest().stringValue;
		
		var ast:IParserNode = findNameTypeInit();
		var name:IParserNode = ast.getKind(AS3NodeKind.NAME);
		if (name)
			return ASTUtil.nameText(name);
		
		// IllegalStateException
		throw new Error("No parameter name, and not a 'rest' parameter");
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
		if (isRest)
		{
			findRest().stringValue = value;
			return;
		}
		
		var ast:IParserNode = findNameTypeInit();
		var name:IParserNode = ast.getKind(AS3NodeKind.NAME);
		if (name)
			name.stringValue = value;
	}
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#type
	 */
	public function get type():String
	{
		if (isRest)
			return null;
	
		return NameTypeUtil.getType(findNameTypeInit());
	}
	
	/**
	 * @private
	 */	
	public function set type(value:String):void
	{
		if (isRest)
			return;
		
		var ast:IParserNode = findNameTypeInit();
		var typeAST:IParserNode = ast.getKind(AS3NodeKind.TYPE);
		if (typeAST)
			typeAST.stringValue = value;
	}
	
	//----------------------------------
	//  qualifiedType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#qualifiedType
	 */
	public function get qualifiedType():String
	{
		if (!type)
			return null;
		
		return ASTUtil.qualifiedNameForTypeString(node, type);
	}
	
	//----------------------------------
	//  hasType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#hasType
	 */
	public function get hasType():Boolean
	{
		return NameTypeUtil.hasType(findNameTypeInit());
	}
	
	//----------------------------------
	//  defaultValue
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#defaultValue
	 */
	public function get defaultValue():String
	{
		if (isRest)
			return null;
		
		var ast:IParserNode = findNameTypeInit();
		var init:IParserNode = ast.getKind(AS3NodeKind.INIT);
		if (init)
			return ASTUtil.initText(init);
		
		return null;
	}
	
	/**
	 * @private
	 */	
	public function set defaultValue(value:String):void
	{
		if (isRest)
			return;
		
		var ast:IParserNode = findNameTypeInit();
		var initAST:IParserNode = ast.getKind(AS3NodeKind.INIT);
		if (!initAST)
		{
			initAST = ASTBuilder.newAST(AS3NodeKind.INIT);
			ast.addChild(initAST);
		}
		
		initAST.stringValue = value;
	}
	
	//----------------------------------
	//  hasDefaultValue
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#hasDefaultValue
	 */
	public function get hasDefaultValue():Boolean
	{
		if (isRest)
			return false;
		
		return defaultValue != null;
	}
	
	//----------------------------------
	//  isRest
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IParameter#isRest
	 */
	public function get isRest():Boolean
	{
		return node.hasKind(AS3NodeKind.REST);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ParameterNode(node:IParserNode)
	{
		super(node);
	}
	
	/**
	 * @private
	 */
	private function findNameTypeInit():IParserNode
	{
		return node.getKind(AS3NodeKind.NAME_TYPE_INIT);
	}
	
	/**
	 * @private
	 */
	private function findRest():IParserNode
	{
		return node.getKind(AS3NodeKind.REST);
	}
}
}