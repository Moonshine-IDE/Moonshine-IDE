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

import org.as3commons.asblocks.api.IForLabelStatement;
import org.as3commons.asblocks.api.IForStatement;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>ILabelStatement</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ForLabelStatementNode extends LabelStatementNode 
	implements IForLabelStatement
{
	//--------------------------------------------------------------------------
	//
	//  ILabelStatement API :: Properties
	//
	//--------------------------------------------------------------------------
	
	override protected function get statementContainer():IStatementContainer
	{
		return new StatementList(node.getLastChild());
	}
	
	//----------------------------------
	//  statement
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get statement():IForStatement
	{
		var ast:IParserNode = node.getLastChild();
		if (!ast.getLastChild().isKind(AS3NodeKind.BLOCK))
		{
			ASTUtil.addChildWithIndentation(ast, ASTStatementBuilder.newBlock());
		}
		return new ForStatementNode(ast);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ForLabelStatementNode(node:IParserNode)
	{
		super(node);
	}
}
}