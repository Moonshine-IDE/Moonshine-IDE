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
 * Conditional expression (ternary operator); <code>condition ? then : else</code>.
 * 
 * <pre>
 * var condition:IExpression = factory.newExpression("foo");
 * var thenExp:IExpression = factory.newExpression("bar");
 * var elseExp:IExpression = factory.newExpression("baz");
 * var ce:IConditionalExpression = factory.newConditionalExpression(condition, thenExp, elseExp);
 * </pre>
 * 
 * <p>Will produce; <code>foo ? bar : baz</code>.</p>
 * 
 * <pre>
 * var condition:IExpression = factory.newExpression("foo");
 * var thenExp:IExpression = factory.newExpression("bar");
 * var elseExp:IExpression = factory.newExpression("baz");
 * var ce:IConditionalExpression = factory.newConditionalExpression(condition, thenExp, elseExp);
 * ce.condition = factory.newExpression("foo < 42");
 * ce.thenExpression = factory.newExpression("foBar()");
 * ce.elseExpression = factory.newExpression("foBaz()");
 * </pre>
 * 
 * <p>Will produce; <code>foo > 42 ? foBar() : foBaz()</code>.</p>
 * 
 * <pre>
 * var ce:IConditionalExpression = factory.newExpression("foo ? bar : baz");
 * </pre>
 * 
 * <p>Will produce an <code>IConditionalExpression</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newConditionalExpression()
 */
public interface IConditionalExpression extends IExpression, IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  condition
	//----------------------------------
	
	/**
	 * The condition expression that resolves to the <code>thenExpression</code> 
	 * or <code>elseExpression</code>.
	 */
	function get condition():IExpression;
	
	/**
	 * @private
	 */
	function set condition(value:IExpression):void;
	
	//----------------------------------
	//  thenExpression
	//----------------------------------
	
	/**
	 * The expression that is executed when the <code>condition</code> is 
	 * <code>true</code>.
	 */
	function get thenExpression():IExpression;
	
	/**
	 * @private
	 */
	function set thenExpression(value:IExpression):void;
	
	//----------------------------------
	//  elseExpression
	//----------------------------------
	
	/**
	 * The expression that is executed when the <code>condition</code> is 
	 * <code>false</code>.
	 */
	function get elseExpression():IExpression;
	
	/**
	 * @private
	 */
	function set elseExpression(value:IExpression):void;
}
}