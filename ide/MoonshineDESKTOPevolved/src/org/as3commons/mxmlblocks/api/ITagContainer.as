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

package org.as3commons.mxmlblocks.api
{

import org.as3commons.asblocks.parser.api.IToken;

/**
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface ITagContainer
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  id
	//----------------------------------
	
	/**
	 * The tag's identifier name.
	 */
	function get id():String;
	
	//----------------------------------
	//  binding
	//----------------------------------
	
	/**
	 * The tag's binding.
	 */
	function get binding():String;
	
	/**
	 * @private
	 */
	function set binding(value:String):void;
	
	//----------------------------------
	//  localName
	//----------------------------------
	
	/**
	 * The tag's localName.
	 */
	function get localName():String;
	
	/**
	 * @private
	 */
	function set localName(value:String):void;
	
	//----------------------------------
	//  hasChildren
	//----------------------------------
	
	/**
	 * Whether the tag has children.
	 */
	function get hasChildren():Boolean;
	
	//----------------------------------
	//  namespaces
	//----------------------------------
	
	/**
	 * The tag's namespaces
	 */
	function get namespaces():Vector.<IXMLNamespace>;
	
	//----------------------------------
	//  attributes
	//----------------------------------
	
	/**
	 * The tag's attributes.
	 */
	function get attributes():Vector.<IAttribute>;
	
	//----------------------------------
	//  children
	//----------------------------------
	
	/**
	 * The tag's children.
	 */
	function get children():Vector.<ITag>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds a comment to the tag.
	 * 
	 * @param text The String text comment.
	 * @return The added token.
	 */
	function addComment(text:String):IToken;
	
	/**
	 * @private
	 */
	//function removeComment(statement:IStatement):IToken;
	
	/**
	 * Creates a new <code>xmlns:bar="bar"</code>.
	 * 
	 * @param localName The simple namespace name.
	 * @param uri A String identifier.
	 * @return A new <code>IXMLNamespace</code>.
	 * 
	 * @see org.as3commons.mxmlblocks.api.IXMLNamespace
	 */
	function newXMLNS(localName:String, uri:String):IXMLNamespace;
	
	/**
	 * Creates a new <code>bar="bar"</code>.
	 * 
	 * @param name The simple name.
	 * @param value The String value.
	 * @param state The String state of the attribute.
	 * @return A new <code>IAttribute</code>.
	 * 
	 * @see org.as3commons.mxmlblocks.api.IAttribute
	 */
	function newAttribute(name:String, value:String, state:String = null):IAttribute;
	
	/**
	 * Creates a new <code>&lt;x:Foo&gt;&lt;/x:Foo&gt;</code> tag.
	 * 
	 * @param name The simple name.
	 * @param binding The String block binding.
	 * @return A new <code>IBlockTag</code>.
	 * 
	 * @see org.as3commons.mxmlblocks.api.IBlockTag
	 */
	function newTag(name:String, binding:String = null):IBlockTag;
	
	/**
	 * Creates a new <code>&lt;x:Script&gt;&lt;[CDATA[code]]&gt;&lt;/x:Script&gt;</code> tag.
	 * 
	 * @param code The script code.
	 * @return A new <code>IScriptTag</code>.
	 * 
	 * @see org.as3commons.mxmlblocks.api.IScriptTag
	 */
	function newScriptTag(code:String = null):IScriptTag;
	
	/**
	 * Creates a new <code>&lt;x:Metadata&gt;&lt;[CDATA[meta]]&gt;&lt;/x:Metadata&gt;</code> tag.
	 * 
	 * @param code The script code.
	 * @return A new <code>IMetadataTag</code>.
	 * 
	 * @see org.as3commons.mxmlblocks.api.IMetadataTag
	 */
	function newMetadataTag(code:String = null):IMetadataTag;
}
}