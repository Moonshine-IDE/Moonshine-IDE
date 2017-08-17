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
 * A function parameter; <code>(arg0:int = 0)</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IFunction#addParameter()
 * @see org.as3commons.asblocks.api.IFunction#addRestParameter()
 * @see org.as3commons.asblocks.api.IFunction#removeParameter()
 * @see org.as3commons.asblocks.api.IFunction#getParameter()
 */
public interface IParameter extends IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  description
	//----------------------------------
	
	/**
	 * The asdoc description for the parameter.
	 * 
	 * <p>Setting this value will update the documentation <strong>param</strong>
	 * tag for the function owner.</p>
	 */
	function get description():String;
	
	/**
	 * @private
	 */
	function set description(value:String):void;
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * The name of the parameter; after the <code>(</code> or <code>,</code>.
	 */
	function get name():String;
	
	/**
	 * @private
	 */
	function set name(value:String):void;
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * The type of the parameter; after the <code>:</code>.
	 */
	function get type():String;
	
	/**
	 * @private
	 */
	function set type(value:String):void;
	
	//----------------------------------
	//  qualifiedType
	//----------------------------------
	
	/**
	 * The qualified (resolved from imports or package) type.
	 */
	function get qualifiedType():String;
	
	//----------------------------------
	//  hasType
	//----------------------------------
	
	/**
	 * Returns whether the parameter contains a type.
	 */
	function get hasType():Boolean;
	
	//----------------------------------
	//  defaultValue
	//----------------------------------
	
	/**
	 * The parameters default value that is read after an <code>=</code> sign.
	 */
	function get defaultValue():String;
	
	/**
	 * @private
	 */
	function set defaultValue(value:String):void;
	
	//----------------------------------
	//  hasDefaultValue
	//----------------------------------
	
	/**
	 * Returns <code>true</code> if a default value exist.
	 */
	function get hasDefaultValue():Boolean;
	
	//----------------------------------
	//  isRest
	//----------------------------------
	
	/**
	 * Whether this parameter is a rest that appears at the end of the parameter
	 * list.
	 */
	function get isRest():Boolean;
}
}