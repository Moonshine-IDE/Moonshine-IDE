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

import org.as3commons.asblocks.api.IScriptNode;

/**
 * An MXML attribute; <code>name="value"</code> or <code>name.state="value"</code>.
 * 
 * <pre>
 * var tag:ITagBlock = factory.newTag("Foo");
 * var attribute:IAttribute = tag.newAttribute("foo", "bar");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * &lt;Foo foo="bar"&gt;
 * &lt;/Foo&gt;
 * </pre>
 * 
 * <pre>
 * var tag:ITagBlock = factory.newTag("Foo");
 * var attribute:IAttribute = tag.newAttribute("foo", "bar", "baz");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * &lt;Foo foo.baz="bar"&gt;
 * &lt;/Foo&gt;
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.mxmlblocks.api.ITagContainer#newAttribute()
 */
public interface IAttribute extends IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * The name of the attribute.
	 */
	function get name():String;
	
	/**
	 * @private
	 */
	function set name(value:String):void;
	
	//----------------------------------
	//  value
	//----------------------------------
	
	/**
	 * The value of the attribute.
	 */
	function get value():String;
	
	/**
	 * @private
	 */
	function set value(value:String):void;
	
	//----------------------------------
	//  value
	//----------------------------------
	
	/**
	 * The state of the attribute.
	 */
	function get state():String;
	
	/**
	 * @private
	 */
	function set state(value:String):void;
}
}