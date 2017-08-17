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
 * A this statement; <code>this.property</code> or <code>this.func(arg)</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThisStatement = block.newThis(factory.newExpression("property = 42"));
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	this.property = 42;
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThisStatement = block.newThis(factory.newExpression("foo(bar)"));
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	this.foo(bar);
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThisStatement = block.addStatement("this.foo(bar)") as IThisStatement;
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	this.foo(bar);
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newThis()
 */
public interface IThisStatement extends IStatement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  expression
	//----------------------------------
	
	/**
	 * The this's expression located after the <code>this</code> keyword 
	 * and period.
	 */
	function get expression():IExpression;
}
}