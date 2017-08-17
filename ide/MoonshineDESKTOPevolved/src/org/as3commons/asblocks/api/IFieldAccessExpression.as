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
 * Field access; <code>target.name</code>.
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("foo()");
 * var name:String = "bar";
 * var fa:IFieldAccessExpression = factory.newFieldAccessExpression(target, name);
 * </pre>
 * 
 * <p>Will produce; <code>foo().bar</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newFieldAccessExpression()
 */
public interface IFieldAccessExpression extends IExpression, IScriptNode
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
	 * The simple String name of the expression <code>target.name<code>.
	 */
	function get name():String;
	
	/**
	 * @private
	 */
	function set name(value:String):void;
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * The target <code>IExpression<code> the field name accesses.
	 */
	function get target():IExpression;
	
	/**
	 * @private
	 */
	function set target(value:IExpression):void;
}
}