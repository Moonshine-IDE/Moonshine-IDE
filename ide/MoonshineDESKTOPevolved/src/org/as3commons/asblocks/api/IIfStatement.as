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
 * An if ( condition ) thenBlock else elseBlock statement; 
 * <code>if (condition) { } else { }</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ifs:IIfStatement = block.newIf(factory.newExpression("foo"));
 * ifs.addStatement("trace('true')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	if (foo) {
 * 		trace(true);
 * 	}
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ifs:IIfStatement = block.newIf(factory.newExpression("foo"));
 * ifs.condition = factory.newExpression("foo == bar && baz != foo");
 * ifs.addStatement("trace('true')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	if (foo == bar && baz != foo) {
 * 		trace(true);
 * 	}
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ifs:IIfStatement = block.newIf(factory.newExpression("foo"));
 * ifs.addStatement("trace('true')");
 * ifs.elseBlock.addStatement("trace('false')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	if (foo) {
 * 		trace(true);
 * 	} else {
 * 		trace(false);
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newIf()
 */
public interface IIfStatement extends IStatement, IStatementContainer
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
	 * The if statement's condition expression.
	 * 
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError if then block connot be null
	 */
	function get condition():IExpression;
	
	/**
	 * @private
	 */
	function set condition(value:IExpression):void;
	
	//----------------------------------
	//  thenBlock
	//----------------------------------
	
	/**
	 * The if statement's then block (<code>if (condition) { thenBlock }</code>).
	 * 
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError if then block connot be null
	 */
	function get thenBlock():IBlock;
	
	/**
	 * @private
	 */
	function set thenBlock(value:IBlock):void;
	
	//----------------------------------
	//  elseBlock
	//----------------------------------
	
	/**
	 * The if statement's else block (<code>if (condition) { thenBlock } 
	 * else { elseBlock }</code>).
	 * 
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError Expecting an IBlock
	 */
	function get elseBlock():IBlock;
	
	/**
	 * @private
	 */
	function set elseBlock(value:IBlock):void;
}
}