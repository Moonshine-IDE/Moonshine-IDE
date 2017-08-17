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

import org.as3commons.asblocks.api.IDocComment;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.IMetaDataParameter;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;

/**
 * The <code>IMetaData</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MetaDataNode extends ScriptNode implements IMetaData
{
	//--------------------------------------------------------------------------
	//
	//  IMetaData API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#parameters
	 */
	public function get name():String
	{
		var ast:IParserNode = findName();
		if(!ast)
			return null;
		return ASTUtil.nameText(ast);
	}
	
	//----------------------------------
	//  parameter
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#parameter
	 */
	public function get parameter():String
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return null;
		return ASTUtil.stringifyNode(ast);
	}
	
	//----------------------------------
	//  parameters
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#parameters
	 */
	public function get parameters():Vector.<IMetaDataParameter>
	{
		var result:Vector.<IMetaDataParameter> = new Vector.<IMetaDataParameter>();
		
		var ast:IParserNode = findParameterList();
		if (!ast)
			return result;
		
		var i:ASTIterator = new ASTIterator(ast);
		while(i.hasNext())
		{
			result.push(new MetaDataParameterNode(i.next()));
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IDocCommentAware API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  description
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#description
	 */
	public function get description():String
	{
		return documentation.description;
	}
	
	/**
	 * @private
	 */	
	public function set description(value:String):void
	{
		documentation.description = value;
	}
	
	//----------------------------------
	//  documentation
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IDocCommentAware#documentation
	 */
	public function get documentation():IDocComment
	{
		return DocCommentUtil.createDocComment(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function MetaDataNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IMetaData API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#addParameter()
	 */
	public function addParameter(value:String):IMetaDataParameter
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.PARAMETER);
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.PRIMARY, value));
		
		_addParameter(ast);
		return new MetaDataParameterNode(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#addNamedParameter()
	 */
	public function addNamedParameter(name:String, value:String):IMetaDataParameter
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.PARAMETER);
		ast.addChild(ASTBuilder.newNameAST(name));
		ast.appendToken(TokenBuilder.newAssign());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.PRIMARY, value));
		
		_addParameter(ast);
		return new MetaDataParameterNode(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#addNamedStringParameter()
	 */
	public function addNamedStringParameter(name:String, value:String):IMetaDataParameter
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.PARAMETER);
		ast.addChild(ASTBuilder.newNameAST(name));
		ast.appendToken(TokenBuilder.newAssign());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.STRING, ASTUtil.escapeString(value)));
		
		_addParameter(ast);
		return new MetaDataParameterNode(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#removeParameter()
	 */
	public function removeParameter(name:String):IMetaDataParameter
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return null;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var current:IParserNode = i.next();
			var parameter:MetaDataParameterNode = new MetaDataParameterNode(current);
			if (parameter.name == name)
			{
				if (i.currentIndex < ast.numChildren - 1)
				{
					ASTUtil.removeTrailingWhitespaceAndComma(current.stopToken);
				} 
				else if (i.currentIndex > 0)
				{
					ASTUtil.removePreceedingWhitespaceAndComma(current.startToken);
				}
				
				i.remove();
				return parameter;
			}
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#removeParameterAt()
	 */
	public function removeParameterAt(index:int):IMetaDataParameter
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return null;
		
		var i:ASTIterator = new ASTIterator(ast);
		var current:IParserNode = i.moveTo(index);
		if (!current)
			return null;
		
		var result:IMetaDataParameter = new MetaDataParameterNode(current);
		
		if (ast.numChildren - 1 > i.currentIndex)
		{
			ASTUtil.removeTrailingWhitespaceAndComma(current.stopToken);
		} 
		else if (i.currentIndex > 0)
		{
			ASTUtil.removePreceedingWhitespaceAndComma(current.startToken);
		}
		
		i.remove();
		
		return result;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#getParameter()
	 */
	public function getParameter(name:String):IMetaDataParameter
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return null;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var parameter:MetaDataParameterNode = new MetaDataParameterNode(i.next());
			if (parameter.name == name)
				return parameter;
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#getParameterAt()
	 */
	public function getParameterAt(index:int):IMetaDataParameter
	{
		var ast:IParserNode = findParameterList();
		if (!ast)
			return null;
		
		var i:ASTIterator = new ASTIterator(ast);
		var current:IParserNode = i.moveTo(index);
		if (!current)
			return null;
		
		return new MetaDataParameterNode(current);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#getParameterValue()
	 */
	public function getParameterValue(name:String):String
	{
		var parameter:IMetaDataParameter = getParameter(name);
		if (!parameter)
			return null;
		return parameter.value;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaData#hasParameter()
	 */
	public function hasParameter(name:String):Boolean
	{
		return getParameter(name) != null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function _addParameter(ast:IParserNode):void
	{
		var list:IParserNode = findParameterList();
		if (!list)
		{
			list = ASTUtil.newParentheticAST(
				AS3NodeKind.PARAMETER_LIST, 
				AS3NodeKind.LPAREN, "(", 
				AS3NodeKind.RPAREN, ")");
			node.addChild(list);
		}
		
		if (list.numChildren > 0)
		{
			list.appendToken(TokenBuilder.newComma());
			list.appendToken(TokenBuilder.newSpace());
		}
		
		list.addChild(ast);
	}
	
	/**
	 * @private
	 */
	private function findName():IParserNode
	{
		return node.getKind(AS3NodeKind.NAME);
	}
	
	/**
	 * @private
	 */
	private function findParameterList():IParserNode
	{
		return node.getKind(AS3NodeKind.PARAMETER_LIST);
	}
}
}