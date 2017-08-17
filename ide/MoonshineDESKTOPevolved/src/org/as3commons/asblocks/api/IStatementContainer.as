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

import org.as3commons.asblocks.parser.api.IToken;

/**
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IStatementContainer
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  hasCode
	//----------------------------------
	
	/**
	 * Whether the statement container contains child statement.
	 * 
	 * @see #statements
	 */
	function get hasCode():Boolean;
	
	//----------------------------------
	//  statements
	//----------------------------------
	
	/**
	 * A <code>Vector</code> of <code>IStatement</code>s contained in this
	 * statement container.
	 */
	function get statements():Vector.<IStatement>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds a line of comment text to the statement container.
	 * 
	 * @param comment A <code>String</code> comment.
	 */
	function addComment(text:String):IToken;
	
	/**
	 * @private
	 */
	function removeComment(statement:IStatement):IToken;
	
	/**
	 * @private
	 */
	function addStatement(statement:String):IStatement;
	
	/**
	 * @private
	 */
	function removeStatement(statement:IStatement):IStatement;
	
	/**
	 * @private
	 */
	function removeStatementAt(index:int):IStatement;
	
	//--------------------------------------------------------------------------
	//
	//  Factory Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>break label;</code> statement.
	 * 
	 * @param label The simple label name.
	 * @return A new <code>IBreakStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IBreakStatement
	 */
	function newBreak(label:String = null):IBreakStatement;
	
	/**
	 * Creates a new <code>continue label;</code> statement.
	 * 
	 * @param label The simple label name.
	 * @return A new <code>IContinueStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IContinueStatement
	 */
	function newContinue(label:String = null):IContinueStatement;
	
	/**
	 * Creates a new <code>var foo:int = 0</code> or 
	 * <code>var foo:int = 0, bar:int = 42</code> statement.
	 * 
	 * @param declaration The String variable declaration.
	 * @return A new <code>IContinueStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IDeclarationStatement
	 */
	function newDeclaration(declaration:String):IDeclarationStatement;
	
	/**
	 * Creates a new <code>default xml namespace = ns1</code> statement.
	 * 
	 * @param namespace The String namespace.
	 * @return A new <code>IDefaultXMLNamespaceStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IDefaultXMLNamespaceStatement
	 */
	function newDefaultXMLNamespace(namespace:String):IDefaultXMLNamespaceStatement;
	
	/**
	 * Creates a new <code>do {...} while (condition)</code> statement.
	 * 
	 * @param condition The <code>IExpression</code> while condition.
	 * @return A new <code>IDoWhileStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IDoWhileStatement
	 */
	function newDoWhile(condition:IExpression):IDoWhileStatement;
	
	/**
	 * Creates a new <code>expression;</code> statement.
	 * 
	 * @param statement The <code>String</code> expression statement.
	 * @return A new <code>IExpressionStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IExpressionStatement
	 */
	function newExpressionStatement(statement:String):IExpressionStatement;
	
	/**
	 * Creates a new <code>for(initializer; condition; iterator){...}</code> statement.
	 * 
	 * @param initializer The <code>IExpression</code> initializer.
	 * @param initializer The <code>IExpression</code> condition.
	 * @param initializer The <code>IExpression</code> iterater.
	 * @return A new <code>IForStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IForStatement
	 */
	function newFor(initializer:IExpression, 
					condition:IExpression, 
					iterater:IExpression):IForStatement;
	
	/**
	 * @private
	 */
	function parseNewFor(initializer:String, 
						 condition:String, 
						 iterater:String):IForStatement;
	
	/**
	 * Creates a new <code>for each(declaration in target){...}</code> statement.
	 * 
	 * @param declaration The <code>IScriptNode</code> declaration.
	 * @param target The <code>IExpression</code> iteration target.
	 * @return A new <code>IForStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IForStatement
	 */
	function newForEachIn(declaration:IScriptNode, 
						  target:IExpression):IForEachInStatement;
	
	/**
	 * @private
	 */
	//function parseNewForEachIn(declaration:String, 
	//						   target:String):IForEachInStatement;
	
	/**
	 * Creates a new <code>for(declaration in target){...}</code> statement.
	 * 
	 * @param declaration The <code>IScriptNode</code> declaration.
	 * @param target The <code>IExpression</code> iteration target.
	 * @return A new <code>IForInStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IForInStatement
	 */
	function newForIn(declaration:IScriptNode, 
					  target:IExpression):IForInStatement;
	
	/**
	 * @private
	 */
	//function parseNewForIn(declaration:String, 
	//					   target:String):IForInStatement;
	
	/**
	 * Creates a new <code>if(condition){...} else {...}</code> statement.
	 * 
	 * @param condition The <code>IExpression</code> condition.
	 * @return A new <code>IIfStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IIfStatement
	 */
	function newIf(condition:IExpression):IIfStatement;
	
	/**
	 * @private
	 */
	function newLabel(name:String):ILabelStatement;
	
	/**
	 * @private
	 */
	function newForLabel(name:String, kind:String):ILabelStatement;
	
	/**
	 * @private
	 */
	//function newWhileLabel(name:String):ILabelStatement;
	
	/**
	 * Creates a new <code>return expression</code> statement.
	 * 
	 * @param expression The <code>IExpression</code> to return.
	 * @return A new <code>IReturnStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IReturnStatement
	 */
	function newReturn(expression:IExpression = null):IReturnStatement
	
	/**
	 * Creates a new <code>super(args...)</code>, <code>super.foo(args...)</code>
	 * op <code>super.bar = expression</code> statement.
	 * 
	 * @param arguments A <code>Vector</code> of <code>IExpression</code>s.
	 * @return A new <code>ISuperStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.ISuperStatement
	 */
	function newSuper(arguments:Vector.<IExpression> = null):ISuperStatement;
	
	/**
	 * Creates a new <code>switch(condition){ case label: default: }</code> statement.
	 * 
	 * @param arguments A <code>Vector</code> of <code>IExpression</code>s.
	 * @return A new <code>ISwitchStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.ISwitchStatement
	 * @see org.as3commons.asblocks.api.ISwitchCase
	 * @see org.as3commons.asblocks.api.ISwitchDefault
	 */
	function newSwitch(condition:IExpression):ISwitchStatement;
	
	/**
	 * Creates a new <code>this.expression</code> statement.
	 * 
	 * @param expression The <code>IExpression</code> access.
	 * @return A new <code>IThisStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IThisStatement
	 */
	function newThis(expression:IExpression):IThisStatement;
	
	/**
	 * Creates a new <code>throw new Error(args...)</code> or 
	 * <code>throw e1</code> statement.
	 * 
	 * @param expression The <code>IExpression</code> access.
	 * @return A new <code>IThrowStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IThrowStatement
	 */
	function newThrow(expression:IExpression):IThrowStatement;
	
	/**
	 * Creates a new <code>try {...} catch(name:type) {...}</code> statement.
	 * 
	 * @param name The <code>String</code> error instance name.
	 * @param type The <code>String</code> error instance type.
	 * @return A new <code>ITryStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.ITryStatement
	 */
	function newTryCatch(name:String, type:String):ITryStatement;
	
	/**
	 * Creates a new <code>try {...} finally {...}</code> statement.
	 * 
	 * @return A new <code>ITryStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.ITryStatement
	 */
	function newTryFinally():ITryStatement;
	
	/**
	 * Creates a new <code>while(condition) {...}</code> statement.
	 * 
	 * @param condition The <code>IExpression</code> condition.
	 * @return A new <code>IWhileStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IWhileStatement
	 */
	function newWhile(condition:IExpression):IWhileStatement;
	
	/**
	 * Creates a new <code>with(scope) {...}</code> statement.
	 * 
	 * @param scope The <code>IExpression</code> scope.
	 * @return A new <code>IWithStatement</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IWithStatement
	 */
	function newWith(scope:IExpression):IWithStatement;
}
}