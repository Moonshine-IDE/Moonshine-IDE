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
 * Array access; <code>foo["bar"]</code> - <code>target</code>
 * [<code>subscript</code>].
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("myObject[42]");
 * var subscript:IExpression = factory.newExpression("0");
 * var aae:IArrayAccessExpression = factory.newArrayAccessExpression(target, subscript);
 * </pre>
 * 
 * <p>Will produce; <code>myObject[42][0]</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IArrayAccessExpression 
	extends IExpression, IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * The target expression occurs before the <code>[</code> -
	 * <code>target</code>[<code>subscript</code>].
	 */
	function get target():IExpression;
	
	/**
	 * @private
	 */
	function set target(value:IExpression):void;
	
	//----------------------------------
	//  subscript
	//----------------------------------
	
	/**
	 * The subscript expression occurs after the <code>[</code> -
	 * <code>target</code>[<code>subscript</code>].
	 */
	function get subscript():IExpression;
	
	/**
	 * @private
	 */
	function set subscript(value:IExpression):void;
}
}