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

import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.Modifier;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.FieldUtil;
import org.as3commons.asblocks.utils.ModifierUtil;

/**
 * The <code>IClassType</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ClassTypeNode extends TypeNode implements IClassType
{
	//--------------------------------------------------------------------------
	//
	//  IClassType API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  isDynamic
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#isDynamic
	 */
	public function get isDynamic():Boolean
	{
		return ModifierUtil.hasModifierFlag(node, Modifier.DYNAMIC);
	}
	
	/**
	 * @private
	 */	
	public function set isDynamic(value:Boolean):void
	{
		ModifierUtil.setModifierFlag(node, value, Modifier.DYNAMIC);
	}
	
	//----------------------------------
	//  isFinal
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#isFinal
	 */
	public function get isFinal():Boolean
	{
		return ModifierUtil.hasModifierFlag(node, Modifier.FINAL);
	}
	
	/**
	 * @private
	 */	
	public function set isFinal(value:Boolean):void
	{
		ModifierUtil.setModifierFlag(node, value, Modifier.FINAL);
	}
	
	//----------------------------------
	//  superClass
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#superClass
	 */
	public function get superClass():String
	{
		var ast:IParserNode = findExtends();
		if (!ast)
			return null;
		
		return ASTUtil.typeText(ast.getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set superClass(value:String):void
	{
		if (value == null || value == "")
		{
			removeExtends();
			return;
		}
		
		var extendz:IParserNode = findExtends();
		var type:IParserNode = AS3FragmentParser.parseType(value);
		if (!extendz)
		{
			extendz = ASTBuilder.newAST(AS3NodeKind.EXTENDS, "extends");
			extendz.appendToken(TokenBuilder.newSpace());
			// space is between className and 'extends' keyword
			var space:LinkedListToken = TokenBuilder.newSpace();
			extendz.startToken.prepend(space);
			extendz.startToken = space;
			var i:ASTIterator = new ASTIterator(node);
			i.find(AS3NodeKind.NAME);
			i.insertAfterCurrent(extendz);
			extendz.addChild(type);
		}
		else
		{
			extendz.setChildAt(type, 0);
		}
	}
	
	//----------------------------------
	//  qualifiedSuperClass
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#qualifiedSuperClass
	 */
	public function get qualifiedSuperClass():String
	{
		if (!findExtends())
			return null;
		
		var qname:ASQName = new ASQName(superClass);
		if (qname.isQualified)
			return qname.qualifiedName;
		
		return ASTUtil.qualifiedNameForTypeString(node, superClass);
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
	
	//----------------------------------
	//  implementedInterfaces
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#implementedInterfaces
	 */
	public function get implementedInterfaces():Vector.<String>
	{
		var result:Vector.<String> = new Vector.<String>();
		var ast:IParserNode = findImplements();
		if (!ast)
			return result;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			result.push(ASTUtil.typeText(i.next()));
		}
		
		return result;
	}
	
	//----------------------------------
	//  qualifiedImplementedInterfaces
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#qualifiedImplementedInterfaces
	 */
	public function get qualifiedImplementedInterfaces():Vector.<String>
	{
		var result:Vector.<String> = new Vector.<String>();
		var ast:IParserNode = findImplements();
		if (!ast)
			return result;
		
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var impl:String = ASTUtil.typeText(i.next());
			result.push(ASTUtil.qualifiedNameForTypeString(node, impl));
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFieldAware API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  fields
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFieldAware#fields
	 */
	public function get fields():Vector.<IField>
	{
		return FieldUtil.getFields(findContent());
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ClassTypeNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IClassType API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#addImplementedInterface()
	 */
	public function addImplementedInterface(name:String):Boolean
	{
		if (containsImplementor(name))
			return false;
		
		var ast:IParserNode = findImplements();
		var type:IParserNode = AS3FragmentParser.parseType(name);
		if (!ast)
		{
			ast = ASTBuilder.newAST(AS3NodeKind.IMPLEMENTS, "implements");
			var i:ASTIterator = new ASTIterator(node);
			i.find(AS3NodeKind.CONTENT);
			i.insertBeforeCurrent(ast);
			// adds a space before the 'implements' keyword
			var space:LinkedListToken = TokenBuilder.newSpace();
			ast.startToken.prepend(space);
		}
		else
		{
			ast.appendToken(TokenBuilder.newComma());
		}
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(type);
		return true;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#removeImplementedInterface()
	 */
	public function removeImplementedInterface(name:String):Boolean
	{
		var ast:IParserNode = findImplements();
		if (!ast)
			return false;
		
		var count:int = 0;
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var ichild:IParserNode = i.next();
			var n:String = ASTUtil.typeText(ichild);
			if (n == name)
			{
				if (i.hasNext())
				{
					ASTUtil.removeTrailingWhitespaceAndComma(ichild.stopToken, true);
				}
				else if (count == 0)
				{
					var previous:LinkedListToken = ast.startToken.previous;
					node.removeChild(ast);
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
		var ast:IParserNode = ASTTypeBuilder.newMethodAST(name, visibility, returnType);
		var method:IMethod = new MethodNode(ast);
		addMethod(method);
		return method;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFieldAware API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFieldAware#newField()
	 */
	public function newField(name:String, 
							 visibility:Visibility, 
							 type:String):IField
	{
		return FieldUtil.newField(findContent(), name, visibility, type);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFieldAware#getField()
	 */
	public function getField(name:String):IField
	{
		return FieldUtil.getField(findContent(), name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFieldAware#addField()
	 */
	public function addField(field:IField):void
	{
		FieldUtil.addField(findContent(), field);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFieldAware#removeField()
	 */
	public function removeField(name:String):IField
	{
		return FieldUtil.removeField(findContent(), name);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function findExtends():IParserNode
	{
		return node.getKind(AS3NodeKind.EXTENDS);
	}
	
	/**
	 * @private
	 */
	protected function findImplements():IParserNode
	{
		return node.getKind(AS3NodeKind.IMPLEMENTS);
	}
	
	/**
	 * @private
	 */
	private function removeExtends():void
	{
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext())
		{
			var child:IParserNode = i.next();
			if (child.isKind(AS3NodeKind.EXTENDS))
			{
				i.remove();
				break;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function containsImplementor(name:String):Boolean
	{
		var impls:IParserNode = node.getKind(AS3NodeKind.IMPLEMENTS);
		if (!impls)
			return false;
		
		var i:ASTIterator = new ASTIterator(impls);
		while (i.hasNext())
		{
			if (ASTUtil.typeText(i.next()) == name)
				return true;
		}
		return false;
	}
}
}