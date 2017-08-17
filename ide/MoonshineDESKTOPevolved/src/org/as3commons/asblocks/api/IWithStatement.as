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
 * A with statement; <code>with (object) {}</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var object:IExpression = factory.newExpression("foo.bar");
 * var ws:IWithStatement = block.newWith(object);
 * ws.addStatement("baz = 42");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	with (foo.bar) {
 * 		baz = 42;
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newWith()
 */
public interface IWithStatement extends IStatement, IStatementContainer
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  scope
	//----------------------------------
	
	/**
	 * The target object's scope that each statement within the body resolves to.
	 */
	function get scope():IExpression;
	
	/**
	 * @private
	 */
	function set scope(value:IExpression):void;
	
	//----------------------------------
	//  body
	//----------------------------------
	
	/**
	 * The with statement's child statement or block.
	 */
	function get body():IStatement;
}
}