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
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.api.ICatchClause;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>ICatchClause</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class CatchClauseNode extends ContainerDelegate 
	implements ICatchClause
{
	//catch
	//catch/name
	//catch/type
	//catch/block
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function get statementContainer():IStatementContainer
	{
		return new StatementList(node.getLastChild()); // block
	}
	
	//--------------------------------------------------------------------------
	//
	//  ICatchClause API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.ICatchClause#name
	 */
	public function get name():String
	{
		return ASTUtil.nameText(node.getChild(0));
	}
	
	/**
	 * @private
	 */	
	public function set name(value:String):void
	{
		var ast:IParserNode = AS3FragmentParser.parseName(value);
		node.setChildAt(ast, 0);
	}
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.ICatchClause#type
	 */
	public function get type():String
	{
		return ASTUtil.typeText(node.getChild(1));
	}
	
	/**
	 * @private
	 */	
	public function set type(value:String):void
	{
		var ast:IParserNode = AS3FragmentParser.parseType(value);
		node.setChildAt(ast, 1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function CatchClauseNode(node:IParserNode)
	{
		super(node);
	}
}
}