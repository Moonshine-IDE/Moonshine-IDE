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

import org.as3commons.asblocks.api.AccessorRole;
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
import org.as3commons.asblocks.api.IFunction;
import org.as3commons.asblocks.api.IIfStatement;
import org.as3commons.asblocks.api.ILabelStatement;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.IParameter;
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
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IMember</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MethodNode extends MemberNode 
	implements IMethod
{
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var functionMixin:IFunction;
	
	/**
	 * @private
	 */
	private var containerMixin:IStatementContainer;
	
	private function findAccessorRoleNode():IParserNode
	{
		return node.getKind(AS3NodeKind.ACCESSOR_ROLE);
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
		return containerMixin.hasCode;
	}
	
	//----------------------------------
	//  statements
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#statements
	 */
	public function get statements():Vector.<IStatement>
	{
		return containerMixin.statements;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IMethodNode API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  accessorRole
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IMethodNode#accessorRole
	 */
	public function get accessorRole():AccessorRole
	{
		var role:IParserNode = findAccessorRoleNode();
		if (role.numChildren > 0)
		{
			if (role.getFirstChild().isKind(AS3NodeKind.SET))
			{
				return AccessorRole.SETTER;
			}
			else if (role.getFirstChild().isKind(AS3NodeKind.GET))
			{
				return AccessorRole.GETTER;
			}
		}
		return AccessorRole.NORMAL;
	}
	
	/**
	 * @private
	 */	
	public function set accessorRole(value:AccessorRole):void
	{
		if (value.equals(accessorRole))
		{
			return;
		}
		var role:IParserNode = findAccessorRoleNode();
		var ast:IParserNode = (value == AccessorRole.GETTER) 
			? ASTBuilder.newAST(AS3NodeKind.GET, "get")
			: ASTBuilder.newAST(AS3NodeKind.SET, "set");
		if (role.numChildren == 0)
		{
			role.addChild(ast);
		}
		else
		{
			role.setChildAt(ast, 0);
		}
		role.appendToken(TokenBuilder.newSpace());
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFunction API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  arguments
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#arguments
	 */
	public function get parameters():Vector.<IParameter>
	{
		return functionMixin.parameters;
	}
	
	//----------------------------------
	//  hasParameters
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasParameters
	 */
	public function get hasParameters():Boolean
	{
		return functionMixin.hasParameters;
	}
	
	//----------------------------------
	//  returnType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#returnType
	 */
	public function get returnType():String
	{
		return functionMixin.returnType;
	}
	
	/**
	 * @private
	 */	
	public function set returnType(value:String):void
	{
		functionMixin.returnType = value;
	}
	
	//----------------------------------
	//  qualifiedReturnType
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#qualifiedReturnType
	 */
	public function get qualifiedReturnType():String
	{
		return functionMixin.qualifiedReturnType;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function MethodNode(node:IParserNode)
	{
		super(node);
		
		var block:IParserNode = node.getKind(AS3NodeKind.BLOCK);
		if (block)
		{
			containerMixin = new StatementList(block);
		}
		
		functionMixin = new FunctionCommon(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IFunction API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#addParameter()
	 */
	public function addParameter(name:String, 
								 type:String, 
								 defaultValue:String = null):IParameter
	{
		return functionMixin.addParameter(name, type, defaultValue);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#removeParameter()
	 */
	public function removeParameter(name:String):IParameter
	{
		return functionMixin.removeParameter(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#addRestParameter()
	 */
	public function addRestParameter(name:String):IParameter
	{
		return functionMixin.addRestParameter(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#removeRestParameter()
	 */
	public function removeRestParameter():IParameter
	{
		return functionMixin.removeRestParameter();
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#getParameter()
	 */
	public function getParameter(name:String):IParameter
	{
		return functionMixin.getParameter(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasParameter()
	 */
	public function hasParameter(name:String):Boolean
	{
		return functionMixin.hasParameter(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IFunction#hasRestParameter()
	 */
	public function hasRestParameter():Boolean
	{
		return functionMixin.hasRestParameter();
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
		return containerMixin.addComment(text);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeComment()
	 */
	public function removeComment(statement:IStatement):IToken
	{
		return containerMixin.removeComment(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#addStatement()
	 */
	public function addStatement(statement:String):IStatement
	{
		return containerMixin.addStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatement()
	 */
	public function removeStatement(statement:IStatement):IStatement
	{
		return containerMixin.removeStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#removeStatementAt()
	 */
	public function removeStatementAt(index:int):IStatement
	{
		return containerMixin.removeStatementAt(index);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newExpressionStatement()
	 */
	public function newExpressionStatement(statement:String):IExpressionStatement
	{
		return containerMixin.newExpressionStatement(statement);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newBreak()
	 */
	public function newBreak(label:String = null):IBreakStatement
	{
		return containerMixin.newBreak(label);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newContinue()
	 */
	public function newContinue(label:String = null):IContinueStatement
	{
		return containerMixin.newContinue(label);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDeclaration()
	 */
	public function newDeclaration(declaration:String):IDeclarationStatement
	{
		return containerMixin.newDeclaration(declaration);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDefaultXMLNamespace()
	 */
	public function newDefaultXMLNamespace(namespace:String):IDefaultXMLNamespaceStatement
	{
		return containerMixin.newDefaultXMLNamespace(namespace);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newDoWhile()
	 */
	public function newDoWhile(condition:IExpression):IDoWhileStatement
	{
		return containerMixin.newDoWhile(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newFor()
	 */
	public function newFor(initializer:IExpression, 
						   condition:IExpression, 
						   iterater:IExpression):IForStatement
	{
		return containerMixin.newFor(initializer, condition, iterater);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#parseNewFor()
	 */
	public function parseNewFor(initializer:String, 
								condition:String, 
								iterater:String):IForStatement
	{
		return containerMixin.parseNewFor(initializer, condition, iterater);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForEacIn()
	 */
	public function newForEachIn(declaration:IScriptNode, 
								 expression:IExpression):IForEachInStatement
	{
		return containerMixin.newForEachIn(declaration, expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForIn()
	 */
	public function newForIn(declaration:IScriptNode, 
							 expression:IExpression):IForInStatement
	{
		return containerMixin.newForIn(declaration, expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newIf()
	 */
	public function newIf(condition:IExpression):IIfStatement
	{
		return containerMixin.newIf(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newLabel()
	 */
	public function newLabel(name:String):ILabelStatement
	{
		return containerMixin.newLabel(name);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newForLabel()
	 */
	public function newForLabel(name:String, kind:String):ILabelStatement
	{
		return containerMixin.newForLabel(name, kind);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newReturn()
	 */
	public function newReturn(expression:IExpression = null):IReturnStatement
	{
		return containerMixin.newReturn(expression);
	}
	
	/**
	 * @private
	 */
	public function newSuper(arguments:Vector.<IExpression> = null):ISuperStatement
	{
		return containerMixin.newSuper(arguments);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newSwitch()
	 */
	public function newSwitch(condition:IExpression):ISwitchStatement
	{
		return containerMixin.newSwitch(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newThrow()
	 */
	public function newThis(expression:IExpression):IThisStatement
	{
		return containerMixin.newThis(expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newThrow()
	 */
	public function newThrow(expression:IExpression):IThrowStatement
	{
		return containerMixin.newThrow(expression);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newTryFinally()
	 */
	public function newTryCatch(name:String, type:String):ITryStatement
	{
		return containerMixin.newTryCatch(name, type);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newTryFinally()
	 */
	public function newTryFinally():ITryStatement
	{
		return containerMixin.newTryFinally();
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newWhile()
	 */
	public function newWhile(condition:IExpression):IWhileStatement
	{
		return containerMixin.newWhile(condition);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IStatementContainer#newWith()
	 */
	public function newWith(condition:IExpression):IWithStatement
	{
		return containerMixin.newWith(condition);
	}
}
}