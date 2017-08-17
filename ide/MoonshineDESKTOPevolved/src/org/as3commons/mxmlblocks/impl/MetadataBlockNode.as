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

import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.MetaDataUtil;
import org.as3commons.mxmlblocks.api.IMetadataBlock;

/**
 * The <code>IType</code> implementation and abstract base class for the
 * <code>ClassTypeNode</code>, <code>InterfaceTypeNode</code> and
 * <code>FunctionTypeNode</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MetadataBlockNode extends ScriptNode implements IMetadataBlock
{
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
		return MetaDataUtil.getMetaDatas(findContent());
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function MetadataBlockNode(node:IParserNode)
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
		return MetaDataUtil.newMetaData(findContent(), name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getMetaData()
	 */
	public function getMetaData(name:String):IMetaData
	{
		return MetaDataUtil.getMetaData(findContent(), name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#getAllMetaData()
	 */
	public function getAllMetaData(name:String):Vector.<IMetaData>
	{
		return MetaDataUtil.getAllMetaData(findContent(), name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#hasMetaData()
	 */
	public function hasMetaData(name:String):Boolean
	{
		return MetaDataUtil.hasMetaData(findContent(), name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IMetaDataAware#removeMetaData()
	 */
	public function removeMetaData(metaData:IMetaData):Boolean
	{
		return MetaDataUtil.removeMetaData(findContent(), metaData);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function findContent():IParserNode
	{
		return node.getKind(AS3NodeKind.CONTENT);
	}
}
}