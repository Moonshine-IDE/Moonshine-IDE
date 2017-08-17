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

import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.mxmlblocks.api.IAttribute;
import org.as3commons.mxmlblocks.api.IBlockTag;
import org.as3commons.mxmlblocks.api.IMetadataTag;
import org.as3commons.mxmlblocks.api.IScriptTag;
import org.as3commons.mxmlblocks.api.ITag;
import org.as3commons.mxmlblocks.api.ITagContainer;
import org.as3commons.mxmlblocks.api.IXMLNamespace;

/**
 * The <code>ITagContainer</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TagContainerDelegate extends ScriptNode implements ITagContainer
{
	//--------------------------------------------------------------------------
	//
	//  Protected :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function get container():ITagContainer
	{
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  ITagContainer API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  id
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#id
	 */
	public function get id():String
	{
		return container.id;
	}
	
	//----------------------------------
	//  binding
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#binding
	 */
	public function get binding():String
	{
		return container.binding;
	}
	
	/**
	 * @private
	 */	
	public function set binding(value:String):void
	{
		container.binding = value;
	}
	
	//----------------------------------
	//  localName
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#localName
	 */
	public function get localName():String
	{
		return container.localName;
	}
	
	/**
	 * @private
	 */	
	public function set localName(value:String):void
	{
		container.localName = value;
	}
	
	//----------------------------------
	//  hasChildren
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#hasChildren
	 */
	public function get hasChildren():Boolean
	{
		return container.hasChildren;
	}
	
	//----------------------------------
	//  namespaces
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#namespaces
	 */
	public function get namespaces():Vector.<IXMLNamespace>
	{
		return container.namespaces;
	}
	
	//----------------------------------
	//  attributes
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#attributes
	 */
	public function get attributes():Vector.<IAttribute>
	{
		return container.attributes;
	}
	
	//----------------------------------
	//  children
	//----------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#children
	 */
	public function get children():Vector.<ITag>
	{
		return container.children;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function TagContainerDelegate(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IBlockTag API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#addComment()
	 */
	public function addComment(text:String):IToken
	{
		return container.addComment(text);
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newXMLNS()
	 */
	public function newXMLNS(localName:String, uri:String):IXMLNamespace
	{
		return container.newXMLNS(localName, uri);
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newAttribute()
	 */
	public function newAttribute(name:String, value:String, state:String = null):IAttribute
	{
		return container.newAttribute(name, value, state);
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newTag()
	 */
	public function newTag(name:String, binding:String = null):IBlockTag
	{
		return container.newTag(name, binding);
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newScriptTag()
	 */
	public function newScriptTag(code:String = null):IScriptTag
	{
		return container.newScriptTag(code);
	}
	
	/**
	 * @copy org.as3commons.mxmlblocks.api.ITagContainer#newMetadataTag()
	 */
	public function newMetadataTag(code:String = null):IMetadataTag
	{
		return container.newMetadataTag(code);
	}
}
}