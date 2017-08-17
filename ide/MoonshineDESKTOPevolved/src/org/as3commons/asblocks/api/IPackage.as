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
 * The <code>IPackage</code> holds the public <code>IClassType</code>,
 * <code>IInterfaceType</code> and <code>IFunctionType</code> type definitions.
 * 
 * <p>This package type gets created as a side-effect from creating one of the above
 * types in a compilation unit.</p>
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
public interface IPackage extends IScriptNode
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
	 * The simple String name of the package.
	 */
	function get name():String;
	
	/**
	 * @private
	 */
	function set name(value:String):void;
	
	//----------------------------------
	//  typeNode
	//----------------------------------
	
	/**
	 * The <code>public</code> type, class, interface or function.
	 */
	function get typeNode():IType;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds an import to the package.
	 * 
	 * @param name the String qualified import name.
	 */
	function addImports(name:String):void;
	
	/**
	 * Removes an import from the package.
	 * 
	 * @param name the String qualified import name.
	 * @return A Boolean indicating whether the removal was successfull.
	 */
	function removeImport(name:String):Boolean;
	
	/**
	 * Returns a Vector of String qualified imports.
	 * 
	 * @return A String Vector of package imports.
	 */
	function findImports():Vector.<String>;
}
}