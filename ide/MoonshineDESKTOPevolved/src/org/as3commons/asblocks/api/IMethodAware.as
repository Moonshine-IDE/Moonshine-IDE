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
 * The <code>IClassType</code> is the supertype for the <code>IClassType</code>,
 * <code>IInterfaceType</code> and <code>IFunctionType</code> types.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newClass()
 * @see org.as3commons.asblocks.ASFactory#newInterface()
 * @see org.as3commons.asblocks.ASFactory#newFunction()
 * @see org.as3commons.asblocks.IASProject#newClass()
 * @see org.as3commons.asblocks.IASProject#newInterface()
 * @see org.as3commons.asblocks.IASProject#newFunction()
 */
public interface IMethodAware
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  methods
	//----------------------------------
	
	/**
	 * Returns the Vector of <code>IMethod</code> held on this type.
	 * 
	 * <p>The property always returns a Vector regaurdless of methods defined.
	 * The property will not return <code>null</code>.</p>
	 */
	function get methods():Vector.<IMethod>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates, appends and returns a new <code>IMethod</code> instance.
	 * 
	 * @param name The <code>String</code> name of the method.
	 * @param visibility The <code>Visibility</code> of the method.
	 * @param returnType The return type of the method.
	 * @return A new <code>IMethod</code> instance appended to the type.
	 */
	function newMethod(name:String, 
					   visibility:Visibility, 
					   returnType:String):IMethod;
	
	/**
	 * Returns an <code>IMethod</code> instance if found or <code>null</code> 
	 * if the type does not contain a method by name.
	 * 
	 * @return The <code>IMethod</code> instance by name or <code>null</code>.
	 */
	function getMethod(name:String):IMethod;
	
	/**
	 * Attemps to remove an <code>IMethod</code> instance by name.
	 * 
	 * @param name The <code>String</code> name of the method.
	 * @return An <code>IMethod</code> indicating whether a method by name was 
	 * found and removed (<code>IMethod</code>), or (<code>null</code>) if not.
	 */
	function removeMethod(name:String):IMethod;
}
}