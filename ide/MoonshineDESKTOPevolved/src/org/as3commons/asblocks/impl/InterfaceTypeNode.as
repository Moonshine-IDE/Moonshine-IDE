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

import org.as3commons.asblocks.api.IInterfaceType;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IInterfaceType</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class InterfaceTypeNode extends TypeNode implements IInterfaceType
{
	//--------------------------------------------------------------------------
	//
	//  IInterfaceType API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  superInterfaces
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IInterfaceType#superInterfaces
	 */
	public function get superInterfaces():Vector.<String>
	{
		var result:Vector.<String> = new Vector.<String>();
		var extndz:IParserNode = findExtends();
		if (extndz)
		{
			var i:ASTIterator = new ASTIterator(extndz);
			while (i.hasNext())
			{
				result.push(ASTUtil.typeText(i.next()));
			}
		}
		return result;
	}
	
	//----------------------------------
	//  qualifiedSuperInterfaces
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IInterfaceType#qualifiedSuperInterfaces
	 */
	public function get qualifiedSuperInterfaces():Vector.<String>
	{
		var result:Vector.<String> = new Vector.<String>();
		var extndz:IParserNode = findExtends();
		if (extndz)
		{
			var i:ASTIterator = new ASTIterator(extndz);
			while (i.hasNext())
			{
				var type:String = ASTUtil.typeText(i.next());
				result.push(ASTUtil.qualifiedNameForTypeString(node, type));
			}
		}
		return result;
	}
	
	//----------------------------------
	//  isSubType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#isSubType
	 */
	public function get isSubType():Boolean
	{
		return findExtends() != null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function InterfaceTypeNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function newMethod(name:String, 
									   visibility:Visibility, 
									   returnType:String):IMethod
	{
		var ast:IParserNode = ASTTypeBuilder.newInterfaceMethodAST(name, returnType);
		var method:IMethod = new MethodNode(ast);
		addMethod(method);
		return method;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IClassTypeNode API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IInterfaceType#addSuperInterface()
	 */
	public function addSuperInterface(name:String):Boolean
	{
		if (containsSuper(name))
			return false;
		
		var extndz:IParserNode = findExtends();
		var type:IParserNode = AS3FragmentParser.parseType(name);
		if (!extndz)
		{
			extndz = ASTBuilder.newAST(AS3NodeKind.EXTENDS, "extends");
			var i:ASTIterator = new ASTIterator(node);
			i.find(AS3NodeKind.CONTENT);
			i.insertBeforeCurrent(extndz);
			// adds a space before the 'implements' keyword
			var space:LinkedListToken = TokenBuilder.newSpace();
			extndz.startToken.prepend(space);
		}
		else
		{
			extndz.appendToken(TokenBuilder.newComma());
		}
		extndz.appendToken(TokenBuilder.newSpace());
		extndz.addChild(type);
		return true;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IInterfaceType#removeSuperInterface()
	 */
	public function removeSuperInterface(name:String):Boolean
	{
		var extndz:IParserNode = findExtends();
		if (!extndz)
			return false;
		
		var count:int = 0;
		var i:ASTIterator = new ASTIterator(extndz);
		while (i.hasNext())
		{
			var echild:IParserNode = i.next();
			var n:String = ASTUtil.typeText(echild);
			if (n == name)
			{
				if (i.hasNext())
				{
					ASTUtil.removeTrailingWhitespaceAndComma(echild.stopToken, true);
				}
				else if (count == 0)
				{
					var previous:LinkedListToken = extndz.startToken.previous;
					node.removeChild(extndz);
					// Hack, I can't figure out how to remove both spaces
					ASTUtil.collapseWhitespace(previous)
					return true;
				}
				i.remove();
				if (i.hasNext())
				{
					count++;
				}
				return true;
			}
			count++;
		}
		return false;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	protected function findExtends():IParserNode
	{
		return node.getKind(AS3NodeKind.EXTENDS);
	}
	
	/**
	 * @private
	 */
	private function containsSuper(name:String):Boolean
	{
		var ast:IParserNode = findExtends();
		if (!ast)
			return false;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			if (ASTUtil.typeText(i.next()) == name)
				return true;
		}
		return false;
	}
}
}