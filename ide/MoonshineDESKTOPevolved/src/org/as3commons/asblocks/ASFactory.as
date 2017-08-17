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

import org.as3commons.asblocks.api.IArrayAccessExpression;
import org.as3commons.asblocks.api.IArrayLiteral;
import org.as3commons.asblocks.api.IAssignmentExpression;
import org.as3commons.asblocks.api.IBinaryExpression;
import org.as3commons.asblocks.api.IBlock;
import org.as3commons.asblocks.api.IBooleanLiteral;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IConditionalExpression;
import org.as3commons.asblocks.api.IDeclarationStatement;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.api.IFieldAccessExpression;
import org.as3commons.asblocks.api.IFunctionLiteral;
import org.as3commons.asblocks.api.IINvocationExpression;
import org.as3commons.asblocks.api.INewExpression;
import org.as3commons.asblocks.api.INullLiteral;
import org.as3commons.asblocks.api.INumberLiteral;
import org.as3commons.asblocks.api.IObjectLiteral;
import org.as3commons.asblocks.api.IPostfixExpression;
import org.as3commons.asblocks.api.IPrefixExpression;
import org.as3commons.asblocks.api.ISimpleNameExpression;
import org.as3commons.asblocks.api.IStatement;
import org.as3commons.asblocks.api.IStringLiteral;
import org.as3commons.asblocks.api.IUndefinedLiteral;
import org.as3commons.asblocks.api.IVectorExpression;
import org.as3commons.asblocks.impl.ASParserImpl;
import org.as3commons.asblocks.impl.ASProject;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTExpressionBuilder;
import org.as3commons.asblocks.impl.ASTLiteralBuilder;
import org.as3commons.asblocks.impl.ASTStatementBuilder;
import org.as3commons.asblocks.impl.ASTTypeBuilder;
import org.as3commons.asblocks.impl.ASWriter;
import org.as3commons.asblocks.impl.ArrayAccessExpressionNode;
import org.as3commons.asblocks.impl.ArrayLiteralNode;
import org.as3commons.asblocks.impl.BooleanLiteralNode;
import org.as3commons.asblocks.impl.CompilationUnitNode;
import org.as3commons.asblocks.impl.ConditionalExpressionNode;
import org.as3commons.asblocks.impl.ExpressionBuilder;
import org.as3commons.asblocks.impl.FieldAccessExpressionNode;
import org.as3commons.asblocks.impl.FunctionLiteralNode;
import org.as3commons.asblocks.impl.InvocationExpressionNode;
import org.as3commons.asblocks.impl.NewExpressionNode;
import org.as3commons.asblocks.impl.NullLiteralNode;
import org.as3commons.asblocks.impl.NumberLiteralNode;
import org.as3commons.asblocks.impl.ObjectLiteralNode;
import org.as3commons.asblocks.impl.PostfixExpressionNode;
import org.as3commons.asblocks.impl.PrefixExpressionNode;
import org.as3commons.asblocks.impl.SimpleNameExpressionNode;
import org.as3commons.asblocks.impl.StatementBuilder;
import org.as3commons.asblocks.impl.StatementList;
import org.as3commons.asblocks.impl.StringLiteralNode;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.impl.UndefinedLiteralNode;
import org.as3commons.asblocks.impl.VectorExpressionNode;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.mxmlblocks.IMXMLParser;
import org.as3commons.mxmlblocks.api.IBlockTag;
import org.as3commons.mxmlblocks.impl.ASTMXMLBuilder;
import org.as3commons.mxmlblocks.impl.MXMLParserImpl;
import org.as3commons.mxmlblocks.impl.TagList;

// TODO (mschmalle) figure out how to separate MXML implementation

