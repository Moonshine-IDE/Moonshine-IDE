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

import org.as3commons.asblocks.api.IArgument;
import org.as3commons.asblocks.api.IBlock;
import org.as3commons.asblocks.api.IBreakStatement;
import org.as3commons.asblocks.api.IContinueStatement;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IDefaultXMLNamespaceStatement;
import org.as3commons.asblocks.api.IDoWhileStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IExpressionStatement;
import org.as3commons.asblocks.api.IForEachInStatement;
import org.as3commons.asblocks.api.IForInStatement;
import org.as3commons.asblocks.api.IForStatement;
import org.as3commons.asblocks.api.IIfStatement;
import org.as3commons.asblocks.api.ILabelStatement;
import org.as3commons.asblocks.api.IReturnStatement;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.api.IStatement;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.api.ISuperStatement;
import org.as3commons.asblocks.api.ISwitchStatement;
import org.as3commons.asblocks.api.IThisStatement;
import org.as3commons.asblocks.api.IThrowStatement;
import org.as3commons.asblocks.api.ITryStatement;
import org.as3commons.asblocks.api.IWhileStatement;
import org.as3commons.asblocks.api.IWithStatement;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IStatementContainer</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class StatementList extends ContainerDelegate implements IBlock
{
	override protected function get statementContainer():IStatementContainer
	{
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IStatementContainer API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  hasCode
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#hasCode
	 */
	override public function get hasCode():Boolean
	{
		return node.getFirstChild() != null;
	}
	
	//----------------------------------
	//  statements
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#statements
	 */
	override public function get statements():Vector.<IStatement>
	{
		var result:Vector.<IStatement> = new Vector.<IStatement>();
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext())
		{
			result.push(StatementBuilder.build(i.next()));
		}
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function StatementList(node:IParserNode)
	{
		super(node);
	}
	
	/**
	 * @private
	 */
	override public function addComment(text:String):IToken
	{
		return ASTBuilder.newComment(node, text);
	}
	
	/**
	 * @private
	 */
	override public function removeComment(statement:IStatement):IToken
	{
		return ASTUtil.removeComment(statement.node);
	}
	
	/**
	 * @private
	 */
	override public function addStatement(statement:String):IStatement
	{
		var ast:IParserNode = AS3FragmentParser.parseStatement(statement);
		ast.parent = null;
		_addStatement(ast);
		return StatementBuilder.build(ast);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatement()
	 */
	override public function removeStatement(statement:IStatement):IStatement
	{
		var i:ASTIterator = new ASTIterator(node);
		while (i.hasNext())
		{
			var ast:IParserNode = i.next();
			if (statement.node === ast)
			{
				i.remove();
				return StatementBuilder.build(ast);
			}
		}
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatementAt()
	 */
	override public function removeStatementAt(index:int):IStatement
	{
		var i:ASTIterator = new ASTIterator(node);
		var ast:IParserNode = i.moveTo(index);
		if (ast)
		{
			i.remove();
			return StatementBuilder.build(ast);
		}
		return null;
	}
	
	/**
	 * @private
	 */
	override public function newBreak(label:String = null):IBreakStatement
	{
		var ast:IParserNode = ASTStatementBuilder.newBreak(label);
		_addStatement(ast);
		return new BreakStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newContinue(label:String = null):IContinueStatement
	{
		var ast:IParserNode = ASTStatementBuilder.newContinue(label);
		_addStatement(ast);
		return new ContinueStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newDeclaration(declaration:String):IDeclarationStatement
	{
		var ast:IParserNode = AS3FragmentParser.parseDecList(declaration);
		_addStatement(ast);
		return new DeclarationStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newDefaultXMLNamespace(namespace:String):IDefaultXMLNamespaceStatement
	{
		var ast:IParserNode = ASTStatementBuilder.newDefaultXMLNamespace(
			AS3FragmentParser.parsePrimaryExpression(namespace));
		_addStatement(ast);
		return new DefaultXMLNamespaceStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newDoWhile(condition:IExpression):IDoWhileStatement
	{
		var ast:IParserNode = ASTStatementBuilder.newDoWhile(condition.node);
		_addStatement(ast);
		return new DoWhileStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newExpressionStatement(statement:String):IExpressionStatement
	{
		var ast:IParserNode = AS3FragmentParser.parseExpressionStatement(statement);
		_addStatement(ast);
		return new ExpressionStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newFor(initializer:IExpression,
									condition:IExpression, 
									iterator:IExpression):IForStatement
	{
		var init:IParserNode = initializer ? initializer.node : null;
		var cond:IParserNode = condition ? condition.node : null;
		var iter:IParserNode = iterator ? iterator.node : null;
		
		var ast:IParserNode = ASTStatementBuilder.newFor(init, cond, iter);
		appendBlock(ast);
		_addStatement(ast);
		return new ForStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function parseNewFor(initializer:String,
										 condition:String, 
										 iterator:String):IForStatement
	{
		var init:IParserNode;
		var cond:IParserNode;
		var iter:IParserNode;
		
		if (initializer)
		{
			init = AS3FragmentParser.parseForInit(initializer);
		}
		
		if (condition)
		{
			cond = AS3FragmentParser.parseForCond(condition);
		}
		
		if (iterator)
		{
			iter = AS3FragmentParser.parseForIter(iterator);
		}
		
		var ast:IParserNode = ASTStatementBuilder.newFor(init, cond, iter);
		appendBlock(ast);
		_addStatement(ast);
		return new ForStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newForEachIn(declaration:IScriptNode,
										  expression:IExpression):IForEachInStatement
	{
		if (!declaration)
			throw new Error("");
		if (!expression)
			throw new Error("");
		
		var ast:IParserNode = ASTStatementBuilder.newForEachIn(declaration.node, expression.node);
		appendBlock(ast);
		_addStatement(ast);
		return new ForEachInStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newForIn(declaration:IScriptNode,
									  expression:IExpression):IForInStatement
	{
		if (!declaration)
			throw new Error("");
		if (!expression)
			throw new Error("");
		
		var ast:IParserNode = ASTStatementBuilder.newForIn(declaration.node, expression.node);
		appendBlock(ast);
		_addStatement(ast);
		return new ForInStatementNode(ast);
	}
	
	public function appendBlock(ast:IParserNode):IParserNode
	{
		ast.appendToken(TokenBuilder.newSpace());
		var block:IParserNode = ASTStatementBuilder.newBlock();
		ast.addChild(block);
		return block;
	}
	
	/**
	 * @private
	 */
	override public function newIf(condition:IExpression):IIfStatement
	{
		var ifStmt:IParserNode = ASTStatementBuilder.newIf(condition.node);
		_addStatement(ifStmt);
		return new IfStatementNode(ifStmt);
	}
	
	/**
	 * @private
	 */
	override public function newLabel(name:String):ILabelStatement
	{
		var expr:IParserNode = ASTBuilder.newAST(AS3NodeKind.EXPR_STMNT);
		expr.addChild(AS3FragmentParser.parseExpression(name));
		var ast:IParserNode = ASTStatementBuilder.newLabel(expr);
		_addStatement(ast);
		return new LabelStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newForLabel(name:String, kind:String):ILabelStatement
	{
		var expr:IParserNode = ASTBuilder.newAST(AS3NodeKind.EXPR_STMNT);
		expr.addChild(AS3FragmentParser.parseExpression(name));
		var ast:IParserNode = ASTStatementBuilder.newForLabel(expr, kind);
		_addStatement(ast);
		return new ForLabelStatementNode(ast);
	}
	
	/**
	 * @private
	 */
	override public function newReturn(expression:IExpression = null):IReturnStatement
	{
		var result:IParserNode = ASTStatementBuilder.newReturn((expression) ? expression.node : null);
		_addStatement(result);
		return new ReturnStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newSuper(arguments:Vector.<IExpression> = null):ISuperStatement
	{
		var result:IParserNode = ASTStatementBuilder.newSuper(arguments);
		_addStatement(result);
		return new SuperStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newSwitch(condition:IExpression):ISwitchStatement
	{
		var result:IParserNode = ASTStatementBuilder.newSwitch(condition.node);
		_addStatement(result);
		return new SwitchStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newThis(expression:IExpression):IThisStatement
	{
		var result:IParserNode = ASTStatementBuilder.newThis(expression.node);
		_addStatement(result);
		return new ThisStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newThrow(expression:IExpression):IThrowStatement
	{
		var result:IParserNode = ASTStatementBuilder.newThrow(expression.node);
		_addStatement(result);
		return new ThrowStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newTryCatch(name:String, type:String):ITryStatement
	{
		var result:IParserNode = ASTStatementBuilder.newTryStatement();
		result.appendToken(TokenBuilder.newSpace());
		result.addChild(ASTStatementBuilder.newCatchClause(name, type));
		_addStatement(result);
		return new TryStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newTryFinally():ITryStatement
	{
		var result:IParserNode = ASTStatementBuilder.newTryStatement();
		result.appendToken(TokenBuilder.newSpace());
		result.addChild(ASTStatementBuilder.newFinallyClause());
		_addStatement(result);
		return new TryStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newWhile(condition:IExpression):IWhileStatement
	{
		var result:IParserNode = ASTStatementBuilder.newWhile(condition.node);
		_addStatement(result);
		return new WhileStatementNode(result);
	}
	
	/**
	 * @private
	 */
	override public function newWith(condition:IExpression):IWithStatement
	{
		var result:IParserNode = ASTStatementBuilder.newWith(condition.node);
		_addStatement(result);
		return new WithStatementNode(result);
	}
	
	
	
	
	private function _addStatement(statement:IParserNode):void
	{
		ASTUtil.addChildWithIndentation(node, statement);
	}
}
}