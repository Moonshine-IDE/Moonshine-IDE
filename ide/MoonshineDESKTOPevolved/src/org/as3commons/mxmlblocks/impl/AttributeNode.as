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

package org.as3commons.mxmlblocks.impl
{

import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.mxmlblocks.api.IAttribute;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

/**
 * The <code>IAttribute</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class AttributeNode extends ScriptNode implements IAttribute
{
	//--------------------------------------------------------------------------
	//
	//  IAttribute API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IAttribute#name
	 */
	public function get name():String
	{
		var ast:IParserNode = findName();
		if (!ast)
			return null;
		return ast.stringValue;
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
		var ast:IParserNode = findName();
		ast.stringValue = value;
	}
	
	//----------------------------------
	//  value
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IAttribute#value
	 */
	public function get value():String
	{
		var ast:IParserNode = findValue();
		if (!ast)
			return null;
		return ast.stringValue;
	}
	
	/**
	 * @private
	 */	
	public function set value(value:String):void
	{
		var ast:IParserNode = findValue();
		ast.stringValue = value;
	}
	
	//----------------------------------
	//  state
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IAttribute#state
	 */
	public function get state():String
	{
		var ast:IParserNode = findState();
		if (!ast)
			return null;
		return ast.stringValue;
	}
	
	/**
	 * @private
	 */	
	public function set state(value:String):void
	{
		var ast:IParserNode = findState();
		
		if (value == null)
		{
			if (ast)
			{
				node.removeChild(ast);
			}
			return;
		}
		
		if (!ast)
		{
			var dot:LinkedListToken = TokenBuilder.newDot();
			ast = ASTBuilder.newAST(MXMLNodeKind.STATE, value);
			ast.startToken.prepend(dot);
			ast.startToken = dot;
		}
		
		node.addChildAt(ast, 1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function AttributeNode(node:IParserNode)
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
	private function findName():IParserNode
	{
		return node.getKind(MXMLNodeKind.NAME);
	}
	
	/**
	 * @private
	 */
	private function findValue():IParserNode
	{
		return node.getKind(MXMLNodeKind.VALUE);
	}
	
	/**
	 * @private
	 */
	private function findState():IParserNode
	{
		return node.getKind(MXMLNodeKind.STATE);
	}
}
}