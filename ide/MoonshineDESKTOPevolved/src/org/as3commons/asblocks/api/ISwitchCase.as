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
 * A switch case; <code>switch { case 1: statement; }</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ss:ISwitchStatement = block.newSwitch(factory.newExpression("foo"));
 * var sc:ISwitchCase = ss.newCase("1");
 * sc.addStatement("trace('one')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	switch (foo) {
 * 		case 1:
 * 			trace('one');
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newSwitch()
 * @see org.as3commons.asblocks.api.ISwitchStatement#newCase()
 */
public interface ISwitchCase extends ISwitchLabel
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  label
	//----------------------------------
	
	/**
	 * The case's label expression.
	 */
	function get label():IExpression;
	
	/**
	 * @private
	 */
	function set label(value:IExpression):void;
}
}