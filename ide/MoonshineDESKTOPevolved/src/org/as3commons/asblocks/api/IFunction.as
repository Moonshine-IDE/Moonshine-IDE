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
 * A common interface for <code>IMethod</code> and <code>IFunctionLiteral</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IType#newMethod()
 * @see org.as3commons.asblocks.ASFactory#newFunctionLiteral()
 * @see org.as3commons.asblocks.api.IMethod
 * @see org.as3commons.asblocks.api.IFunctionLiteral
 */
public interface IFunction
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  parameters
	//----------------------------------
	
	/**
	 * A Vector of <code>IParameter</code> instances, an empty Vector if the 
	 * function does not contain a parameter list.
	 */
	function get parameters():Vector.<IParameter>;
	
	//----------------------------------
	//  hasParameter
	//----------------------------------
	
	/**
	 * Returns a <code>Boolean</code> indicating whether the function contains 
	 * a parameter list.
	 */
	function get hasParameters():Boolean;
	
	//----------------------------------
	//  returnType
	//----------------------------------
	
	/**
	 * The return type of the function, this value may include a period.
	 * 
	 * <p>If a period is found in the type, the type is considered a
	 * qualified type else it is a simple type.</p>
	 */
	function get returnType():String;
	
	/**
	 * @private
	 */
	function set returnType(value:String):void;
	
	//----------------------------------
	//  qualifiedReturnType
	//----------------------------------
	
	/**
	 * The qualified return type (resolved from imports or package).
	 */
	function get qualifiedReturnType():String;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds a parameter to the function's parameter list.
	 * 
	 * @param name The <code>String</code> name of the parameter to add.
	 * @param type The <code>String</code> type of the parameter (may include
	 * a period for a qualified type).
	 * @param defaultValue The <code>String</code> default value of the type.
	 * This is the value found after the <code>=</code> sign.
	 * @return A new <code>IParameter</code> instance or throws and error if a
	 * parameter is found with the same name.
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError 
	 * a parameter name already exists
	 */
	function addParameter(name:String, type:String, defaultValue:String = null):IParameter;
	
	/**
	 * Removes a parameter from the function's parameter list.
	 * 
	 * @param name The <code>String</code> name of the parameter to remove.
	 * @return A <code>IParameter</code> instance if removed or <code>null</code> 
	 * if the parameter was not found. 
	 */
	function removeParameter(name:String):IParameter;
	
	/**
	 * Adds a rest parameter to the end of the function's parameter list.
	 * 
	 * @param name The <code>String</code> name of the rest parameter to add.
	 * @return A new <code>IParameter</code> instance or throws and error if a
	 * rest parameter already exists.
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError 
	 * only one rest parameter allowed
	 */
	function addRestParameter(name:String):IParameter;
	
	/**
	 * Removes the rest parameter from the function's parameter list.
	 * 
	 * @return A <code>IParameter</code> instance if the rest removed or 
	 * <code>null</code> if the rest parameter was not found. 
	 */
	function removeRestParameter():IParameter;
	
	/**
	 * Returns an <code>IParameter</code> instance by name.
	 * 
	 * @param name The <code>String</code> name of the parameter.
	 * @return An <code>IParameter</code> instance the same name or <code>null</code>
	 * if not found.
	 */
	function getParameter(name:String):IParameter;
	
	/**
	 * Returns a <code>Boolean</code> indicating whether the function contains
	 * a parameter by name.
	 * 
	 * @param name The <code>String</code> name of the parameter.
	 * @return A <code>Boolean</code> indicating whether the parameter exists.
	 */
	function hasParameter(name:String):Boolean;
	
	/**
	 * Returns a <code>Boolean</code> indicating whether the function contains
	 * a rest parameter.
	 * 
	 * @return A <code>Boolean</code> indicating whether the rest parameter exists.
	 */
	function hasRestParameter():Boolean;
}
}