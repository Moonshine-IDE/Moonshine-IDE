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

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IScriptNode</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ScriptNode implements IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  IScriptNode API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  node
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _node:IParserNode;
	
	/**
	 * @copy org.as3commons.asblocks.api.IScriptNode#node
	 */
	public function get node():IParserNode
	{
		return _node;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ScriptNode(node:IParserNode)
	{
		_node = node;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function toString():String
	{
		return ASTUtil.convert(_node);
	}
}
}