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

/**
 * The <code>IStatementContainer</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ContainerDelegate extends ScriptNode 
	implements IStatementContainer
{
	protected function get statementContainer():IStatementContainer
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
	public function get hasCode():Boolean
	{
		return statementContainer.hasCode;
	}
	
	//----------------------------------
	//  statements
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#statements
	 */
	public function get statements():Vector.<IStatement>
	{
		return statementContainer.statements;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ContainerDelegate(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IStatementContainer API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#addComment()
	 */
	public function addComment(text:String):IToken
	{
		return statementContainer.addComment(text);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeComment()
	 */
	public function removeComment(statement:IStatement):IToken
	{
		return statementContainer.removeComment(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#addStatement()
	 */
	public function addStatement(statement:String):IStatement
	{
		return statementContainer.addStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatement()
	 */
	public function removeStatement(statement:IStatement):IStatement
	{
		return statementContainer.removeStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatementAt()
	 */
	public function removeStatementAt(index:int):IStatement
	{
		return statementContainer.removeStatementAt(index);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newExpressionStatement()
	 */
	public function newExpressionStatement(statement:String):IExpressionStatement
	{
		return statementContainer.newExpressionStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newBreak()
	 */
	public function newBreak(label:String = null):IBreakStatement
	{
		return statementContainer.newBreak(label);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newContinue()
	 */
	public function newContinue(label:String = null):IContinueStatement
	{
		return statementContainer.newContinue(label);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDeclaration()
	 */
	public function newDeclaration(declaration:String):IDeclarationStatement
	{
		return statementContainer.newDeclaration(declaration);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDefaultXMLNamespace()
	 */
	public function newDefaultXMLNamespace(namespace:String):IDefaultXMLNamespaceStatement
	{
		return statementContainer.newDefaultXMLNamespace(namespace);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDoWhile()
	 */
	public function newDoWhile(condition:IExpression):IDoWhileStatement
	{
		return statementContainer.newDoWhile(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newFor()
	 */
	public function newFor(initializer:IExpression, 
						   condition:IExpression, 
						   iterater:IExpression):IForStatement
	{
		return statementContainer.newFor(initializer, condition, iterater);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#parseNewFor()
	 */
	public function parseNewFor(initializer:String, 
								condition:String, 
								iterater:String):IForStatement
	{
		return statementContainer.parseNewFor(initializer, condition, iterater);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForEachIn()
	 */
	public function newForEachIn(declaration:IScriptNode, 
								 expression:IExpression):IForEachInStatement
	{
		return statementContainer.newForEachIn(declaration, expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForIn()
	 */
	public function newForIn(declaration:IScriptNode, 
							 expression:IExpression):IForInStatement
	{
		return statementContainer.newForIn(declaration, expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newIf()
	 */
	public function newIf(condition:IExpression):IIfStatement
	{
		return statementContainer.newIf(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newLabel()
	 */
	public function newLabel(name:String):ILabelStatement
	{
		return statementContainer.newLabel(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForLabel()
	 */
	public function newForLabel(name:String, kind:String):ILabelStatement
	{
		return statementContainer.newForLabel(name, kind);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newReturn()
	 */
	public function newReturn(expression:IExpression = null):IReturnStatement
	{
		return statementContainer.newReturn(expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newSuper()
	 */
	public function newSuper(arguments:Vector.<IExpression> = null):ISuperStatement
	{
		return statementContainer.newSuper(arguments);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newSwitch()
	 */
	public function newSwitch(condition:IExpression):ISwitchStatement
	{
		return statementContainer.newSwitch(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newThis()
	 */
	public function newThis(expression:IExpression):IThisStatement
	{
		return statementContainer.newThis(expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newThrow()
	 */
	public function newThrow(expression:IExpression):IThrowStatement
	{
		return statementContainer.newThrow(expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newTryCatch()
	 */
	public function newTryCatch(name:String, type:String):ITryStatement
	{
		return statementContainer.newTryCatch(name, type);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newTryFinally()
	 */
	public function newTryFinally():ITryStatement
	{
		return statementContainer.newTryFinally();
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newWhile()
	 */
	public function newWhile(condition:IExpression):IWhileStatement
	{
		return statementContainer.newWhile(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newWith()
	 */
	public function newWith(condition:IExpression):IWithStatement
	{
		return statementContainer.newWith(condition);
	}
}
}