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

package org.as3commons.asblocks
{

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
import org.as3commons.asblocks.api.ISimpleNameExpression;
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
 * Visits elements within an <code>IPackage</code>, <code>IClassType</code>, 
 * <code>IInterfaceType</code> and <code>IStatementContainer</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IPackage
 * @see org.as3commons.asblocks.api.IClassType
 * @see org.as3commons.asblocks.api.IInterfaceType
 * @see org.as3commons.asblocks.api.IStatementContainer
 */
public interface IASBlockVisitor
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Visits an <code>IArgument</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IArgument</code>.
	 */
	function visitArgument(element:IArgument):void;
	
	/**
	 * Visits an <code>IArrayAccessExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IArrayAccessExpression</code>.
	 */
	function visitArrayAccessExpression(element:IArrayAccessExpression):void;
	
	/**
	 * Visits an <code>IArrayLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IArrayLiteral</code>.
	 */
	function visitArrayLiteral(element:IArrayLiteral):void;
	
	/**
	 * Visits an <code>IAssignmentExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IAssignmentExpression</code>.
	 */
	function visitAssignmentExpression(element:IAssignmentExpression):void;
	
	/**
	 * Visits an <code>IBinaryExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IBinaryExpression</code>.
	 */
	function visitBinaryExpression(element:IBinaryExpression):void;
	
	/**
	 * Visits an <code>IBlock</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IBlock</code>.
	 */
	function visitBlockStatement(element:IBlock):void;
	
	/**
	 * Visits an <code>IBooleanLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IBooleanLiteral</code>.
	 */
	function visitBooleanLiteral(element:IBooleanLiteral):void;
	
	/**
	 * Visits an <code>IBreakStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IBreakStatement</code>.
	 */
	function visitBreakStatement(element:IBreakStatement):void;
	
	/**
	 * Visits an <code>ICatchClause</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ICatchClause</code>.
	 */
	function visitCatchClause(element:ICatchClause):void;
	
	/**
	 * Visits an <code>IClassType</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IClassType</code>.
	 */
	function visitClassType(element:IClassType):void;
	
	/**
	 * Visits an <code>ICompilationUnit</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ICompilationUnit</code>.
	 */
	function visitCompilationUnit(element:ICompilationUnit):void;
	
	/**
	 * Visits an <code>IConditionalExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IConditionalExpression</code>.
	 */
	function visitConditionalExpression(element:IConditionalExpression):void;
	
	/**
	 * Visits an <code>IContinueStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IContinueStatement</code>.
	 */
	function visitContinueStatement(element:IContinueStatement):void;
	
	/**
	 * Visits an <code>IDeclarationStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IDeclarationStatement</code>.
	 */
	function visitDeclarationStatement(element:IDeclarationStatement):void;
	
	/**
	 * Visits an <code>IDefaultXMLNamespaceStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IDefaultXMLNamespaceStatement</code>.
	 */
	function visitDefaultXMLNamespaceStatement(element:IDefaultXMLNamespaceStatement):void;
	
	/**
	 * Visits an <code>IDoWhileStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IDoWhileStatement</code>.
	 */
	function visitDoWhileStatement(element:IDoWhileStatement):void;
	
	/**
	 * Visits an <code>IDescendantExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IDescendantExpression</code>.
	 */
	//	function visitDescendantExpression(element:IDescendantExpression):void;
	
	/**
	 * Visits an <code>IExpressionAttribute</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IExpressionAttribute</code>.
	 */
	//	function visitExpressionAttribute(element:IExpressionAttribute):void;
	
	/**
	 * Visits an <code>IExpressionStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IExpressionStatement</code>.
	 */
	function visitExpressionStatement(element:IExpressionStatement):void;
	
	/**
	 * Visits an <code>IField</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IField</code>.
	 */
	function visitField(element:IField):void;
	
	/**
	 * Visits an <code>IFieldAccessExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IFieldAccessExpression</code>.
	 */
	function visitFieldAccessExpression(element:IFieldAccessExpression):void;
	
	/**
	 * Visits an <code>IFilterExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IFilterExpression</code>.
	 */
	//	function visitFilterExpression(element:IFilterExpression):void;
	
	/**
	 * Visits an <code>IFinallyClause</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IFinallyClause</code>.
	 */
	function visitFinallyClause(element:IFinallyClause):void;
	
	/**
	 * Visits an <code>IForEachInStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IForEachInStatement</code>.
	 */
	function visitForEachInStatement(element:IForEachInStatement):void;
	
	/**
	 * Visits an <code>IForInStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IForInStatement</code>.
	 */
	function visitForInStatement(element:IForInStatement):void;
	
	/**
	 * Visits an <code>IForStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IForStatement</code>.
	 */
	function visitForStatement(element:IForStatement):void;
	
	/**
	 * Visits an <code>IFunctionLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IFunctionLiteral</code>.
	 */
	function visitFunctionLiteral(element:IFunctionLiteral):void;
	
	/**
	 * Visits an <code>IIfStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IIfStatement</code>.
	 */
	function visitIfStatement(element:IIfStatement):void;
	
	/**
	 * Visits an <code>INumberLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>INumberLiteral</code>.
	 */
	function visitNumberLiteral(element:INumberLiteral):void;
	
	/**
	 * Visits an <code>IInterfaceType</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IInterfaceType</code>.
	 */
	function visitInterfaceType(element:IInterfaceType):void;
	
	/**
	 * Visits an <code>IINvocationExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IINvocationExpression</code>.
	 */
	function visitInvocationExpression(element:IINvocationExpression):void;
	
	/**
	 * Visits an <code>IMetaData</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IMetaData</code>.
	 */
	function visitMetaData(element:IMetaData):void;
	
	/**
	 * Visits an <code>IMethod</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IMethod</code>.
	 */
	function visitMethod(element:IMethod):void;
	
	/**
	 * Visits an <code>INewExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>INewExpression</code>.
	 */
	function visitNewExpression(element:INewExpression):void;
	
	/**
	 * Visits an <code>INullLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>INullLiteral</code>.
	 */
	function visitNullLiteral(element:INullLiteral):void;
	
	/**
	 * Visits an <code>IPropertyField</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IPropertyField</code>.
	 */
	function visitObjectField(element:IPropertyField):void;
	
	/**
	 * Visits an <code>IObjectLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IObjectLiteral</code>.
	 */
	function visitObjectLiteral(element:IObjectLiteral):void;
	
	/**
	 * Visits an <code>IPackage</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IPackage</code>.
	 */
	function visitPackage(element:IPackage):void;
	
	/**
	 * Visits an <code>IParameter</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IParameter</code>.
	 */
	function visitParameter(element:IParameter):void;
	
	/**
	 * Visits an <code>IPostfixExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IPostfixExpression</code>.
	 */
	function visitPostfixExpression(element:IPostfixExpression):void;
	
	/**
	 * Visits an <code>IPrefixExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IPrefixExpression</code>.
	 */
	function visitPrefixExpression(element:IPrefixExpression):void;
	
	/**
	 * Visits an <code>IPropertyAttribute</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IPropertyAttribute</code>.
	 */
	//function visitPropertyAttribute(element:IPropertyAttribute):void;
	
	/**
	 * Visits an <code>IRegexpLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IRegexpLiteral</code>.
	 */
	//function visitRegexpLiteral(element:IRegexpLiteral):void;
	
	/**
	 * Visits an <code>IReturnStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IReturnStatement</code>.
	 */
	function visitReturnStatement(element:IReturnStatement):void;
	
	/**
	 * Visits an <code>ISimpleNameExpression</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ISimpleNameExpression</code>.
	 */
	function visitSimpleNameExpression(element:ISimpleNameExpression):void;
	
	/**
	 * Visits an <code>IStringLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IStringLiteral</code>.
	 */
	function visitStringLiteral(element:IStringLiteral):void;
	
	/**
	 * Visits an <code>IStarAttribute</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IStarAttribute</code>.
	 */
	//function visitStarAttribute(element:IStarAttribute):void;
	
	/**
	 * Visits an <code>ISuperStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ISuperStatement</code>.
	 */
	function visitSuperStatement(element:ISuperStatement):void;
	
	/**
	 * Visits an <code>ISwitchCase</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ISwitchCase</code>.
	 */
	function visitSwitchCase(element:ISwitchCase):void;
	
	/**
	 * Visits an <code>ISwitchDefault</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ISwitchDefault</code>.
	 */
	function visitSwitchDefault(element:ISwitchDefault):void;
	
	/**
	 * Visits an <code>ISwitchStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ISwitchStatement</code>.
	 */
	function visitSwitchStatement(element:ISwitchStatement):void;
	
	/**
	 * Visits an <code>IThisStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IThisStatement</code>.
	 */
	function visitThisStatement(element:IThisStatement):void;
	
	/**
	 * Visits an <code>IThrowStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IThrowStatement</code>.
	 */
	function visitThrowStatement(element:IThrowStatement):void;
	
	/**
	 * Visits an <code>ITryStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>ITryStatement</code>.
	 */
	function visitTryStatement(element:ITryStatement):void;
	
	/**
	 * Visits an <code>IUndefinedLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IUndefinedLiteral</code>.
	 */
	function visitUndefinedLiteral(element:IUndefinedLiteral):void;
	
	/**
	 * Visits an <code>IVarDeclarationFragment</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IVarDeclarationFragment</code>.
	 */
	function visitVarDeclarationFragment(element:IDeclaration):void;
	
	/**
	 * Visits an <code>IWhileStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IWhileStatement</code>.
	 */
	function visitWhileStatement(element:IWhileStatement):void;
	
	/**
	 * Visits an <code>IWithStatement</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IWithStatement</code>.
	 */
	function visitWithStatement(element:IWithStatement):void;
	
	/**
	 * Visits an <code>IXMLLiteral</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IXMLLiteral</code>.
	 */
	//function visitXMLLiteral(element:IXMLLiteral):void;
}
}