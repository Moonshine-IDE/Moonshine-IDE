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

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IFunction;
import org.as3commons.asblocks.api.IParameter;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IFunction</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class FunctionCommon implements IFunction
{	
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var node:IParserNode;
	
	//--------------------------------------------------------------------------
	//
	//  IFunction API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  parameters
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#parameters
	 */
	public function get parameters():Vector.<IParameter>
	{
		var result:Vector.<IParameter> = new Vector.<IParameter>();
		var ast:IParserNode = findParameterList();
		if (!ast)
			return result;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			result.push(new ParameterNode(i.next()));
		}
		
		return result;
	}
	
	//----------------------------------
	//  hasParameters
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasParameters
	 */
	public function get hasParameters():Boolean
	{
		var ast:IParserNode = findParameterList();
		return ast != null && ast.numChildren > 0;
	}
	
	//----------------------------------
	//  returnType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#returnType
	 */
	public function get returnType():String
	{
		return NameTypeUtil.getType(node);
	}
	
	/**
	 * @private
	 */	
	public function set returnType(value:String):void
	{
		var ast:IParserNode = findType();
		if (value == null)
		{
			if (ast != null)
			{
				node.removeChild(ast);
			}
			return;
		}
		
		var typeAST:IParserNode = AS3FragmentParser.parseType(value);
		var colon:LinkedListToken = TokenBuilder.newColon();
		typeAST.startToken.prepend(colon);
		typeAST.startToken = colon;
		if (ast == null) // SHOULDN'T BE
		{
			
		}
		else
		{
			node.setChildAt(typeAST, node.getChildIndex(ast));
		}
	}
	
	//----------------------------------
	//  qualifiedReturnType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#qualifiedReturnType
	 */
	public function get qualifiedReturnType():String
	{
		if (!returnType)
			return null;
		
		return ASTUtil.qualifiedNameForTypeString(node, returnType);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function FunctionCommon(node:IParserNode)
	{
		super();
		
		this.node = node;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFunction API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#addParameter()
	 */
	public function addParameter(name:String, 
								 type:String, 
								 defaultValue:String = null):IParameter
	{
		if (hasParameter(name))
		{
			throw new ASBlocksSyntaxError("a parameter name [" + name + "] already exists");
		}
		
		var ast:IParserNode = ASTFunctionBuilder.newParameter(name, type, defaultValue);
		return createParameter(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#removeParameter()
	 */
	public function removeParameter(name:String):IParameter
	{
		if (!hasParameter(name))
			return null;
		
		var i:ASTIterator = new ASTIterator(findParameterList());
		while (i.hasNext())
		{
			var parameter:IParameter = new ParameterNode(i.next());
			if (parameter.name == name)
			{
				i.remove();
				return parameter;
			}
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#addRestParameter()
	 */
	public function addRestParameter(name:String):IParameter
	{
		if (hasRestParameter())
		{
			throw new ASBlocksSyntaxError("only one rest parameter allowed");
		}
		
		var ast:IParserNode = ASTFunctionBuilder.newRestParameter(name);
		return createParameter(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#removeRestParameter()
	 */
	public function removeRestParameter():IParameter
	{
		if (!hasRestParameter())
			return null;
		
		var i:ASTIterator = new ASTIterator(findParameterList());
		while (i.hasNext())
		{
			var parameter:IParameter = new ParameterNode(i.next());
			if (parameter.isRest)
			{
				i.remove();
				return parameter;
			}
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#getParameter()
	 */
	public function getParameter(name:String):IParameter
	{
		if (!hasParameter(name))
			return null;
		
		var ast:IParserNode = findParameterList();
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var parameter:IParameter = new ParameterNode(i.next());
			if (parameter.name == name)
				return parameter;
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasParameter()
	 */
	public function hasParameter(name:String):Boolean
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return false;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var parameter:IParameter = new ParameterNode(i.next());
			if (parameter.name == name)
				return true;
		}
		return false;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasRestParameter()
	 */
	public function hasRestParameter():Boolean
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return false;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var parameter:IParameter = new ParameterNode(i.next());
			if (parameter.isRest)
				return true;
		}
		return false;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function findParameterList():IParserNode
	{
		return node.getKind(AS3NodeKind.PARAMETER_LIST);
	}
	
	/**
	 * @private
	 */
	private function findType():IParserNode
	{
		var ast:IParserNode = node.getKind(AS3NodeKind.TYPE);
		if (!ast)
		{
			ast = node.getKind(AS3NodeKind.VECTOR);
		}
		return ast;
	}
	
	/**
	 * @private
	 */
	private function createParameter(parameter:IParserNode):IParameter
	{
		var ast:IParserNode = findParameterList();
		if (ast.numChildren > 0)
		{
			ast.appendToken(TokenBuilder.newComma());
			ast.appendToken(TokenBuilder.newSpace());
		}
		ast.addChild(parameter);
		return new ParameterNode(parameter);
	}
}
}