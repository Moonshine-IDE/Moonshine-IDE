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

import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IPackage</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class PackageNode extends ScriptNode implements IPackage
{
	//--------------------------------------------------------------------------
	//
	//  IPackage API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IPackage#name
	 */
	public function get name():String
	{
		var n:IParserNode = node.getKind(AS3NodeKind.NAME);
		if (n)
			return n.stringValue;
		
		return null;
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
		var i:ASTIterator = new ASTIterator(node);
		var first:IParserNode = i.next();
		
		// a package can have an asdoc, which would be first
		if (first.isKind(AS3NodeKind.AS_DOC))
		{
			first = i.next();
		}
		
		// if name null, remove NAME node
		if (!value && first.isKind(AS3NodeKind.NAME))
		{
			i.remove();
			return;
		}
		
		// replace with new NAME parsed node or add it new
		var ast:IParserNode = AS3FragmentParser.parseName(value);
		if (first.isKind(AS3NodeKind.NAME))
		{
			i.replace(ast);
		}
		else
		{
			i.insertBeforeCurrent(ast);
		}
		
		ast.appendToken(TokenBuilder.newSpace());
	}
	
	//----------------------------------
	//  typeNode
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IPackage#typeNode
	 */
	public function get typeNode():IType
	{
		var ast:IParserNode = findContent();
		if (ast.hasKind(AS3NodeKind.CLASS))
		{
			return new ClassTypeNode(ast.getKind(AS3NodeKind.CLASS));
		}
		else if (ast.hasKind(AS3NodeKind.INTERFACE))
		{
			return new InterfaceTypeNode(ast.getKind(AS3NodeKind.INTERFACE));
		}
		else if (ast.hasKind(AS3NodeKind.FUNCTION))
		{
			return new FunctionTypeNode(ast.getKind(AS3NodeKind.FUNCTION));
		}
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function PackageNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IPackage API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IPackage#addImports()
	 */
	public function addImports(name:String):void
	{
		var ast:IParserNode = AS3FragmentParser.parseImport(name);
		var pos:int = nextInsertion();
		ASTUtil.addChildWithIndentation(findContent(), ast, pos);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IPackage#removeImport()
	 */
	public function removeImport(name:String):Boolean
	{
		var i:ASTIterator = getContentIterator();
		var ast:IParserNode;
		while (ast = i.search(AS3NodeKind.IMPORT))
		{
			if (importText(ast) == name)
			{
				i.remove();
				return true;
			}
		}
		return false;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IPackage#findImports()
	 */
	public function findImports():Vector.<String>
	{
		var i:ASTIterator = getContentIterator();
		var ast:IParserNode;
		var result:Vector.<String> = new Vector.<String>();
		while (ast = i.search(AS3NodeKind.IMPORT))
		{
			result.push(importText(ast));
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function getContentIterator():ASTIterator
	{
		return new ASTIterator(findContent());
	}
	
	/**
	 * @private
	 */
	protected function findContent():IParserNode
	{
		return node.getLastChild();
	}
	
	/**
	 * @private
	 */
	protected function importText(ast:IParserNode):String
	{
		return ast.getFirstChild().stringValue;
	}
	
	/**
	 * @private
	 */
	protected function nextInsertion():int
	{
		var i:ASTIterator = getContentIterator();
		var index:int = 0;
		while (i.search(AS3NodeKind.IMPORT))
		{
			index = i.currentIndex + 1;
		}
		return index;
	}
}
}