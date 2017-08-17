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

import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTTypeBuilder;
import org.as3commons.asblocks.impl.ContentBlockNode;
import org.as3commons.asblocks.impl.MethodNode;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.FieldUtil;
import org.as3commons.mxmlblocks.api.IScriptBlock;

/**
 * The <code>IType</code> implementation and abstract base class for the
 * <code>ClassTypeNode</code>, <code>InterfaceTypeNode</code> and
 * <code>FunctionTypeNode</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ScriptBlockNode extends ContentBlockNode implements IScriptBlock
{
	
	//----------------------------------
	//  fields
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.ITypeNode#fields
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
	public function ScriptBlockNode(node:IParserNode)
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
}
}