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
 * An Array literal; <code>[1,2,3]</code>.
 * 
 * <pre>
 * var al:IArrayLiteral = factory.newArrayLiteral();
 * al.add(factory.newNumberLiteral(1));
 * al.add(factory.newStringLiteral("two"));
 * al.add(factory.newNumberLiteral(3));
 * </pre>
 * 
 * <p>Will produce; <code>[1,"two",3]</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newArrayLiteral()
 */
public interface IArrayLiteral 
	extends IExpression, ILiteral, IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The Vector of <code>IExpression</code> entries in the array literal.
	 * 
	 * <p>The entries appear between the <code>[</code> and <code>]</code> 
	 * brackets and are separated by commas.</p>
	 * 
	 * <p><strong>Note:</strong> - Do not attempt to add or remove items from 
	 * this Vector, the AST will not be updated.</p>
	 * 
	 * @see #add()
	 * @see #remove()
	 */
	function get entries():Vector.<IExpression>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Add an <code>IExpression</code> entry to the array literal.
	 * 
	 * @param expression An <code>IExpression</code> to add to the array literal.
	 */
	function add(expression:IExpression):void;
	
	/**
	 * Remove an <code>IExpression</code> entry from the array literal at the
	 * specified index.
	 * 
	 * @param index The index to remove, returns the removed <code>IExpression</code>
	 * if successfull, <code>null</code> if not.
	 */
	function remove(index:int):IExpression;
}
}