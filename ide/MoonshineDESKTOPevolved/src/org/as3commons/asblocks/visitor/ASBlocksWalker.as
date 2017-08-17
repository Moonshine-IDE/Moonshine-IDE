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

package org.as3commons.asblocks.visitor
{

import org.as3commons.asblocks.IASBlockVisitor;
import org.as3commons.asblocks.api.IArgument;
import org.as3commons.asblocks.api.IArrayAccessExpression;
import org.as3commons.asblocks.api.IArrayLiteral;
import org.as3commons.asblocks.api.IAssignmentExpression;
import org.as3commons.asblocks.api.IBinaryExpression;
import org.as3commons.asblocks.api.IBlock;
import org.as3commons.asblocks.api.IBooleanLiteral;
import org.as3commons.asblocks.api.IBreakStatement;
import org.as3commons.asblocks.api.ICatchClause;
import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IConditionalExpression;
import org.as3commons.asblocks.api.IContinueStatement;
import org.as3commons.asblocks.api.IDeclaration;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IDefaultXMLNamespaceStatement;
import org.as3commons.asblocks.api.IDoWhileStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IExpressionStatement;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IFieldAccessExpression;
import org.as3commons.asblocks.api.IFinallyClause;
import org.as3commons.asblocks.api.IForEachInStatement;
import org.as3commons.asblocks.api.IForInStatement;
import org.as3commons.asblocks.api.IForStatement;
import org.as3commons.asblocks.api.IFunctionLiteral;
import org.as3commons.asblocks.api.IINvocationExpression;
import org.as3commons.asblocks.api.IIfStatement;
import org.as3commons.asblocks.api.IInterfaceType;
import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.INewExpression;
import org.as3commons.asblocks.api.INullLiteral;
import org.as3commons.asblocks.api.INumberLiteral;
import org.as3commons.asblocks.api.IObjectLiteral;
import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IParameter;
import org.as3commons.asblocks.api.IPostfixExpression;
import org.as3commons.asblocks.api.IPrefixExpression;
import org.as3commons.asblocks.api.IPropertyField;
import org.as3commons.asblocks.api.IReturnStatement;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.api.ISimpleNameExpression;
import org.as3commons.asblocks.api.IStatementContainer;
import org.as3commons.asblocks.api.IStringLiteral;
import org.as3commons.asblocks.api.ISuperStatement;
import org.as3commons.asblocks.api.ISwitchCase;
import org.as3commons.asblocks.api.ISwitchDefault;
import org.as3commons.asblocks.api.ISwitchStatement;
import org.as3commons.asblocks.api.IThisStatement;
import org.as3commons.asblocks.api.IThrowStatement;
import org.as3commons.asblocks.api.ITryStatement;
import org.as3commons.asblocks.api.IUndefinedLiteral;
import org.as3commons.asblocks.api.IWhileStatement;
import org.as3commons.asblocks.api.IWithStatement;

/**
 * A default null visitor implementation that can be subclassed.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ASBlocksWalker implements IASBlockVisitor
{
	private var strategy:IScriptNodeStrategy;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ASBlocksWalker(strategy:FilterStrategy)
	{
		this.strategy = strategy;
		strategy.filtered = new ScriptNodeSwitch(this);
	}
	
	public function visitArgument(element:IArgument):void
	{
	}
	
	public function visitArrayAccessExpression(element:IArrayAccessExpression):void
	{
		walk(element.target);
		walk(element.subscript);
	}
	
	public function visitArrayLiteral(element:IArrayLiteral):void
	{
		walkElements(element.entries as Vector.<IScriptNode>);
	}
	
	protected function walk(object:*):void
	{
		if (object is Vector)
		{
			walkElements(object as Vector.<IScriptNode>);
		}
		else 
		{
			walkElement(object as IScriptNode);
		}
	}
	
	public function walkStatementContainer(element:IStatementContainer):void
	{
		walk(element.statements);
	}
	
	protected function walkElements(list:Vector.<IScriptNode>):void
	{
		var len:int = list.length;
		for (var i:int = 0; i < len; i++)
		{
			var element:IExpression = list[i] as IExpression;
			walk(element);
		}
	}
	
	public function walkElement(element:IScriptNode):void
	{
		strategy.handle(element);
	}
	
	public function visitAssignmentExpression(element:IAssignmentExpression):void
	{
		walk(element.leftExpression);
		walk(element.rightExpression);
	}
	
	public function visitBinaryExpression(element:IBinaryExpression):void
	{
		walk(element.leftExpression);
		walk(element.rightExpression);
	}
	
	public function visitBlockStatement(element:IBlock):void
	{
		walkStatementContainer(element);
	}
	
	public function visitBooleanLiteral(element:IBooleanLiteral):void
	{
	}
	
	public function visitBreakStatement(element:IBreakStatement):void
	{
	}
	
	public function visitCatchClause(element:ICatchClause):void
	{
		walkStatementContainer(element);
	}
	
	public function visitClassType(element:IClassType):void
	{
		walk(element.metaDatas);
		walk(element.fields);
		walk(element.methods);
	}
	
	public function visitCompilationUnit(element:ICompilationUnit):void
	{
		walk(element.packageNode);
	}
	
	public function visitConditionalExpression(element:IConditionalExpression):void
	{
		walk(element.condition);
		walk(element.thenExpression);
		walk(element.elseExpression);
	}
	
	public function visitContinueStatement(element:IContinueStatement):void
	{
	}
	
	public function visitDeclarationStatement(element:IDeclarationStatement):void
	{
		walk(element.declarations);
	}
	
	public function visitDefaultXMLNamespaceStatement(element:IDefaultXMLNamespaceStatement):void
	{
	}
	
	public function visitDoWhileStatement(element:IDoWhileStatement):void
	{
		walk(element.condition);
		walkStatementContainer(element);
	}
	
	public function visitExpressionStatement(element:IExpressionStatement):void
	{
		walk(element.expression);
	}
	
	public function visitField(element:IField):void
	{
		walk(element.metaDatas);
	}
	
	public function visitFieldAccessExpression(element:IFieldAccessExpression):void
	{
		walk(element.target);
	}
	
	public function visitFinallyClause(element:IFinallyClause):void
	{
		walkStatementContainer(element);
	}
	
	public function visitForEachInStatement(element:IForEachInStatement):void
	{
		walk(element.initializer);
		walk(element.iterated);
		walkStatementContainer(element);
	}
	
	public function visitForInStatement(element:IForInStatement):void
	{
		walk(element.initializer);
		walk(element.iterated);
		walkStatementContainer(element);
	}
	
	public function visitForStatement(element:IForStatement):void
	{
		var init:IScriptNode = element.initializer;
		if (init)
		{
			walk(element.initializer);
		}
		var cond:IScriptNode = element.condition;
		if (cond)
		{
			walk(element.condition);
		}
		var iter:IScriptNode = element.iterator;
		if (iter)
		{
			walk(element.iterator);
		}
		walkStatementContainer(element);
	}
	
	public function visitFunctionLiteral(element:IFunctionLiteral):void
	{
		walk(element.parameters);
		walkStatementContainer(element);
	}
	
	public function visitIfStatement(element:IIfStatement):void
	{
		walk(element.condition);
		walk(element.thenBlock);
		var block:IScriptNode = element.elseBlock;
		if (block)
		{
			walk(element.elseBlock);
		}
	}
	
	public function visitNumberLiteral(element:INumberLiteral):void
	{
	}
	
	public function visitInterfaceType(element:IInterfaceType):void
	{
		walk(element.metaDatas);
		walk(element.methods);
	}
	
	public function visitInvocationExpression(element:IINvocationExpression):void
	{
		walk(element.target);
		walk(element.arguments);
	}
	
	public function visitMetaData(element:IMetaData):void
	{
	}
	
	public function visitMethod(element:IMethod):void
	{
		walk(element.metaDatas);
		walk(element.parameters);
		walkStatementContainer(element);
	}
	
	public function visitNewExpression(element:INewExpression):void
	{
		walk(element.target);
		walk(element.arguments);
	}
	
	public function visitNullLiteral(element:INullLiteral):void
	{
	}
	
	public function visitObjectField(element:IPropertyField):void
	{
		walk(element.value);
	}
	
	public function visitObjectLiteral(element:IObjectLiteral):void
	{
		walk(element.fields);
	}
	
	public function visitPackage(element:IPackage):void
	{
		walk(element.typeNode);
	}
	
	public function visitParameter(element:IParameter):void
	{
	}
	
	public function visitPostfixExpression(element:IPostfixExpression):void
	{
		walk(element.expression);
	}
	
	public function visitPrefixExpression(element:IPrefixExpression):void
	{
		walk(element.expression);
	}
	
	public function visitReturnStatement(element:IReturnStatement):void
	{
		var expression:IExpression = element.expression;
		if (expression)
		{
			walk(expression);
		}
	}
	
	public function visitSimpleNameExpression(element:ISimpleNameExpression):void
	{
	}
	
	public function visitStringLiteral(element:IStringLiteral):void
	{
	}
	
	public function visitSuperStatement(element:ISuperStatement):void
	{
		walk(element.arguments);
	}
	
	public function visitSwitchCase(element:ISwitchCase):void
	{
		walk(element.label);
		walkStatementContainer(element);
	}
	
	public function visitSwitchDefault(element:ISwitchDefault):void
	{
		walkStatementContainer(element);
	}
	
	public function visitSwitchStatement(element:ISwitchStatement):void
	{
		walk(element.condition);
		walk(element.labels);
	}
	
	public function visitThisStatement(element:IThisStatement):void
	{
	}
	
	public function visitThrowStatement(element:IThrowStatement):void
	{
		walk(element.expression);
	}
	
	public function visitTryStatement(element:ITryStatement):void
	{
		walkStatementContainer(element);
		var catches:Vector.<ICatchClause> = element.catchClauses;
		if (catches.length > 0)
		{
			walk(catches);
		}
		var fclause:IFinallyClause = element.finallyClause;
		if (fclause)
		{
			walk(fclause);
		}
	}
	
	public function visitUndefinedLiteral(element:IUndefinedLiteral):void
	{
	}
	
	public function visitVarDeclarationFragment(element:IDeclaration):void
	{
		walk(element.initializer);
	}
	
	public function visitWhileStatement(element:IWhileStatement):void
	{
		walk(element.condition);
		walk(element.body);
	}
	
	public function visitWithStatement(element:IWithStatement):void
	{
		walk(element.scope);
		walk(element.body);
	}
}
}