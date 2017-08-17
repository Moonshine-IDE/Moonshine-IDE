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
 * A switch statement; <code>switch (condition) { case: break; default: break; }</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ss:ISwitchStatement = block.newSwitch(factory.newExpression("foo"));
 * var sc:ISwitchCase = ss.newCase("1");
 * sc.addStatement("trace('one')");
 * var sd:ISwitchDefault = ss.newDefault();
 * sd.addStatement("trace('default')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	switch (foo) {
 * 		case 1:
 * 			trace('one');
 * 		default:
 * 			trace('default');
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newSwitch()
 * @see org.as3commons.asblocks.api.ISwitchCase
 * @see org.as3commons.asblocks.api.ISwitchDefault
 */
public interface ISwitchStatement extends IStatement
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
	 * The switch statement's condition expression.
	 */
	function get condition():IExpression;
	
	/**
	 * @private
	 */
	function set condition(value:IExpression):void;
	
	//----------------------------------
	//  labels
	//----------------------------------
	
	/**
	 * The switch statement's Vector of <code>ISwitchLabel</code> statements,
	 * (the <code>case</code> and <code>default</code> statements).
	 */
	function get labels():Vector.<ISwitchLabel>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates and appends a new <code>case</code> label statement to the 
	 * <code>switch</code> statement.
	 * 
	 * @param label A <code>String</code> indicating the label's name.
	 * @return A new <code>ISwitchCase</code> statement.
	 */
	function newCase(label:String):ISwitchCase;
	
	/**
	 * Creates and appends a new <code>default</code> label statement to the 
	 * <code>switch</code> statement.
	 * 
	 * <p>Note: Only one <code>default</code> label statement is allowed per
	 * switch statement.</p>
	 * 
	 * @return A new <code>ISwitchDefault</code> statement.
	 */
	function newDefault():ISwitchDefault;
}
}