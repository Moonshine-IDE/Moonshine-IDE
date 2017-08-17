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

/**
 * A metadata annotation; <code>[Name(value, name=value, name="value")]</code>.
 * 
 * <pre>
 * var md:IMetaData = aware.newMetaData("Foo");
 * md.addParameter("bar");
 * md.addNamedParameter("bar", "baz");
 * md.addNamedStringParameter("goo", "ber");
 * </pre>
 * 
 * <p>Will produce; <code>[Foo(bar, bar=baz, goo="ber")]</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IMetaData extends IScriptNode, IDocCommentAware
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
	 * The name of the metadata tag.
	 */
	function get name():String;
	
	//----------------------------------
	//  parameter
	//----------------------------------
	
	/**
	 * The original String found between the <code>[(</code> and <code>)]</code>.
	 * 
	 * <p>If there was no parenthesis, this property value is null.</p>
	 */
	function get parameter():String;
	
	//----------------------------------
	//  parameters
	//----------------------------------
	
	/**
	 * The Vector of <code>IMetaDataParameter</code> instances.
	 */
	function get parameters():Vector.<IMetaDataParameter>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds a value parameter (<code>[Foo(value)]</code>) to the metadata.
	 * 
	 * @param value The String value.
	 * @return A <code>IMetaDataParameter</code> instance.
	 */
	function addParameter(value:String):IMetaDataParameter;
	
	/**
	 * Adds a named parameter (<code>[Foo(name=value)]</code>) to the metadata.
	 * 
	 * @param name The String name.
	 * @param value The String value.
	 * @return A <code>IMetaDataParameter</code> instance.
	 */
	function addNamedParameter(name:String, value:String):IMetaDataParameter;
	
	/**
	 * Adds a named String parameter (<code>[Foo(name="value")]</code>) to the metadata.
	 * 
	 * @param name The String name.
	 * @param value The String value.
	 * @return A <code>IMetaDataParameter</code> instance.
	 */
	function addNamedStringParameter(name:String, value:String):IMetaDataParameter;
	
	/**
	 * Removes a named parameter from the metadata.
	 * 
	 * @param name The String name.
	 * @return A <code>IMetaDataParameter</code> instance if removed, <code>null</code>
	 * if not.
	 */
	function removeParameter(name:String):IMetaDataParameter;
	
	/**
	 * Removes a parameter from the metadata at the specified index.
	 * 
	 * @param index The int index.
	 * @return A <code>IMetaDataParameter</code> instance if removed, <code>null</code>
	 * if not.
	 */
	function removeParameterAt(index:int):IMetaDataParameter;
	
	/**
	 * Returns a <code>IMetaDataParameter</code> by the specified name
	 * or <code>null</code> if the named parameter does not exist.
	 * 
	 * @param name A String parameter name.
	 * @return A <code>IMetaDataParameter</code> or <code>null</code>.
	 */
	function getParameter(name:String):IMetaDataParameter;
	
	/**
	 * Returns a <code>IMetaDataParameter</code> at the specified index
	 * or <code>null</code> if the index is out of range.
	 * 
	 * @param index An int specifying the parameter to return.
	 * @return A <code>IMetaDataParameter</code> or <code>null</code>.
	 */
	function getParameterAt(index:int):IMetaDataParameter;
	
	/**
	 * Returns a <code>IMetaDataParameter.value</code> with the specified name
	 * or <code>null</code> if the paramater dosn't exist.
	 * 
	 * @param name A String parameter name.
	 * @return A String parameter value or <code>null</code>.
	 */
	function getParameterValue(name:String):String;
	
	/**
	 * Returns whether the metadata contains a parameter by the name, 
	 * <code>name</code>.
	 * 
	 * @param name A String parameter name.
	 * @return A Boolean indicating whether the name exists in a paramter.
	 */
	function hasParameter(name:String):Boolean;
}
}