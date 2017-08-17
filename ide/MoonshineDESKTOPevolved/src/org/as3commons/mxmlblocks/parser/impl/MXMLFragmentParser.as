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

package org.as3commons.mxmlblocks.parser.impl
{

import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * A utility class to parse mxml fragements that don't start
 * at the <code>MXMLNodeKind.COMPILATION_UNIT</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MXMLFragmentParser
{
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Parses a <code>MXMLNodeKind.COMPILATION_UNIT</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>MXMLNodeKind.COMPILATION_UNIT</code> node.
	 */
	public static function parseCompilationUnit(source:String):IParserNode
	{
		var parser:MXMLParser = createParser(source);
		var node:IParserNode = parser.parseCompilationUnit();
		return node;
	}
	
	/**
	 * Parses a <code>MXMLNodeKind.TAG_LIST</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>MXMLNodeKind.TAG_LIST</code> node.
	 */
	public static function parseTagList(source:String):IParserNode
	{
		var parser:MXMLParser = createParser(source);
		parser.nextToken();
		var node:IParserNode = parser.parseTagList();
		return node;
	}
	
	/**
	 * Parses a <code>MXMLNodeKind.ATT_LIST</code> node.
	 * 
	 * @param source A String source to be parsed into AST.
	 * @return Returns a <code>MXMLNodeKind.ATT_LIST</code> node.
	 */
	public static function parseAttList(source:String):IParserNode
	{
		var parser:MXMLParser = createParser(source);
		parser.nextToken();
		var node:IParserNode = parser.parseAttList();
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
	private static function createParser(source:String):MXMLParser
	{
		var parser:MXMLParser = new MXMLParser();
		parser.scanner.setLines(Vector.<String>(source.split("\n")));
		return parser
	}
}
}