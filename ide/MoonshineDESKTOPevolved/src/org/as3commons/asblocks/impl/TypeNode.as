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
import org.as3commons.asblocks.api.IDocComment;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.IType;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;
import org.as3commons.asblocks.utils.MetaDataUtil;
import org.as3commons.asblocks.utils.ModifierUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IType</code> implementation and abstract base class for the
 * <code>ClassTypeNode</code>, <code>InterfaceTypeNode</code> and
 * <code>FunctionTypeNode</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TypeNode extends ContentBlockNode implements IType
{
	//--------------------------------------------------------------------------
	//
	//  IType API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  visibility
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IType#visibility
	 */
	public function get visibility():Visibility
	{
		return ModifierUtil.getVisibility(node);
	}
	
	/**
	 * @private
	 */	
	public function set visibility(value:Visibility):void
	{
		if (!value.equals(Visibility.PUBLIC))
		{
			throw new ASBlocksSyntaxError("IType visibility must be public");
		}
		return ModifierUtil.setVisibility(node, value);
	}
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IType#name
	 */
	public function get name():String
	{
		return NameTypeUtil.getName(node);
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
		NameTypeUtil.setName(node, value);
	}
	
	//----------------------------------
	//  packageName
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IType#packageName
	 */
	public function get packageName():String
	{
		return ASTUtil.packageNameForType(this);
	}
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IType#qualifiedName
	 */
	public function get qualifiedName():String
	{
		return ASTUtil.qualifiedNameForType(this);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IMetaDataAware API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  metaDatas
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#metaDatas
	 */
	public function get metaDatas():Vector.<IMetaData>
	{
		return MetaDataUtil.getMetaDatas(node);
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
		return null;
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
	public function TypeNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IMetaDataAware API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#newMetaData()
	 */
	public function newMetaData(name:String):IMetaData
	{
		return MetaDataUtil.newMetaData(node, name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getMetaData()
	 */
	public function getMetaData(name:String):IMetaData
	{
		return MetaDataUtil.getMetaData(node, name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getAllMetaData()
	 */
	public function getAllMetaData(name:String):Vector.<IMetaData>
	{
		return MetaDataUtil.getAllMetaData(node, name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#hasMetaData()
	 */
	public function hasMetaData(name:String):Boolean
	{
		return MetaDataUtil.hasMetaData(node, name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#removeMetaData()
	 */
	public function removeMetaData(metaData:IMetaData):Boolean
	{
		return MetaDataUtil.removeMetaData(node, metaData);
	}
}
}