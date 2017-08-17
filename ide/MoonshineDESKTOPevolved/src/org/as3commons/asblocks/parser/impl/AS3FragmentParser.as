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

package org.as3commons.asblocks.parser.impl
{

import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * A utility class to parse actionscript3 fragements that don't start
 * at the <code>AS3NodeKind.COMPILATION_UNIT</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class AS3FragmentParser
{
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Parses a <code>AS3NodeKind.COMPILATION_UNIT</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.COMPILATION_UNIT</code> node.
	 */
	public static function parseCompilationUnit(source:String):IParserNode
	{
		var parser:AS3Parser = createParser(source);
		var node:IParserNode = parser.parseCompilationUnit();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.PACKAGE</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.PACKAGE</code> node.
	 */
	public static function parsePackage(source:String):IParserNode
	{
		var parser:AS3Parser = createParser(source);
		parser.nextToken(); // package
		var node:IParserNode = parser.parsePackage();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node.
	 */
	public static function parsePackageContent(source:String):IParserNode
	{
		var parser:AS3Parser = createParser("{" + source + "}");
		parser.nextToken(); // package
		var node:IParserNode = parser.parsePackageContent();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node.
	 */
	public static function parseClassContent(source:String):IParserNode
	{
		var parser:AS3Parser = createParser("{" + source + "}");
		parser.nextToken(); // {
		var node:IParserNode = parser.parseTypeContent();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node.
	 */
	public static function parseInterfaceContent(source:String):IParserNode
	{
		var parser:AS3Parser = createParser("{" + source + "}");
		parser.nextToken(); // {
		var node:IParserNode = parser.parseTypeContent();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.META_LIST</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.META_LIST</code> node.
	 */
	public static function parseMetaData(source:String):IParserNode
	{
	//	var parser:AS3Parser2 = createParser(source);
	//	parser.nextToken();
	//	var node:IParserNode = parser.parseMetaDatas();
	//	return node;
		return null;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> list of 
	 * <code>AS3NodeKind.CONST</code> nodes.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node of
	 * <code>AS3NodeKind.CONST</code> nodes.
	 */
	public static function parseConstants(source:String):IParserNode
	{
		//var parser:AS3Parser2 = createParser(source);
		//parser.nextToken();
		//var node:IParserNode = parser.parseConstants();
		//return node;
		return parseClassContent(source);
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> list of 
	 * <code>AS3NodeKind.VAR</code> nodes.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node of
	 * <code>AS3NodeKind.VAR</code> nodes.
	 */
	public static function parseVariables(source:String):IParserNode
	{
	//	var parser:AS3Parser2 = createParser(source);
	//	parser.nextToken();
	//	var node:IParserNode = parser.parseVariables();
	//	return node;
		return null;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.CONTENT</code> list of 
	 * <code>AS3NodeKind.FUNCTION</code>, <code>AS3NodeKind.GET</code>
	 * or <code>AS3NodeKind.SET</code> nodes.
	 * 
	 * <p>The result depends on the source passed to the parser. If get 
	 * and set accessors are all you want in this list just pass either
	 * get, set or get and set property definitions. Otherwise, just pas
	 * methods that will be returned as <code>FUNCTION</code>.</p>
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONTENT</code> node of
	 * <code>AS3NodeKind.FUNCTION</code>, <code>AS3NodeKind.GET</code>
	 * or <code>AS3NodeKind.SET</code> nodes.
	 */
	public static function parseMethods(source:String):IParserNode
	{
	//	var parser:AS3Parser2 = createParser(source);
	//	parser.nextToken();
	//	var node:IParserNode = parser.parseMethods();
	//	return node;
		return null;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.BLOCK</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.BLOCK</code> node.
	 */
	public static function parseBlock(source:String):IParserNode
	{
		var parser:AS3Parser = createParser("{" + source + "}");
		parser.nextToken(); // {
		var node:IParserNode = parser.parseBlock();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.STATEMENT</code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.STATEMENT</code> node.
	 */
	public static function parseStatement(statement:String, useSemi:Boolean = true):IParserNode
	{
		var semi:String = (useSemi) ? ";" : "";
		var parser:AS3Parser = createParser(statement + semi);
		parser.nextToken();
		var node:IParserNode = parser.parseStatement();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.EXPR_STMNT</code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.EXPR_STMNT</code> node.
	 */
	public static function parseExpressionStatement(statement:String):IParserNode
	{
		var parser:AS3Parser = createParser(statement + ";");
		parser.nextToken();
		var node:IParserNode = parser.parseExpressionStatement();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.EXPR_LIST</code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.EXPR_LIST</code> node.
	 */
	public static function parseExpressionList(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parseExpressionList();
		return node;
	}
	
	/**
	 * Parses a <code>AS3NodeKind.PRIMARY</code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.PRIMARY</code> node.
	 */
	public static function parsePrimaryExpression(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parsePrimaryExpression();
		return node;
	}
	
	/**
	 * Parses a <code></code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code></code> node.
	 */
	public static function parseExpression(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parseExpression();
		return node;
	}
	
	/**
	 * Parses a <code></code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code></code> node.
	 */
	public static function parseForInit(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parseForInit();
		return node;
	}
	
	/**
	 * Parses a <code></code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code></code> node.
	 */
	public static function parseForCond(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parseForCond();
		return node;
	}
	
	/**
	 * Parses a <code></code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code></code> node.
	 */
	public static function parseForIter(expression:String):IParserNode
	{
		var parser:AS3Parser = createParser(expression);
		parser.nextToken();
		var node:IParserNode = parser.parseForIter();
		return node;
	}
	/**
	 * Parses a <code>AS3NodeKind.CONDITION</code> node.
	 * 
	 * @param statement A String statement to be parsed into AST.
	 * @return Returns a <code>AS3NodeKind.CONDITION</code> node.
	 */
	public static function parseCondition(condition:String):IParserNode
	{
		var parser:AS3Parser = createParser("(" + condition + ")");
		parser.nextToken();
		// /condition
		var node:IParserNode = parser.parseCondition();
		return node;
	}
	
	public static function parseDecList(assignment:String):IParserNode
	{
		var parser:AS3Parser = createParser("var " + assignment + ";");
		parser.nextToken();
		var node:IParserNode = parser.parseDecList();
		return node;
	}
	
	public static function parseType(typeName:String):IParserNode
	{
		var parser:AS3Parser = createParser(typeName);
		parser.nextToken();
		var node:IParserNode = parser.parseType();
		return node;
	}
	
	public static function parseName(name:String):IParserNode
	{
		var parser:AS3Parser = createParser(name);
		parser.nextToken();
		var node:IParserNode = parser.parseName();
		return node;
	}
	
	public static function parseImport(name:String):IParserNode
	{
		var parser:AS3Parser = createParser("import " + name + ";");
		parser.nextToken();
		var node:IParserNode = parser.parseImport();
		return node;
	}
	
	
	
	//--------------------------------------------------------------------------
	//
	//  Private Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static function createParser(source:String):AS3Parser
	{
		var parser:AS3Parser = new AS3Parser();
		parser.scanner.setLines(Vector.<String>(source.split("\n")));
		return parser
	}
}
}