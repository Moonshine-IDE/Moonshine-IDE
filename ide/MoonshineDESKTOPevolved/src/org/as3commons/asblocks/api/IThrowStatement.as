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
 * A throw statement; <code>throw new Error()</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThrowStatement = block.newThrow(factory.newExpression("new Error()"));
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	throw new Error();
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThrowStatement = block.newThrow(factory.newExpression("e1"));
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	throw e1;
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ts:IThrowStatement = block.addStatement("throw new Error('message')") as IThrowStatement;
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	throw new Error('message');
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newThrow()
 */
public interface IThrowStatement extends IStatement
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
	 * The throw's expression located after the <code>throw</code> keyword.
	 * 
	 * <p>This can either be a <code>new</code> expression or an identifier
	 * realating to an existing error instance.</p>
	 */
	function get expression():IExpression;
}
}