/**
 * The <code>ASFactory</code> is the default concrete interface factory for the
 * creation of ActionScript 3 building blocks in the ASBlocks library.
 * 
 * <p>Creating a factory allows the developer to create and write projects, 
 * classes, interfaces and other ActionScript 3 building blocks. The factory
 * also allows the developer to read and parse ActionScript 3 code files and 
 * Strings into Abstract Syntax Trees (AST). After the AST has been created,
 * the ASBlocks API can then be used to modifiy the source code.</p>
 * 
 * <p>The default base implementation of the <code>ASFactory</code> allows 
 * for creation of expressions, literals, blocks, parsers and writers. This 
 * implementation of the factory does not allow for file system access do
 * to the restriction on AIR dependencies (see the ASBuilder library).</p>
 * 
 * <pre>
 * // create a class unit with out the project overhead
 * var factory:ASFactory = new ASFactory();
 * var cunit:ICompilationUnit = factory.newClass("foo.bar.Baz");
 * // or create a class unit using the project
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = factory.newEmptyASProject(".");
 * // creates and adds the compilation unit to the project
 * var cunit:ICompilationUnit = project.newClass("foo.bar.Baz");
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.IASProject
 */
public class ASFactory
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ASFactory()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Global Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>IASProject</code> project and sets it's 
	 * <code>outputLocation</code>.
	 * 
	 * <p><strong>Note:</strong> Subclasses can override the default behavior 
	 * and return their own custom instances of <code>IASProject</code>. This
	 * is true for the <code>ASBuilderFactory</code> which returns an AIR dependent 
	 * project which can access the file system and load SWC resources.</p>
	 * 
	 * @param outputLocation A <code>String</code> indicating the output location
	 * of the project's source code.
	 * @return The implemented <code>IASProject</code> project.
	 * 
	 * @see org.as3commons.asblocks.IASProject
	 */
	public function newEmptyASProject(outputLocation:String):IASProject
	{
		var result:IASProject = createASProject();
		result.outputLocation = outputLocation;
		return result;
	}
	
	/**
	 * Returns a new <code>IASParser</code> implementation.
	 * 
	 * @return The implemented <code>IASParser</code> parser.
	 * 
	 * @see org.as3commons.asblocks.IASParser
	 */
	public function newParser():IASParser
	{
		return new ASParserImpl();
	}
	
	/**
	 * Returns a new <code>IMXMLParser</code> implementation.
	 * 
	 * @return The implemented <code>IMXMLParser</code> parser.
	 * 
	 * @see org.as3commons.mxmlblocks.IMXMLParser
	 */
	public function newMXMLParser():IMXMLParser
	{
		return new MXMLParserImpl();
	}
	
	/**
	 * Returns a new <code>ISourceCode</code> implementation.
	 * 
	 * @return The implemented <code>ISourceCode</code> instance.
	 */
	public function newSourceCode(code:String = null,
								  filePath:String = null):ISourceCode
	{
		return new SourceCode(code, filePath);
	}
	
	/**
	 * Returns a new <code>IASWriter</code> implementation.
	 * 
	 * @return The implemented <code>IASWriter</code> writer.
	 * 
	 * @see org.as3commons.asblocks.IASWriter
	 */
	public function newWriter():IASWriter
	{
		return new ASWriter();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Type Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new public <strong>class</strong> <code>ICompilationUnit</code>.
	 * 
	 * @param qualifiedName The <code>String</code> qualified name of the class.
	 * @return A new class <code>ICompilationUnit</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IClassType
	 */
	public function newClass(qualifiedName:String):ICompilationUnit
	{
		var ast:IParserNode = ASTTypeBuilder.newClassCompilationUnitAST(qualifiedName);
		return new CompilationUnitNode(ast);
	}
	
	/**
	 * Creates a new public <strong>interface</strong> <code>ICompilationUnit</code>.
	 * 
	 * @param qualifiedName The <code>String</code> qualified name of the interface.
	 * @return A new interface <code>ICompilationUnit</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IInterfaceType
	 */
	public function newInterface(qualifiedName:String):ICompilationUnit
	{
		var ast:IParserNode = ASTTypeBuilder.newInterfaceCompilationUnitAST(qualifiedName);
		return new CompilationUnitNode(ast);
	}
	
	/**
	 * Creates a new public <strong>function</strong> <code>ICompilationUnit</code>.
	 * 
	 * @param qualifiedName The <code>String</code> qualified name of the function.
	 * @param returnType The <code>String</code> return type of the function.
	 * @return A new interface <code>ICompilationUnit</code>.
	 * 
	 * @see org.as3commons.asblocks.api.IFunctionType
	 */
	public function newFunction(qualifiedName:String, returnType:String):ICompilationUnit
	{
		var ast:IParserNode = ASTTypeBuilder.newFunctionCompilationUnitAST(qualifiedName, returnType);
		return new CompilationUnitNode(ast);
	}
	
	/**
	 * Creates a new MXML Application.
	 * 
	 * @param qualifiedName The <code>String</code> qualified name of the 
	 * application.
	 * @param superQualifiedName The <code>String</code> qualified name of the 
	 * application's super class.
	 * @return A new application <code>ICompilationUnit</code>.
	 */
	public function newApplication(qualifiedName:String, 
								   superQualifiedName:String):ICompilationUnit
	{
		return ASTMXMLBuilder.newApplicationCompilationUnit(qualifiedName, superQualifiedName);
	}
	
	/**
	 * Creates a new MXML tag.
	 * 
	 * @param name A String indicating the localName of the tag.
	 * @param binding A String indicating the tag's namespace binding, if any.
	 * @return A new <code>IBlockTag</code>.
	 */
	public function newTag(name:String, binding:String = null):IBlockTag
	{
		var ast:IParserNode = ASTMXMLBuilder.newTag(name, binding);
		return new TagList(ast);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Literals Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>Number</code> literal.
	 * 
	 * @param number The <code>Number</code> value for the literal.
	 * @return A new <code>INumberLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.INumberLiteral
	 */
	public function newNumberLiteral(number:Number):INumberLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newNumberLiteral(number);
		return new NumberLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>null</code> literal.
	 * 
	 * @return A new <code>INullLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.INullLiteral
	 */
	public function newNullLiteral():INullLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newNullLiteral();
		return new NullLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>undefined</code> literal.
	 * 
	 * @return A new <code>IUndefinedLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IUndefinedLiteral
	 */
	public function newUndefinedLiteral():IUndefinedLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newUndefinedLiteral();
		return new UndefinedLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>Boolean</code> literal.
	 * 
	 * @param boolean The <code>Boolean</code> value for the literal.
	 * @return A new <code>IBooleanLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBooleanLiteral
	 */
	public function newBooleanLiteral(boolean:Boolean):IBooleanLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newBooleanLiteral(boolean);
		return new BooleanLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>String</code> literal.
	 * 
	 * <p>Note: The passed value does not inlude the start and end quotes, 
	 * unless they need to be escaped.</p>
	 * 
	 * @param string The <code>String</code> value for the literal.
	 * @return A new <code>IStringLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IStringLiteral
	 */
	public function newStringLiteral(string:String):IStringLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newStringLiteral(string);
		return new StringLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>[a, b, c]</code> literal.
	 * 
	 * @return A new <code>IArrayLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IArrayLiteral
	 */
	public function newArrayLiteral():IArrayLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newArrayLiteral();
		return new ArrayLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>{a:1, b:2, c:3}</code> literal.
	 * 
	 * @return A new <code>IObjectLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IObjectLiteral
	 */
	public function newObjectLiteral():IObjectLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newObjectLiteral();
		return new ObjectLiteralNode(ast);
	}
	
	/**
	 * Creates a new <code>function():void {}</code> literal.
	 * 
	 * @return A new <code>IFunctionLiteral</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IFunctionLiteral
	 */
	public function newFunctionLiteral():IFunctionLiteral
	{
		var ast:IParserNode = ASTLiteralBuilder.newFunctionLiteral();
		return new FunctionLiteralNode(ast);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Expressions Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>IExpression</code> by parsing the expression String.
	 * 
	 * @param expression A <code>String</code> expression to parse.
	 * @return A new <code>IExpression</code>.
	 */
	public function newExpression(expression:String):IExpression
	{
		var ast:IParserNode = AS3FragmentParser.parseExpression(expression);
		ast.parent = null;
		return ExpressionBuilder.build(ast);
	}
	
	/**
	 * Creates a new <code>IVectorExpression</code> by parsing the type String.
	 * 
	 * @param type A <code>String</code> <code>Vector</code> type to parse.
	 * @return A new <code>IVectorExpression</code>.
	 */
	public function newVectorExpression(type:String):IVectorExpression
	{
		var ast:IParserNode = AS3FragmentParser.parseType("Vector.<" + type + ">");
		ast.parent = null;
		return new VectorExpressionNode(ast);
	}
	
	//----------------------------------
	//  Assignment
	//----------------------------------
	
	/**
	 * Creates a new <code>a = b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newAssignExpression(left:IExpression,
										right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a += b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newAddAssignExpression(left:IExpression,
										   right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newAddAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a &amp;= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newBitAndAssignExpression(left:IExpression,
											  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newBitAndAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a |= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newBitOrAssignExpression(left:IExpression,
											 right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newBitOrAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a ^= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newBitXorAssignExpression(left:IExpression,
											  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newBitXorAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a \= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newDivideAssignExpression(left:IExpression,
											  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newDivAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a %= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newModuloAssignExpression(left:IExpression,
											  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newModAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a *= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newMultiplyAssignExpression(left:IExpression,
												right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newStarAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a &lt;&lt;= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newShiftLeftAssignExpression(left:IExpression,
												 right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newSLAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a &gt;&gt;= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newShiftRightAssignExpression(left:IExpression,
												  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newSRAssign(), left, right);
	}
	
	/**
	 * @private
	 */
	public function newShiftRightUnsignedAssignExpression(left:IExpression,
														  right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newSRUAssign(), left, right);
	}
	
	/**
	 * Creates a new <code>a -= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IAssignmentExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IAssignmentExpression
	 */
	public function newSubtractAssignExpression(left:IExpression,
												right:IExpression):IAssignmentExpression
	{
		return ASTExpressionBuilder.newAssignExpression(TokenBuilder.newSubAssign(), left, right);
	}
	
	//----------------------------------
	//  Binary
	//----------------------------------
	
	/**
	 * Creates a new <code>a + b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newAddExpression(left:IExpression, 
									 right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newPlus(), left, right);
	}
	
	/**
	 * Creates a new <code>a &amp;&amp; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newAndExpression(left:IExpression, 
									 right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newAnd(), left, right);
	}
	
	/**
	 * Creates a new <code>a &amp; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newBitAndExpression(left:IExpression, 
										right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newBitAnd(), left, right);
	}
	
	/**
	 * Creates a new <code>a | b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newBitOrExpression(left:IExpression, 
									   right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newBitOr(), left, right);
	}
	
	/**
	 * Creates a new <code>a ^ b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newBitXorExpression(left:IExpression, 
										right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newBitXor(), left, right);
	}
	
	/**
	 * Creates a new <code>a / b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newDivisionExpression(left:IExpression, 
										  right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newDiv(), left, right);
	}
	
	/**
	 * Creates a new <code>a == b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newEqualsExpression(left:IExpression, 
										right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newEquals(), left, right);
	}
	
	/**
	 * Creates a new <code>a &gt;= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newGreaterEqualsExpression(left:IExpression, 
											   right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newGreaterEquals(), left, right);
	}
	
	/**
	 * Creates a new <code>a &gt; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newGreaterThanExpression(left:IExpression, 
											 right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newGreater(), left, right);
	}
	
	/**
	 * Creates a new <code>a &lt;= b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newLessEqualsExpression(left:IExpression, 
											right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newLessEquals(), left, right);
	}
	
	/**
	 * Creates a new <code>a &lt; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newLessThanExpression(left:IExpression, 
										  right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newLess(), left, right);
	}
	
	/**
	 * Creates a new <code>a % b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newModuloExpression(left:IExpression, 
										right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newModulo(), left, right);
	}
	
	/**
	 * Creates a new <code>a * b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newMultiplyExpression(left:IExpression, 
										  right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newMult(), left, right);
	}
	
	/**
	 * Creates a new <code>a != b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newNotEqualsExpression(left:IExpression, 
										   right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newNotEquals(), left, right);
	}
	
	/**
	 * Creates a new <code>a || b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newOrExpression(left:IExpression, 
									right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newOr(), left, right);
	}
	
	/**
	 * Creates a new <code>a &lt;&lt; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newShiftLeftExpression(left:IExpression, 
										   right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newShiftLeft(), left, right);
	}
	
	/**
	 * Creates a new <code>a &gt;&gt; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newShiftRightExpression(left:IExpression, 
											right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newShiftRight(), left, right);
	}
	
	/**
	 * Creates a new <code>a &gt;&gt;&gt; b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newShiftRightUnsignedExpression(left:IExpression, 
													right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newShiftRightUnsigned(), left, right);
	}
	
	/**
	 * Creates a new <code>a - b</code> expression.
	 * 
	 * @param left The left side <code>IExpression</code>.
	 * @param right The right side <code>IExpression</code>.
	 * @return A new <code>IBinaryExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBinaryExpression
	 */
	public function newSubtractExpression(left:IExpression, 
										  right:IExpression):IBinaryExpression
	{
		return ASTExpressionBuilder.newBinaryExpression(TokenBuilder.newMinus(), left, right);
	}
	
	//----------------------------------
	//  Conditional
	//----------------------------------
	
	/**
	 * Creates a new <code>condition ? then : else</code> expression.
	 * 
	 * @param conditionExpression The evaluated condition <code>IExpression</code>.
	 * @param thenExpression The <code>true</code> executed <code>IExpression</code>.
	 * @param elseExpression The <code>false</code> executed <code>IExpression</code>.
	 * @return A new <code>IConditionalExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IConditionalExpression
	 */
	public function newConditionalExpression(conditionExpression:IExpression, 
											 thenExpression:IExpression,
											 elseExpression:IExpression):IConditionalExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newConditionalExpression(
			conditionExpression.node, thenExpression.node, elseExpression.node);
		return new ConditionalExpressionNode(ast);
	}
	
	//----------------------------------
	//  Invocation
	//----------------------------------
	
	/**
	 * Creates a new <code>target(arguments)</code> expression.
	 * 
	 * @param target The invocation target <code>IExpression</code>.
	 * @param arguments The <code>Vector</code> of <code>IExpression</code> 
	 * invocation arguments.
	 * @return A new <code>IINvocationExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IINvocationExpression
	 */
	public function newInvocationExpression(target:IExpression, 
											arguments:Vector.<IExpression>):IINvocationExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newInvocationExpression(target.node);
		var result:IINvocationExpression = new InvocationExpressionNode(ast);
		result.arguments = arguments;
		return result;
	}
	
	/**
	 * Creates a new <code>new Target(arguments)</code> expression.
	 * 
	 * @param target The instantiation invocation target <code>IExpression</code>.
	 * @param arguments The <code>Vector</code> of <code>IExpression</code> 
	 * invocation arguments.
	 * @return A new <code>INewExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.INewExpression
	 */
	public function newNewExpression(target:IExpression, 
									 arguments:Vector.<IExpression> = null):INewExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newNewExpression(target.node);
		var result:INewExpression = new NewExpressionNode(ast);
		if (arguments != null)
		{
			result.arguments = arguments;
		}
		return result;
	}
	
	//----------------------------------
	//  Prefix & Post
	//----------------------------------
	
	/**
	 * Creates a new <code>expression--</code> expression.
	 * 
	 * @param expression The decrement <code>IExpression</code>.
	 * @return A new <code>IPostfixExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IPostfixExpression
	 */
	public function newPostDecExpression(expression:IExpression):IPostfixExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newPostfixExpression(
			TokenBuilder.newPostDec(), expression.node);
		return new PostfixExpressionNode(ast);
	}
	
	/**
	 * Creates a new <code>expression++</code> expression.
	 * 
	 * @param expression The increment <code>IExpression</code>.
	 * @return A new <code>IPostfixExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IPostfixExpression
	 */
	public function newPostIncExpression(expression:IExpression):IPostfixExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newPostfixExpression(
			TokenBuilder.newPostInc(), expression.node);
		return new PostfixExpressionNode(ast);
	}
	
	/**
	 * Creates a new <code>--expression</code> expression.
	 * 
	 * @param expression The decrement <code>IExpression</code>.
	 * @return A new <code>IPrefixExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IPrefixExpression
	 */
	public function newPreDecExpression(expression:IExpression):IPrefixExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newPrefixExpression(
			TokenBuilder.newPreDec(), expression.node);
		return new PrefixExpressionNode(ast);
	}
	
	/**
	 * Creates a new <code>++expression</code> expression.
	 * 
	 * @param expression The increment <code>IExpression</code>.
	 * @return A new <code>IPrefixExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IPrefixExpression
	 */
	public function newPreIncExpression(expression:IExpression):IPrefixExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newPrefixExpression(
			TokenBuilder.newPreInc(), expression.node);
		return new PrefixExpressionNode(ast);
	}
	
	//----------------------------------
	//  Access
	//----------------------------------
	
	/**
	 * Creates a new <code>target.name</code> expression.
	 * 
	 * @param target The target access <code>IExpression</code>.
	 * @param name The name of the target access <code>IExpression</code>.
	 * @return A new <code>IFieldAccessExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IFieldAccessExpression
	 */
	public function newFieldAccessExpression(target:IExpression, 
											 name:String):IFieldAccessExpression
	{
		var ast:IParserNode = ASTExpressionBuilder.newFieldAccessExpression(
			target.node, ASTBuilder.newAST(AS3NodeKind.NAME, name));
		return new FieldAccessExpressionNode(ast);
	}
	
	/**
	 * Creates a new <code>target[subscript]</code> expression.
	 * 
	 * @param target The target access <code>IExpression</code>.
	 * @param target The subscript of the target access <code>IExpression</code>.
	 * @return A new <code>IArrayAccessExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IArrayAccessExpression
	 */
	public function newArrayAccessExpression(target:IExpression, 
											 subscript:IExpression):IArrayAccessExpression
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.ARRAY_ACCESSOR);
		var targetAST:IParserNode = target.node;
		ast.addChild(targetAST);
		ast.appendToken(TokenBuilder.newLeftBracket());
		var subAST:IParserNode = subscript.node;
		ast.addChild(subAST);
		ast.appendToken(TokenBuilder.newRightBracket());
		return new ArrayAccessExpressionNode(ast);
	}
	
	//----------------------------------
	//  Name
	//----------------------------------
	
	/**
	 * Creates a new <code>name</code> expression.
	 * 
	 * @param name The <code>String</code> name.
	 * @return A new <code>ISimpleNameExpression</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.ISimpleNameExpression
	 */
	public function newSimpleNameExpression(name:String):ISimpleNameExpression
	{
		var ast:IParserNode = AS3FragmentParser.parsePrimaryExpression(name);
		return new SimpleNameExpressionNode(ast);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Statement Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new statement using the <code>AS3FragmentParser.parseStatement()</code>
	 * and the <code>StatementBuilder.build()</code> to construct the new statement.
	 * 
	 * @param statement The <code>String</code> statement to be parsed and built.
	 * @return A new <code>IStatement</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IStatement
	 */
	public function newStatement(statement:String):IStatement
	{
		var ast:IParserNode = AS3FragmentParser.parseStatement(statement);
		ast.parent = null;
		return StatementBuilder.build(ast);
	}
	
	/**
	 * Creates a new block statement <code>{ }</code>.
	 * 
	 * @return A new <code>IBlock</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IBlock
	 * @see org.as3commons.asblocks.api.IStatement
	 * @see org.as3commons.asblocks.api.IStatementContainer
	 */
	public function newBlock():IBlock
	{
		var ast:IParserNode = ASTStatementBuilder.newBlock();
		return new StatementList(ast);
	}
	
	/**
	 * Creates a new <code>var i:int = 0;</code> that can be turned into
	 * a <code>const i:int = 0, j:int = 1;</code> statement.
	 * 
	 * @return A new <code>IDeclarationStatement</code> instance.
	 * 
	 * @see org.as3commons.asblocks.api.IDeclarationStatement
	 */
	public function newDeclaration(declaration:String):IDeclarationStatement
	{
		var ast:IParserNode = AS3FragmentParser.parseDecList(declaration);
		ast.parent = null;
		return StatementBuilder.build(ast) as IDeclarationStatement;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected Creation :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Returns an instance of the <code>IASProject</code> project for the 
	 * specific factory implementation.
	 * 
	 * return The implemented <code>IASProject</code> project.
	 */
	protected function createASProject():IASProject
	{
		var result:IASProject = new ASProject(this);
		return result;
	}
}
}