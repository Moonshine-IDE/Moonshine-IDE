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
import org.as3commons.asblocks.api.IMember;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.Modifier;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;
import org.as3commons.asblocks.utils.MetaDataUtil;
import org.as3commons.asblocks.utils.ModifierUtil;
import org.as3commons.asblocks.utils.NameTypeUtil;

/**
 * The <code>IMember</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MemberNode extends ScriptNode implements IMember
{
	//--------------------------------------------------------------------------
	//
	//  IMember API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  visibility
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMember#visibility
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
		return ModifierUtil.setVisibility(node, value);
	}
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMember#name
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
		if (value.indexOf(".") != -1)
		{
			throw new ASBlocksSyntaxError("IMember names cannot contain a period");
		}
		NameTypeUtil.setName(node, value);
	}
	
	//----------------------------------
	//  qualifiedName
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMember#qualifiedName
	 */
	public function get qualifiedName():String
	{
		return NameTypeUtil.getQualfiedName(this);
	}
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMember#type
	 */
	public function get type():String
	{
		return NameTypeUtil.getType(node);
	}
	
	/**
	 * @private
	 */	
	public function set type(value:String):void
	{
		NameTypeUtil.setType(node, value);
	}
	
	//----------------------------------
	//  qualifiedType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#qualifiedType
	 */
	public function get qualifiedType():String
	{
		if (!type)
			return null;
		
		return ASTUtil.qualifiedNameForTypeString(node, type);
	}
	
	//----------------------------------
	//  isStatic
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMember#isStatic
	 */
	public function get isStatic():Boolean
	{
		return ModifierUtil.hasModifierFlag(node, Modifier.STATIC);
	}
	
	/**
	 * @private
	 */	
	public function set isStatic(value:Boolean):void
	{
		ModifierUtil.setModifierFlag(node, value, Modifier.STATIC);
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
	public function MemberNode(node:IParserNode)
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