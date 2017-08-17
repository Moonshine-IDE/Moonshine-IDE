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

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.api.IStatement;

/**
 * Builds <code>IStatement</code> implementations based on ast kinds.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class StatementBuilder
{
	public static function build(ast:IParserNode):IStatement
	{
		switch (ast.kind)
		{
			case AS3NodeKind.BLOCK:
				return new StatementList(ast);
				
			case AS3NodeKind.BREAK:
				return new BreakStatementNode(ast);
			
			case AS3NodeKind.CONTINUE:
				return new ContinueStatementNode(ast);
			
			case AS3NodeKind.DEC_LIST:
				return new DeclarationStatementNode(ast);
			
			case AS3NodeKind.DF_XML_NS:
				return new DefaultXMLNamespaceStatementNode(ast);
				
			case AS3NodeKind.DO:
				return new DoWhileStatementNode(ast);
				
			case AS3NodeKind.EXPR_LIST:
			case AS3NodeKind.EXPR_STMNT:
				return new ExpressionStatementNode(ast);
			
			case AS3NodeKind.FOR:
				return new ForStatementNode(ast);
				
			case AS3NodeKind.FOREACH:
				return new ForEachInStatementNode(ast);
				
			case AS3NodeKind.FORIN:
				return new ForInStatementNode(ast);
				
			case AS3NodeKind.IF:
				return new IfStatementNode(ast);
			
			case AS3NodeKind.LABEL:
				return new LabelStatementNode(ast);
			
			case AS3NodeKind.RETURN:
				return new ReturnStatementNode(ast);
			
			case AS3NodeKind.SUPER:
				return new SuperStatementNode(ast);
				
			case AS3NodeKind.SWITCH:
				return new SwitchStatementNode(ast);
				
			case AS3NodeKind.THIS:
				return new ThisStatementNode(ast);
			
			case AS3NodeKind.THROW:
				return new ThrowStatementNode(ast);
			
			case AS3NodeKind.TRY_STMNT:
				return new TryStatementNode(ast);
				
			case AS3NodeKind.WHILE:
				return new WhileStatementNode(ast);
			
			case AS3NodeKind.WITH:
				return new WithStatementNode(ast);
				
			default:
				throw new Error("unhandled statement node type: '" + ast.kind + "'");
		}
	}
}
}