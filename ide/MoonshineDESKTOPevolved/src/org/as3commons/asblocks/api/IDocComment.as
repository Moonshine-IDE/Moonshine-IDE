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

package org.as3commons.asblocks.api
{
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The comment node of an <code>IDocCommentAware</code> client.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IDocComment extends IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  asdocNode
	//----------------------------------
	
	/**
	 * TODO Docme
	 */
	function get asdocNode():IParserNode;
	
	/**
	 * @private
	 */
	function set asdocNode(value:IParserNode):void;
	
	//----------------------------------
	//  description
	//----------------------------------
	
	/**
	 * The string description minus the doc tags.
	 */
	function get description():String;
	
	/**
	 * @private
	 */
	function set description(value:String):void;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	function newDocTag(name:String, body:String = null):IDocTag;
	
	function removeDocTag(tag:IDocTag):Boolean;
	
	function hasDocTag(name:String):Boolean;
}
}