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

import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.INewExpression;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>INewExpression</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class NewExpressionNode extends InvocationNode implements INewExpression
{
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override public function set arguments(value:Vector.<IExpression>):void
	{
		if (hasArguments)
		{
			if (value == null)
			{
				findCall().removeChildAt(1);
			}
			else
			{
				super.arguments = value;
			}
		}
		else
		{
			if (value != null)
			{
				super.arguments = value;
			}
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function NewExpressionNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function findCall():IParserNode
	{
		return node.getFirstChild();
	}
}
}