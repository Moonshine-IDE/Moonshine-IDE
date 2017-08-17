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

/**
 * An MXML xmlns declaration attribute; <code>xmlns="*"</code> or 
 * <code>xmlns:localName="uri"</code>.
 * 
 * <pre>
 * var tag:ITagBlock = factory.newTag("Foo");
 * var xmlns:IXMLNamespace = tag.newXMLNS("foo", "foo.bar.*");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * &lt;Foo xmlns:foo="foo.bar.*"&gt;
 * &lt;/Foo&gt;
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.mxmlblocks.api.ITagContainer#newXMLNS()
 */
public interface IXMLNamespace
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  localName
	//----------------------------------
	
	/**
	 * The local name of the namespace, this name is placed after the 
	 * <code>:</code>.
	 */
	function get localName():String;
	
	/**
	 * @private
	 */
	function set localName(value:String):void;
	
	//----------------------------------
	//  uri
	//----------------------------------
	
	/**
	 * The uri of the namespace, this name is placed after the 
	 * <code>=</code>.
	 * 
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError 
	 * uri for IXMLNamespace cannot be null
	 */
	function get uri():String;
	
	/**
	 * @private
	 */
	function set uri(value:String):void;
}
}