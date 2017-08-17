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

package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.IBreakStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;

/**
 * The <code>IBreakStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class BreakStatementNode extends ScriptNode implements IBreakStatement
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  label
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IBreakStatement.label
	 */
	public function get label():IExpression
	{
		if (node.numChildren == 0)
			return null;
		
		return ExpressionBuilder.build(node.getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set label(value:IExpression):void
	{
		var label:IParserNode = findLabel();
		if (label)
		{
			var ws:LinkedListToken = label.startToken.previous;
			if (ws.kind == "ws")
			{
				ws.remove();
			}
			node.removeChild(label);
		}
		
		if (value == null)
			return;	
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function BreakStatementNode(node:IParserNode)
	{
		super(node);
	}
	
	private function findLabel():IParserNode
	{
		return node.getFirstChild();
	}
}
}