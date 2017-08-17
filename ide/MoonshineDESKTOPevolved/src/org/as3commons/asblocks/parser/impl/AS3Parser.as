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

import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.api.ISourceCodeScanner;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.api.Operators;
import org.as3commons.asblocks.parser.core.AS3ParserMap;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.core.Node;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.utils.ASTUtil;

// FIXME (mschmalle) XML and RegExp
// FIXME (mschmalle) create a timeout handler for infinate loops

/**
 * A port of the Java PMD de.bokelberg.flex.parser.AS3Parser.
 * 
 * <p>Initial Implementation; Adobe Systems, Incorporated</p>
 * 
 * @author Michael Schmalle LinkedList implementation, continual 
 * language additions, refactor of toplevel (compunit, package, type) parsing
 */
public class AS3Parser extends ParserBase
{	
	//--------------------------------------------------------------------------
	//
	//  Private :: Constants
	//
	//--------------------------------------------------------------------------
	
	public static const ASDOC_COMMENT:String = "/**";
	
	public static const MULTIPLE_LINES_COMMENT:String = "/*";
	
	public static const SINGLE_LINE_COMMENT:String = "//";
	
	public static const NEW_LINE:String = "\n";
	
	private static const VECTOR:String = "Vector";
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	private var currentAsDoc:TokenNode;
	
	private var braceCount:int;
	
	private var isInFor:Boolean = false;
	
	//----------------------------------
	//  parseBlocks
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _parseBlocks:Boolean = true;
	
	/**
	 * doc
	 */
	public function get parseBlocks():Boolean
	{
		return _parseBlocks;
	}
	
	/**
	 * @private
	 */	
	public function set parseBlocks(value:Boolean):void
	{
		_parseBlocks = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function AS3Parser()
	{
		super();
		
		adapter = new LinkedListTreeAdaptor();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Protected :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function createScanner():IScanner
	{
		var scanner:AS3Scanner = new AS3Scanner();
		scanner.allowWhiteSpace = true;
		return scanner;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public var result:TokenNode;
	
	override public function parseCompilationUnit():IParserNode
	{
		 result = adapter.create(AS3NodeKind.COMPILATION_UNIT);
		
		// start the parse, eat whitespace up to a '/**' or 'package'
		nextTokenConsume(result);
		
		// if the package has a doc comment, save it
		if (tokenStartsWith(ASDOC_COMMENT))
		{
			result.addChild(parseASdoc());
			nextTokenConsume(result);
		}
		
		// go into package
		if (tokIs(KeyWords.PACKAGE))
		{
			result.addChild(parsePackage());
		}
		
		nextTokenConsume(result);
		
		if (!tokIs(KeyWords.EOF))
		{
			// parse internal classes|functions
			result.addChild(parsePackageContent());
		}
		
		result.appendToken(adapter.createToken(KeyWords.EOF));
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Internal :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function parsePackage():TokenNode
	{
		var result:TokenNode = adapter.copy(
			AS3NodeKind.PACKAGE, token);
		
		consumeWS(KeyWords.PACKAGE, result);
		
		if (!tokIs(Operators.LCURLY))
		{
			result.addChild(parseTypeSpec(AS3NodeKind.NAME));
		}
		
		result.addChild(parsePackageContent());
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parsePackageContent():IParserNode
	{
		var result:TokenNode = ASTUtil.newCurlyAST(
			AS3NodeKind.CONTENT, token) as TokenNode;
		
		var internalParse:Boolean = 
			tokIs(KeyWords.CLASS) || tokIs(KeyWords.FUNCTION) 
			|| tokIs(KeyWords.IMPORT) || tokIs(KeyWords.INCLUDE)
			|| tokIs(KeyWords.USE);
		
		if (!internalParse)
		{
			consumeWS(Operators.LCURLY, result);
		}
		else
		{
			result = adapter.empty(AS3NodeKind.INTERNAL_CONTENT, token);
		}
		
		var pendingType:TokenNode = adapter.empty(AS3NodeKind.PRIMARY, token);
		var pendingMetaList:TokenNode;
		var pendingModList:TokenNode;
		
		while (!tokIs(Operators.RCURLY)
			&& !tokIs(KeyWords.EOF))
		{
			if (tokIs(KeyWords.INCLUDE))
			{
				result.addChild(parseInclude());
			}
			else if (tokIs(KeyWords.IMPORT))
			{
				result.addChild(parseImport());
			}
			else if (tokIs(KeyWords.USE))
			{
				result.addChild(parseUse());
			}
			else if (tokIs(Operators.LBRACK))
			{
				if (!pendingType.hasKind(AS3NodeKind.META_LIST))
				{
					pendingMetaList = adapter.empty(AS3NodeKind.META_LIST, token);
					pendingType.addChild(pendingMetaList);
				}
				
				pendingMetaList.addChild(parseMetaData());
			}
			else if (tokenStartsWith(ASDOC_COMMENT))
			{
				pendingType.appendToken(adapter.createToken(
					AS3NodeKind.AS_DOC, token.text));
				
				currentAsDoc = parseASdoc();
			}
			else if (tokIs(KeyWords.CLASS))
			{
				result.addChild(parseClass(pendingType));
			}
			else if (tokIs(KeyWords.INTERFACE))
			{
				result.addChild(parseInterface(pendingType));
			}
			else if (tokIs(KeyWords.FUNCTION))
			{
				result.addChild(parseClassFunction(pendingType));
			}
			else
			{
				if (!tokIsWhitespace())
				{
					if (currentAsDoc)
					{
						addAsDoc(pendingType);
					}
					
					if (!pendingType.hasKind(AS3NodeKind.MOD_LIST))
					{
						pendingModList = adapter.empty(AS3NodeKind.MOD_LIST, token);
						pendingType.addChild(pendingModList);
					}
					
					pendingModList.addChild(adapter.copy(
						AS3NodeKind.MODIFIER, token));
					
					nextTokenConsume(pendingModList);
				}
				else
				{
					nextTokenConsume(pendingType);
				}
			}
		}
		
		if (!internalParse)
		{
			consumeWS(Operators.RCURLY, result, false);
		}
		
		if (pendingType.parent == null)
		{
			// parsing just metadata, this is a hack shortcut for now
			pendingType.removeChild(pendingMetaList);
			result.addChild(pendingMetaList);
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseClass(result:TokenNode):TokenNode
	{
		result.kind = AS3NodeKind.CLASS;
		result.line = token.line;
		result.column = token.column;
		
		consume(KeyWords.CLASS, result);
		
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		
		nextTokenConsume(result);
		
		while (!tokIs(Operators.LCURLY))
		{
			if (tokIs(KeyWords.EXTENDS))
			{
				result.addChild(parseExtendsList());
			}
			else if (tokIs(KeyWords.IMPLEMENTS))
			{
				result.addChild(parseImplementsList());
			}
			else
			{
				nextTokenConsume(result);
			}
		}
		
		result.addChild(parseTypeContent());
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseInterface(result:TokenNode):TokenNode
	{
		result.kind = AS3NodeKind.INTERFACE;
		result.line = token.line;
		result.column = token.column;
		
		consume(KeyWords.INTERFACE, result);
		
		result.addChild(adapter.copy(
			AS3NodeKind.NAME, token));
		
		nextTokenConsume(result);
		
		while (!tokIs(Operators.LCURLY))
		{
			if (tokIs(KeyWords.EXTENDS))
			{
				result.addChild(parseExtendsList());
			}
			else
			{
				nextTokenConsume(result);
			}
		}
		
		result.addChild(parseTypeContent());
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseTypeContent():TokenNode
	{
		var result:TokenNode = ASTUtil.newCurlyAST(
			AS3NodeKind.CONTENT, token) as TokenNode;
		
		consumeWS(Operators.LCURLY, result);
		
		var originalResult:TokenNode;
		var configResult:TokenNode;
		var pendingMember:TokenNode = adapter.empty(AS3NodeKind.PRIMARY, token);
		var pendingMetaList:TokenNode;
		var pendingModList:TokenNode;
		
		while (!tokIs(Operators.RCURLY) || configResult && tokIs(Operators.RCURLY))
		{
			if (tokenStartsWith(ASDOC_COMMENT))
			{
				var current:TokenNode = (pendingMember) ? pendingMember : result;
				current.appendToken(adapter.createToken(
					AS3NodeKind.AS_DOC, token.text));
				currentAsDoc = parseASdoc();
				nextTokenConsume(current);
			}
			else if (tokIs(KeyWords.INCLUDE))
			{
				result.addChild(parseInclude());
			}
			else if (tokIs(KeyWords.IMPORT))
			{
				result.addChild(parseImport());
			}
			else if (tokIs(Operators.LBRACK))
			{
				if (!pendingMember.hasKind(AS3NodeKind.META_LIST))
				{
					pendingMetaList = adapter.empty(AS3NodeKind.META_LIST, token);
					pendingMember.addChild(pendingMetaList);
				}
				
				pendingMetaList.addChild(parseMetaData());
			}
			else if (tokIs(Operators.LCURLY))
			{
				result.addChild(parseBlock());
			}
			else if (tokIs(KeyWords.VAR))
			{
				result.addChild(parseClassField(pendingMember));
				pendingMember = adapter.empty(AS3NodeKind.PRIMARY, token);
			}
			else if (tokIs(KeyWords.CONST))
			{
				result.addChild(parseClassConstant(pendingMember));
				pendingMember = adapter.empty(AS3NodeKind.PRIMARY, token);
			}
			else if (tokIs(KeyWords.FUNCTION))
			{
				result.addChild(parseClassFunction(pendingMember));
				pendingMember = adapter.empty(AS3NodeKind.PRIMARY, token);
			}
			else if (tokIs(KeyWords.NAMESPACE))
			{
				result.addChild(parseClassNamespace(pendingMember));
				pendingMember = adapter.empty(AS3NodeKind.PRIMARY, token);
			}
			else if (tokIs(KeyWords.CONFIG))
			{
				originalResult = result;
				result = configResult = adapter.empty(AS3NodeKind.CONFIG, token);
				originalResult.addChild(configResult);
				consume(KeyWords.CONFIG, result);
				consume(Operators.DBL_COLON, result);
				configResult.addChild(parseName());
				consume(Operators.LCURLY, result);
			}
			else if (configResult && tokIs(Operators.RCURLY))
			{
				result = originalResult;
				configResult = null;
				consume(Operators.RCURLY);
			}
			else
			{
				if (!tokIsWhitespace())
				{
					addAsDoc(pendingMember);
					
					if (!pendingMember.hasKind(AS3NodeKind.MOD_LIST))
					{
						pendingModList = adapter.empty(AS3NodeKind.MOD_LIST, token);
						pendingMember.addChild(pendingModList);
					}
					
					pendingModList.addChild(adapter.copy(
						AS3NodeKind.MODIFIER, token));
					
					nextTokenConsume(pendingModList);
				}
				else
				{
					nextTokenConsume(pendingMember);
				}
			}
		}
		
		consumeWS(Operators.RCURLY, result, false);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseTypeSpec(kind:String):TokenNode
	{
		var result:TokenNode = adapter.empty(kind, token);
		
		var buffer:String = "";
		consumeWhitespace(result);
		buffer += token.text; // name
		nextTokenConsume(result); 
		while (tokIs(Operators.DOT) || tokIs(Operators.DBL_COLON))
		{
			buffer += token.text; // '.', '::'
			nextTokenConsume(result); 
			buffer += token.text; // name
			nextTokenConsume(result);
		}
		
		result.stringValue = buffer;
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseQualifiedName():String
	{
		var buffer:String = "";
		
		buffer += token.text;
		nextToken();
		while (tokIs(Operators.DOT) || tokIs(Operators.DBL_COLON))
		{
			buffer += token.text;
			nextToken(); // '.' '::'
			buffer += token.text;
			nextToken(); // name
		}
		return buffer;
	}
	
	/**
	 * @private
	 */
	private function parseInclude():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.INCLUDE, token);
		consume(KeyWords.INCLUDE, result); // include
		result.addChild(parseExpression()); // expression
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseImport():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.IMPORT, token);
		consume(KeyWords.IMPORT, result); // import
		result.addChild(parseTypeSpec(AS3NodeKind.TYPE)); // foo.bar
		skip(Operators.SEMI, result); // ;
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseUse():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.USE, token);
		consume(KeyWords.USE, result); // use
		consume(KeyWords.NAMESPACE, result); // namespace
		result.addChild(parseTypeSpec(AS3NodeKind.NAME)); // name
		skip(Operators.SEMI, result); // ;
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseMetaData():Node
	{
		var result:TokenNode = ASTUtil.newBracketAST(
			AS3NodeKind.META, token) as TokenNode;
		
		addAsDoc(result); // '/**'
		
		consumeWS(Operators.LBRACK, result); // '['
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		nextTokenConsume(result); // name
		
		if (tokIs(Operators.LPAREN)) // '('
		{
			result.addChild(parseMetaDataParameterList())
		}
		
		consumeWS(Operators.RBRACK, result, false); // ']'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseMetaDataParameterList():Node
	{
		var result:TokenNode = ASTUtil.newParenAST(
			AS3NodeKind.PARAMETER_LIST, token) as TokenNode;
		
		consumeWS(Operators.LPAREN, result);
		
		while (!tokIs(Operators.RPAREN))
		{
			result.addChild(parseMetaDataParameter());
			if (tokIs(Operators.COMMA))
			{
				consume(Operators.COMMA, result);
			}
			else
			{
				break;
			}
		}
		
		consumeWS(Operators.RPAREN, result, false);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseMetaDataParameter():Node
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.PARAMETER, token);
		
		var nameOrValue:TokenNode = adapter.copy(AS3NodeKind.NAME, token);
		result.addChild(nameOrValue);
		
		nextTokenConsume(result); // = or , or ]
		
		if (tokIs(Operators.ASSIGN))
		{
			consume(Operators.ASSIGN, result);
			result.addChild(parseExpression());
		}
		else
		{
			nameOrValue.kind = AS3NodeKind.VALUE;
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseImplementsList():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.IMPLEMENTS, token);
		
		consume(KeyWords.IMPLEMENTS, result);
		
		result.addChild(parseTypeSpec(AS3NodeKind.TYPE));
		
		while (tokIs(Operators.COMMA))
		{
			consume(Operators.COMMA, result);
			result.addChild(parseTypeSpec(AS3NodeKind.TYPE));
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseExtendsList():TokenNode
	{
		var result:TokenNode = adapter.empty(
			AS3NodeKind.EXTENDS, token);
		
		consume(KeyWords.EXTENDS, result);
		
		result.addChild(parseTypeSpec(AS3NodeKind.TYPE));
		
		while (tokIs(Operators.COMMA))
		{
			consume(Operators.COMMA, result);
			result.addChild(parseTypeSpec(AS3NodeKind.TYPE));
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseClassField(result:TokenNode):TokenNode
	{
		var mod:LinkedListToken = findToken(result.token, AS3NodeKind.MODIFIER);
		if (mod)
		{
			result.line = mod.line;
			result.column = mod.column;
		}
		result = parseFieldList(result);
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseClassConstant(result:TokenNode):TokenNode
	{
		var mod:LinkedListToken = findToken(result.token, AS3NodeKind.MODIFIER);
		if (mod)
		{
			result.line = mod.line;
			result.column = mod.column;
		}
		result = parseFieldList(result);
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseClassFunction(result:TokenNode):TokenNode
	{
		if (!result)
		{
			result = adapter.copy(AS3NodeKind.FUNCTION, token);
		}
		
		result.kind = AS3NodeKind.FUNCTION;
		var mod:LinkedListToken = findToken(result.token, AS3NodeKind.MODIFIER);
		if (mod)
		{
			result.line = mod.line;
			result.column = mod.column;
		}
		
		consume(KeyWords.FUNCTION, result);
		parseFunction(result);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseClassNamespace(result:TokenNode):TokenNode
	{
		if (!result)
		{
			result = adapter.copy(AS3NodeKind.NAMESPACE, token);
		}
		
		result.kind = AS3NodeKind.NAMESPACE;
		var mod:LinkedListToken = findToken(result.token, AS3NodeKind.MODIFIER);
		if (mod)
		{
			result.line = mod.line;
			result.column = mod.column;
		}
		
		consume(KeyWords.NAMESPACE, result); // 'namespace'
		result.addChild(adapter.copy(AS3NodeKind.NAME, token)); // 'name'
		nextTokenConsume(result);
		if (tokIs(Operators.ASSIGN))
		{
			consume(Operators.ASSIGN, result); // =
			var value:TokenNode = adapter.empty(AS3NodeKind.VALUE, token);
			value.addChild(parseExpression());
			result.addChild(value);
		}
		
		skip(Operators.SEMI);
		
		return result;
	}
	
	private function parseConfig():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.CONFIG, token);
		consume(KeyWords.CONFIG, result);
		consume(Operators.DBL_COLON, result);
		result.addChild(parseName());
		consumeWhitespace(result);
		result.addChild(parseBlock());
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseDecList():IParserNode
	{
		return parseVar();
	}
	
	/**
	 * @private
	 */
	private function parseDeclarationList(result:TokenNode):TokenNode
	{
		if (!result)
		{
			result = adapter.empty(AS3NodeKind.DEC_LIST, token);
		}
		else
		{
			result.kind = AS3NodeKind.DEC_LIST;
		}
		
		var role:TokenNode = adapter.empty(AS3NodeKind.DEC_ROLE, token);
		result.addChild(role);
		
		if (tokIs(KeyWords.VAR) || tokIs(KeyWords.CONST))
		{
			role.addChild(adapter.empty(token.text, token));
			consume(token.text, role);
		}
		
		collectVarListContent(result);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseFieldList(result:TokenNode):TokenNode
	{
		if (!result)
		{
			result = adapter.empty(AS3NodeKind.FIELD_LIST, token);
		}
		else
		{
			result.kind = AS3NodeKind.FIELD_LIST;
		}
		
		var role:TokenNode = adapter.empty(AS3NodeKind.FIELD_ROLE, token);
		result.addChild(role);
		
		if (tokIs(KeyWords.VAR) || tokIs(KeyWords.CONST))
		{
			role.addChild(adapter.empty(token.text, token));
			consume(token.text, role);
		}
		
		collectVarListContent(result);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function collectVarListContent(result:TokenNode):TokenNode
	{
		do
		{
			if (tokIs(Operators.COMMA))
			{
				consume(Operators.COMMA, result);
			}
			result.addChild(parseNameTypeInit());
		}
		while (tokIs(Operators.COMMA))
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseNameTypeInit():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.NAME_TYPE_INIT, token);
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		
		nextTokenConsume(result); // name
		if (tokIs(Operators.COLON))
		{
			result.addChild(parseOptionalType(result));
			if (!tokIs(Operators.ASSIGN))
			{
				if (tokIs(Operators.SEMI))
				{
					skip(Operators.SEMI, result);
				}
					// FIXME 
				else if (!tokIs(Operators.COMMA)
					&& !tokIs(Operators.RPAREN))
				{
					nextTokenConsume(result);
				}
				//nextTokenConsume(result);
			}
			else
			{
				skip(Operators.SEMI, result);
			}
		}
		
		if (tokIs(Operators.ASSIGN))
		{
			result.addChild(parseOptionalInit(result));
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseOptionalType(node:TokenNode):TokenNode
	{
		var result:TokenNode;
		
		if (tokIs(Operators.COLON))
		{		
			consume(Operators.COLON, node);
			result = parseType() as TokenNode;
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseType():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.TYPE, token);
		
		if (token.text == VECTOR)
		{
			result = parseVector();
		}
		else
		{
			result.stringValue = parseQualifiedName();
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseName():IParserNode
	{
		var result:TokenNode = adapter.create(
			AS3NodeKind.NAME, parseQualifiedName());
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseVector():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.VECTOR, token);
		consume("Vector", result);
		consume(Operators.VECTOR_START, result);
		result.addChild(parseType());
		consume(Operators.GT, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseOptionalInit(node:TokenNode):TokenNode
	{
		var result:TokenNode = null;
		if (tokIs(Operators.ASSIGN))
		{
			consume(Operators.ASSIGN, node);
			result = adapter.empty(AS3NodeKind.INIT, token);
			result.addChild(parseExpression());
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function findToken(token:LinkedListToken, kind:String):LinkedListToken
	{
		var next:LinkedListToken = token;
		while (next)
		{
			if (next.kind == kind)
				return next;
			
			next = next.next;
		}
		return null;
	}
	
	private function parseFunction(result:TokenNode):TokenNode
	{
		result.kind = AS3NodeKind.FUNCTION;
		
		var role:TokenNode = adapter.empty(AS3NodeKind.ACCESSOR_ROLE, token);
		result.addChild(role);
		
		// function role
		if (tokIs(KeyWords.GET) || tokIs(KeyWords.SET))
		{
			role.addChild(adapter.empty(token.text, token));
			consume(token.text, role);
		}
		
		// function name
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		
		nextTokenConsume(result); // should be (
		
		// function parameters
		result.addChild(parseParameterList());
		
		// tokens between the ) and possible :
		consumeWhitespace(result); // spaces, tabs
		
		// has type, should be a colon
		if (tokIs(Operators.COLON))
		{
			result.addChild(parseOptionalType(result));
			consumeWhitespace(result);
		}
		
		// interface function; return
		if (!tokIs(Operators.LCURLY) || tokIs(Operators.SEMI))
		{
			skip(Operators.SEMI, result);
			return result;
		}
		
		if (!tokIs(Operators.LCURLY))
		{
			// {
			nextTokenConsume(result);
		}
		
		result.addChild(parseBlock());
		
		// if not a package function, need this to exit package content
		if (!tokIs(Operators.RCURLY))
		{
			nextTokenConsume(result);
		}
		
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Expression :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function parseExpression():IParserNode
	{
		return parseAssignmentExpression();
	}
	
	/**
	 * @private (13)
	 */
	private function parseAssignmentExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(
			AS3NodeKind.ASSIGNMENT, token);
		
		result.addChild(parseConditionalExpression());
		while (tokIs(Operators.ASSIGN) || tokIs(Operators.STAR_ASSIGN)
			|| tokIs(Operators.DIV_ASSIGN) || tokIs(Operators.MOD_ASSIGN)
			|| tokIs(Operators.PLUS_ASSIGN) || tokIs(Operators.MINUS_ASSIGN)
			|| tokIs(Operators.SL_ASSIGN) || tokIs(Operators.SR_ASSIGN) 
			|| tokIs(Operators.BSR_ASSIGN) || tokIs(Operators.BAND_ASSIGN)
			|| tokIs(Operators.BXOR_ASSIGN) || tokIs(Operators.BOR_ASSIGN)
			|| tokIs(Operators.LAND_ASSIGN) || tokIs(Operators.LOR_ASSIGN))
		{
			result.addChild(adapter.copy(AS3ParserMap.assignment.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (12)
	 */
	private function parseConditionalExpression():TokenNode
	{
		var result:TokenNode = parseOrExpression() as TokenNode;
		if (tokIs(Operators.QUESTION))
		{
			var conditional:TokenNode = adapter.empty(
				AS3NodeKind.CONDITIONAL, token);
			conditional.addChild(result);
			consume(Operators.QUESTION, conditional);
			conditional.addChild(parseExpression());
			consume(Operators.COLON, conditional);
			conditional.addChild(parseExpression());
			return conditional;
		}
		return result;
	}
	
	/**
	 * @private (11)
	 */
	private function parseOrExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.OR, token);
		result.addChild(parseAndExpression());
		while (tokIs(Operators.LOR))
		{
			result.addChild(adapter.copy(AS3NodeKind.LOR, token));
			nextTokenConsume(result);
			result.addChild(parseAndExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (10)
	 */
	private function parseAndExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.AND, token);
		result.addChild(parseBitwiseOrExpression());
		while (tokIs(Operators.LAND))
		{
			result.addChild(adapter.copy(AS3NodeKind.LAND, token));
			nextTokenConsume(result);
			result.addChild(parseBitwiseOrExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (9)
	 */
	private function parseBitwiseOrExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.B_OR, token);
		result.addChild(parseBitwiseXorExpression());
		while (tokIs(Operators.BOR))
		{
			result.addChild(adapter.copy(AS3NodeKind.BOR, token));
			nextTokenConsume(result);
			result.addChild(parseBitwiseXorExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (8)
	 */
	private function parseBitwiseXorExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.B_XOR, token);
		result.addChild(parseBitwiseAndExpression());
		while (tokIs(Operators.BXOR))
		{
			result.addChild(adapter.copy(AS3NodeKind.BXOR, token));
			nextTokenConsume(result);
			result.addChild(parseBitwiseAndExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (7)
	 */
	private function parseBitwiseAndExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.B_AND, token);
		result.addChild(parseEqualityExpression());
		while (tokIs(Operators.BAND))
		{
			result.addChild(adapter.copy(AS3NodeKind.BAND, token));
			nextTokenConsume(result);
			result.addChild(parseEqualityExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (6)
	 */
	private function parseEqualityExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.EQUALITY, token);
		result.addChild(parseRelationalExpression());
		while (tokIs(Operators.EQUAL) || tokIs(Operators.NOT_EQUAL)
			|| tokIs(Operators.STRICT_EQUAL) || tokIs(Operators.STRICT_NOT_EQUAL))
		{
			result.addChild(adapter.copy(AS3ParserMap.equality.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseRelationalExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (5)
	 */
	private function parseRelationalExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.RELATIONAL, token);
		result.addChild(parseShiftExpression());
		while (!isInFor && tokIs(KeyWords.IN) 
			|| tokIs(Operators.LT) || tokIs(Operators.GT)
			|| tokIs(Operators.LE) || tokIs(Operators.GE)
			|| tokIs(KeyWords.IS) || tokIs(KeyWords.AS) 
			|| tokIs(KeyWords.INSTANCE_OF))
		{
			result.addChild(adapter.copy(AS3ParserMap.relation.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseShiftExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (4)
	 */
	private function parseShiftExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.SHIFT, token);
		result.addChild(parseAdditiveExpression());
		while (tokIs(Operators.SL) || tokIs(Operators.SR)
			|| tokIs(Operators.SSL) || tokIs(Operators.BSR))
		{
			result.addChild(adapter.copy(AS3ParserMap.shift.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseAdditiveExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (3)
	 */
	private function parseAdditiveExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.ADDITIVE, token);
		result.addChild(parseMultiplicativeExpression());
		while (tokIs(Operators.PLUS) || tokIs(Operators.MINUS))
		{
			result.addChild(adapter.copy(AS3ParserMap.additive.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseMultiplicativeExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (2)
	 */
	private function parseMultiplicativeExpression():IParserNode
	{
		var result:TokenNode = adapter.empty(
			AS3NodeKind.MULTIPLICATIVE, token);
		result.addChild(parseUnaryExpression(result));
		
		while (tokIs(Operators.STAR)
			|| tokIs(Operators.DIV) 
			|| tokIs(Operators.MOD))
		{
			result.addChild(adapter.copy(AS3ParserMap.multiplicative.getValue(token.text), token));
			nextTokenConsume(result);
			result.addChild(parseUnaryExpression(result));
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	/**
	 * @private (1)
	 */
	internal function parseUnaryExpression(node:TokenNode):IParserNode
	{
		var result:TokenNode;
		var line:int = token.line;
		var column:int = token.column;
		
		if (tokIs(Operators.INC))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.PRE_INC,
				Operators.INC, 
				token.line, 
				token.column);
			result.addChild(parseUnaryExpression(node));
		}
		else if (tokIs(Operators.DEC))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.PRE_DEC,
				Operators.DEC, 
				line, 
				column);
			result.addChild(parseUnaryExpression(node));
		}
		else if (tokIs(Operators.MINUS))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.MINUS,
				Operators.MINUS, 
				token.line, 
				token.column);
			result.addChild(parseUnaryExpression(node));
		}
		else if (tokIs(Operators.PLUS))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.PLUS,
				Operators.PLUS, 
				token.line, 
				token.column);
			result.addChild(parseUnaryExpression(node));
		}
		else
		{
			result = parseUnaryExpressionNotPlusMinus(node);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseUnaryExpressionNotPlusMinus(node:TokenNode):TokenNode
	{
		var result:TokenNode;
		if (tokIs(KeyWords.DELETE))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.DELETE,
				KeyWords.DELETE, 
				token.line, 
				token.column);
			result.addChild(parseExpression());
		}
		else if (tokIs(KeyWords.VOID))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.VOID,
				KeyWords.VOID, 
				token.line, 
				token.column);
			result.addChild(parseExpression());
		}
		else if (tokIs(KeyWords.TYPEOF))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.TYPEOF,
				KeyWords.TYPEOF, 
				token.line, 
				token.column);
			result.addChild(parseExpression());
		}
		else if (tokIs(Operators.LNOT))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.NOT,
				Operators.LNOT, 
				token.line, 
				token.column);
			result.addChild(parseExpression());
		}
		else if (tokIs(Operators.BNOT))
		{
			nextTokenConsume(node);
			result = adapter.create(
				AS3NodeKind.B_NOT,
				Operators.BNOT, 
				token.line, 
				token.column);
			result.addChild(parseExpression());
		}
		else
		{
			result = parseUnaryPostfixExpression(node);
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parsePrimaryExpression():TokenNode
	{
		// this would be just a simple name IE 'foo' that means nothing
		// to the parser
		var result:TokenNode = adapter.empty(AS3NodeKind.PRIMARY, token);
		
		if (tokIs(Operators.LBRACK))
		{
			return parseArrayLiteral(); // [a,b,c]
		}
		else if (tokIs(Operators.LCURLY))
		{
			return parseObjectLiteral(); // {foo:bar}
		}
		else if (tokIs(KeyWords.FUNCTION))
		{
			return parseLambdaExpression(); // function():void{}
		}
		else if (tokIs(KeyWords.NEW))
		{
			return parseNewExpression(); // new Type()
		}
		else if (tokIs(Operators.LPAREN))
		{
			return parseEncapsulatedExpression(); // (foo)
		}
		else
		{
			if (token.text.indexOf(Operators.QUOTE) == 0 
				|| token.text.indexOf(Operators.SQUOTE) == 0)
			{
				result.kind = AS3NodeKind.STRING; // '' | ""
			}
			else if (!isNaN(parseInt(token.text)) 
				|| !isNaN(parseFloat(token.text))
				|| tokIs(KeyWords.NAN))
			{
				result.kind = AS3NodeKind.NUMBER; // 42, 0.42, NaN
			}
			else if (token.text.indexOf(Operators.DIV) == 0)
			{
				result.kind = AS3NodeKind.REG_EXP; // /.*/
			}
			else if (token.text.indexOf(Operators.LT) == 0)
			{
				result.kind = AS3NodeKind.XML; // <foo></foo>
			}
			else
			{
				if (tokIs(KeyWords.TRUE))
				{
					result.kind = AS3NodeKind.TRUE; // true
				}
				else if (tokIs(KeyWords.FALSE))
				{
					result.kind = AS3NodeKind.FALSE; // false
				}
				else if (tokIs(KeyWords.NULL))
				{
					result.kind = AS3NodeKind.NULL; // null
				}
				else if (tokIs(KeyWords.UNDEFINED))
				{
					result.kind = AS3NodeKind.UNDEFINED; // undefined
				}
			}
			
			result.stringValue = token.text;
			result.token.text = token.text;
			
			nextTokenConsume(result);
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseArrayLiteral():TokenNode
	{
		var result:TokenNode = ASTUtil.
			newBracketAST(AS3NodeKind.ARRAY, token) as TokenNode;
		consumeParenthetic(Operators.LBRACK); // '['
		while (!tokIs(Operators.RBRACK)) // ']'
		{
			consumeWhitespace(result); // '.*'
			result.addChild(parseExpression()); // expression
			skip(Operators.COMMA, result); // '.*,.*'
		}
		consumeParenthetic(Operators.RBRACK); // ']'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseObjectLiteral():TokenNode
	{
		var result:TokenNode = ASTUtil.
			newCurlyAST(AS3NodeKind.OBJECT, token) as TokenNode;
		consumeParenthetic(Operators.LCURLY); // '{'
		while (!tokIs(Operators.RCURLY)) // '}'
		{
			consumeWhitespace(result); // '.*'
			result.addChild(parseObjectLiteralPropertyDeclaration()); // 'a:b'
			skip(Operators.COMMA, result); // ','
		}
		consumeParenthetic(Operators.RCURLY); // '}'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseObjectLiteralPropertyDeclaration():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.PROP, token);
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		nextTokenConsume(result); // '.*name'
		consume(Operators.COLON, result); // '.*:.*'
		var value:TokenNode = adapter.empty(AS3NodeKind.VALUE, token);
		result.addChild(value);
		value.addChild(parseExpression()); // expression
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseLambdaExpression():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.LAMBDA, token);
		consume(KeyWords.FUNCTION, result); // '.*function.*'
		result.addChild(parseParameterList()); // '(...)'
		consumeWhitespace(result);
		if (tokIs(Operators.COLON))
		{
			result.addChild(parseOptionalType(result)); // ':Type'
		}
		consumeWhitespace(result);
		result.addChild(parseBlock()); // '{'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseThisStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.THIS, token);
		consume(KeyWords.THIS, result); // 'this'
		if (tokIs(Operators.DOT))
		{
			consume(Operators.DOT, result); // .*'.'.*
			result.addChild(parseExpression()); // expression
			skip(Operators.SEMI, result); // .*';'.*
			return result;
		}
		skip(Operators.SEMI, result); // .*';'.*
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseSuperStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.SUPER, token);
		consume(KeyWords.SUPER, result); // 'super'
		if (tokIs(Operators.DOT))
		{
			consume(Operators.DOT, result); // '.'
			result.addChild(parseExpression()); // expression
			skip(Operators.SEMI, result); // ';'
			return result;
		}
		else
		{
			var callAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.CALL);
			callAST.addChild(ASTBuilder.newPrimaryAST(null));
			callAST.addChild(parseArgumentList()); // '(...)'
			result.addChild(callAST);
		}
		skip(Operators.SEMI, result); // ';'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseThrowStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.THROW, token);
		consume(KeyWords.THROW, result); // .*'throw'.*
		result.addChild(parseExpression()); // expression
		skip(Operators.SEMI, result); // .*';'.*
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseDefaultXMLNamespaceStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.DF_XML_NS, token);
		consume(KeyWords.DEFAULT, result); // 'default'
		consume(KeyWords.XML, result); // 'xml'
		consume(KeyWords.NAMESPACE, result); // 'namepsace'
		consume(Operators.ASSIGN, result); // '='
		result.addChild(parseExpression()); // expression
		skip(Operators.SEMI, result); // ';'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseNewExpression():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.NEW, token);
		consume(KeyWords.NEW, result); // 'new'
		// new calls are not required to have () argument list
		if (tokIs("Vector"))
		{
			// have to mimic how this would be packaged by an expression
			var callAST:IParserNode = adapter.empty(AS3NodeKind.CALL, token);
			callAST.addChild(parseVector());
			if (tokIs(Operators.LPAREN))
			{
				callAST.addChild(parseArgumentList());
			}
			result.addChild(callAST); // call/Vector.<T> || Vector.<Vector.<T>>
		}
		else
		{
			// the expression parse will resolve this to a call
			result.addChild(parseExpression()); // call/expression
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseEncapsulatedExpression():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.ENCAPSULATED, token);
		consume(Operators.LPAREN, result); // '('
		result.addChild(parseExpressionList()); // expression list (w/comma)
		consume(Operators.RPAREN, result); // ')'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseArgumentList():TokenNode
	{
		var result:TokenNode = ASTUtil.
			newParenAST(AS3NodeKind.ARGUMENTS, token) as TokenNode;
		consumeParenthetic(Operators.LPAREN); // '('
		consumeWhitespace(result);
		while (!tokIs(Operators.RPAREN))
		{
			result.addChild(parseExpression()); // expression
			skip(Operators.COMMA, result); // ','
		}
		consumeWhitespace(result);
		consumeParenthetic(Operators.RPAREN); // ')'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseParameterList():TokenNode
	{
		var result:TokenNode = ASTUtil.
			newParenAST(AS3NodeKind.PARAMETER_LIST, token) as TokenNode;
		consumeParenthetic(Operators.LPAREN); // '('
		consumeWhitespace(result);
		while (!tokIs(Operators.RPAREN))
		{
			result.addChild(parseParameter()); // 'name:type=init' | '...rest'
			skip(Operators.COMMA, result); // '.*,.*'
		}
		consumeWhitespace(result);
		consumeParenthetic(Operators.RPAREN, result); // ')'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseParameter():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.PARAMETER, token);
		if (tokIs(Operators.REST))
		{
			consume(Operators.REST, result); // '...'
			result.addChild(adapter.copy(AS3NodeKind.REST, token));
			nextTokenConsume(result);
		}
		else
		{
			result.addChild(parseNameTypeInit());
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseUnaryPostfixExpression(node:TokenNode):TokenNode
	{
		var result:TokenNode = parsePrimaryExpression();
		
		if (tokIs(Operators.LBRACK))
		{
			result = parseArrayAccessor(result);
		}
		else if (tokIs(Operators.LPAREN))
		{
			result = parseFunctionCall(result);
		}
		if (tokIs(Operators.INC))
		{
			result = parseIncrement(result);
		}
		else if (tokIs(Operators.DEC))
		{
			result = parseDecrement(result);
		}
		else if (tokIs(Operators.DOT)
			|| tokIs(Operators.DBL_COLON)
			|| tokIs(Operators.E4X_DESC))
		{
			result = parseDot(result);
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseArrayAccessor(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.ARRAY_ACCESSOR, token);
		result.addChild(node);
		while (tokIs(Operators.LBRACK))
		{
			consume(Operators.LBRACK, result); // [
			result.addChild(parseExpression());
			consume(Operators.RBRACK, result);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseFunctionCall(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.CALL, token);
		result.addChild(node);
		while (tokIs(Operators.LPAREN))
		{
			result.addChild(parseArgumentList());
			consumeWhitespace(result);
		}
		while (tokIs(Operators.LBRACK))
		{
			result.addChild(parseArrayLiteral());
			consumeWhitespace(result);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseIncrement(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.POST_INC, token);
		result.addChild(node);
		consume(Operators.INC, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseDecrement(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.POST_DEC, token);
		result.addChild(node);
		consume(Operators.DEC, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseLabel(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.LABEL, token);
		result.addChild(node);
		consume(Operators.COLON, result);
		result.addChild(parseStatement());
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseDot(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.DOT, token);
		result.addChild(node);
		if (tokIs(Operators.E4X_DESC))
		{
			result = adapter.empty(AS3NodeKind.E4X_DESCENDENT, token);
			result.addChild(node);
			consume(Operators.E4X_DESC, result);
			result.addChild(parseExpression());
			return result;
		}
		
		if (tokIs(Operators.DOT))
		{
			consume(Operators.DOT, result);
		}
		else if (tokIs(Operators.DBL_COLON))
		{
			consume(Operators.DBL_COLON, result);
			result.kind = AS3NodeKind.DOUBLE_COLUMN;
		}
		
		if (tokIs(Operators.LPAREN))
		{
			result = ASTUtil.newParenAST(AS3NodeKind.E4X_FILTER, token) as TokenNode;
			consumeWS(Operators.LPAREN, result);
			result.addChild(node);
			result.addChild(parseExpression());
			consumeWS(Operators.RPAREN, result);
			return result;
		}
		else if (tokIs(Operators.STAR))
		{
			result = adapter.empty(AS3NodeKind.E4X_STAR, token);
			result.addChild(node);
			return result;
		}
		else if (tokIs(Operators.E4X_ATTRI))
		{
			result.addChild(parseE4XAttributeIdentifier());
			return result;
		}
		
		result.addChild(parseExpression());
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseE4XAttributeIdentifier():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.E4X_ATTR, token);
		consume(Operators.E4X_ATTRI, result);
		
		if (tokIs(Operators.LBRACK))
		{
			nextTokenConsume(result);
			result.addChild(parseExpression());
			consume(Operators.RBRACK, result);
		}
		else if (tokIs(Operators.STAR))
		{
			result.addChild(adapter.copy(AS3NodeKind.STAR, token));
			consumeWS(Operators.STAR, result);
		}
		else
		{
			result.addChild(adapter.copy(AS3NodeKind.NAME, token));
		}
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseBlock():IParserNode
	{
		var result:TokenNode = ASTUtil.newCurlyAST(
			AS3NodeKind.BLOCK, token) as TokenNode;
		
		consumeParenthetic(Operators.LCURLY);
		consumeWhitespace(result);
		
		ISourceCodeScanner(scanner).inBlock = true;
		
		if (parseBlocks)
		{
			while (!tokIs(Operators.RCURLY))
			{
				result.addChild(parseStatement());
			}
		}
		else
		{
			braceCount = 1;
			
			while (braceCount != 0)
			{
				if (tokIs(Operators.LCURLY))
				{
					braceCount++;
				}
				if (tokIs(Operators.RCURLY))
				{
					braceCount--;
				}
				
				if (braceCount == 0)
				{
					break;
				}
				
				nextTokenConsume(result);
			}
		}
		
		consumeWhitespace(result);
		consumeParenthetic(Operators.RCURLY);
		
		ISourceCodeScanner(scanner).inBlock = false;
		
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseExpressionList():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.EXPR_LIST, token);
		result.addChild(parseAssignmentExpression());
		while (tokIs(Operators.COMMA))
		{
			nextTokenConsume(result);
			result.addChild(parseAssignmentExpression());
		}
		return result.numChildren > 1 ? result : result.getChild(0);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Statement :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	internal function parseStatement():IParserNode
	{
		var result:TokenNode;
		
		if (tokIs(KeyWords.FOR))
		{
			result = parseFor();
		}
		else if (tokIs(KeyWords.IF))
		{
			result = parseIf();
		}
		else if (tokIs(KeyWords.SWITCH))
		{
			result = parseSwitch();
		}
		else if (tokIs(KeyWords.DO))
		{
			result = parseDo();
		}
		else if (tokIs(KeyWords.WITH))
		{
			result = parseWith();
		}
		else if (tokIs(KeyWords.WHILE))
		{
			result = parseWhile();
		}
		else if (tokIs(KeyWords.TRY))
		{
			result = parseTryStatement();
		}
		else if (tokIs(KeyWords.CONFIG))
		{
			result = parseConfig();
		}
		else if (tokIs(Operators.LCURLY))
		{
			result = parseBlock() as TokenNode;
		}
		else if (tokIs(KeyWords.VAR))
		{
			result = parseVar();
		}
		else if (tokIs(KeyWords.CONST))
		{
			result = parseConst();
		}
		else if (tokIs(KeyWords.RETURN))
		{
			result = parseReturnStatement();
		}
		else if (tokIs(KeyWords.THIS))
		{
			result = parseThisStatement();
		}
		else if (tokIs(KeyWords.SUPER))
		{
			result = parseSuperStatement();
		}
		else if (tokIs(KeyWords.THROW))
		{
			result = parseThrowStatement();
		}
		else if (tokIs(KeyWords.DEFAULT))
		{
			result = parseDefaultXMLNamespaceStatement();
		}
		else if (tokIs(KeyWords.BREAK))
		{
			result = parseBreakStatement();
		}
		else if (tokIs(KeyWords.CONTINUE))
		{
			result = parseContinueStatement();
		}
		else if (tokIs(Operators.COLON))
		{
			result = parseLabel(null);
		}
		else if (tokIs(Operators.SEMI))
		{
			result = parseEmptyStatement();
		}
		else
		{
			result = parseExpressionStatement() as TokenNode;
			if (tokIs(Operators.COLON))
			{
				result = parseLabel(result);
			}
			else
			{
				skip(Operators.SEMI, result);
			}
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseFor():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.FOR, token);
		consume(KeyWords.FOR, result);
		if (tokIs(KeyWords.EACH))
		{
			consume(KeyWords.EACH, result);
			return parseForEach(result);
		}
		else
		{
			return parseTraditionalFor(result);
		}
	}
	
	/**
	 * @private
	 */
	private function parseTraditionalFor(node:TokenNode):TokenNode
	{
		consume(Operators.LPAREN, node);
		
		var result:TokenNode;
		
		if (!tokIs(Operators.SEMI))
		{
			result = parseForInit() as TokenNode;
			if (result)
			{
				node.addChild(result);
			}
			if (tokIs(AS3NodeKind.IN))
			{
				result = parseForIn(node);
				result.kind = node.kind = AS3NodeKind.FORIN;
				return result;
			}
		}
		consume(Operators.SEMI, node);
		if (!tokIs(Operators.SEMI))
		{
			node.addChild(parseForCond());
		}
		consume(Operators.SEMI, node);
		if (!tokIs(Operators.RPAREN))
		{
			node.addChild(parseForIter());
		}
		consume(Operators.RPAREN, node);
		node.addChild(parseStatement());
		node.kind = AS3NodeKind.FOR;
		return node;
	}
	
	/**
	 * @private
	 */
	private function parseForEach(node:TokenNode):TokenNode
	{
		consume(Operators.LPAREN, node);
		
		node.addChild(parseForInit());
		
		var ini:TokenNode = adapter.empty(AS3NodeKind.IN, token);
		
		consume(KeyWords.IN, node);
		ini.addChild(parseExpression());
		node.addChild(ini);
		
		consume(Operators.RPAREN, node);
		node.addChild(parseStatement());
		node.kind = AS3NodeKind.FOREACH;
		return node;
	}
	
	/**
	 * @private
	 */
	private function parseForIn(node:TokenNode):TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.IN, token);
		consume(KeyWords.IN, result);
		result.addChild(parseExpression());
		node.addChild(result);
		consume(Operators.RPAREN, result);
		node.addChild(parseStatement());
		return node;
	}
	
	/**
	 * @private
	 */
	internal function parseForInit():IParserNode
	{
		var result:IParserNode = adapter.empty(AS3NodeKind.INIT, token);
		
		if (tokIs(KeyWords.VAR))
		{
			result.addChild(parseDeclarationList(null));
		}
		else
		{
			isInFor = true;
			result.addChild(parseExpression());
			isInFor = false;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseForCond():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.COND, token);
		result.addChild(parseExpression());
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseForIter():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.ITER, token);
		result.addChild(parseExpressionList());
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseIf():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.IF, token);
		
		consume(KeyWords.IF, result);
		result.addChild(parseCondition());
		consumeWhitespace(result);
		result.addChild(parseStatement());
		consumeWhitespace(result);
		if (tokIs(KeyWords.ELSE))
		{
			var eresult:TokenNode = adapter.empty(AS3NodeKind.ELSE, token);
			consume(KeyWords.ELSE, eresult);
			eresult.addChild(parseStatement());
			result.addChild(eresult);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	internal function parseCondition():IParserNode
	{
		var result:TokenNode = ASTUtil.newParenAST(
			AS3NodeKind.CONDITION, token) as TokenNode;
		
		consumeWS(Operators.LPAREN, result);
		result.addChild(parseExpression());
		consumeWS(Operators.RPAREN, result, false);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseEmptyStatement():TokenNode
	{
		var result:TokenNode = adapter.create(
			AS3NodeKind.STMT_EMPTY,
			Operators.SEMI, 
			token.line, 
			token.column);
		
		consume(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseReturnStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(
			AS3NodeKind.RETURN, token);
		
		consume(KeyWords.RETURN, result);
		if (tokIs(NEW_LINE) || tokIs(Operators.SEMI))
		{
			result.stringValue = "";
			result.token.text = "";
		}
		else
		{
			result.addChild(parseExpression());
		}
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseBreakStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.BREAK, token);
		consume(KeyWords.BREAK, result);
		if (!tokIs(Operators.SEMI))
		{
			result.addChild(parseExpression());
		}
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseContinueStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.CONTINUE, token);
		consume(KeyWords.CONTINUE, result);
		if (!tokIs(Operators.SEMI))
		{
			result.addChild(parseExpression());
		}
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseSwitch():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.SWITCH, token);
		
		consume(KeyWords.SWITCH, result);
		
		result.addChild(parseCondition());
		consumeWhitespace(result);
		result.addChild(parseSwitchCases());
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseSwitchCases():TokenNode
	{
		if (!tokIs(Operators.LCURLY))
		{
			return null;
		}
		
		var caseNode:TokenNode;
		
		var result:TokenNode = ASTUtil.newCurlyAST(
			AS3NodeKind.CASES, token) as TokenNode;
		
		consumeWS(Operators.LCURLY, result, true);
		
		for (;;)
		{
			if (tokIs(KeyWords.CASE))
			{
				caseNode = adapter.create(
					AS3NodeKind.CASE,
					null, 
					token.line, 
					token.column);
				
				consume(KeyWords.CASE, result);
				caseNode.addChild(parseExpression());
				
				consume(Operators.COLON, caseNode);
				
				caseNode.addChild(parseSwitchBlock());
				
				result.addChild(caseNode);
			}
			else if (tokIs(KeyWords.DEFAULT))
			{
				caseNode = adapter.create(
					AS3NodeKind.CASE,
					null, 
					token.line, 
					token.column);
				
				caseNode.addChild(
					adapter.create(
						AS3NodeKind.DEFAULT,
						null, 
						token.line, 
						token.column));
				
				consume(KeyWords.DEFAULT, result);
				consume(Operators.COLON, result);
				
				caseNode.addChild(parseSwitchBlock());
				
				result.addChild(caseNode);
			}
			else if (tokIs(Operators.RCURLY))
			{
				break;
			}
		}
		
		consumeWS(Operators.RCURLY, result);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseSwitchBlock():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.SWITCH_BLOCK, token);
		while (!tokIs(KeyWords.CASE)
			&& !tokIs(KeyWords.DEFAULT) 
			&& !tokIs(Operators.RCURLY))
		{
			result.addChild(parseStatement()); // statement
			consumeWhitespace(result);
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseDo():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.DO, token);
		consume(KeyWords.DO, result); // 'do'
		result.addChild(parseStatement()); // statement
		consume(KeyWords.WHILE, result); // 'while'
		result.addChild(parseCondition()); // '(...)'
		skip(Operators.SEMI, result); // ';'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseWith():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.WITH, token);
		consume(KeyWords.WITH, result); // 'with'
		result.addChild(parseCondition()); // '(...)'
		consumeWhitespace(result);
		result.addChild(parseStatement()); // statement
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseWhile():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.WHILE, token);
		consume(KeyWords.WHILE, result); // 'while'
		result.addChild(parseCondition()); // '(...)'
		consumeWhitespace(result);
		result.addChild(parseStatement()); // statement
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseTryStatement():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.TRY_STMNT, token);
		result.addChild(parseTry()); // 'try {...}'
		consumeWhitespace(result);
		if (tokIs(KeyWords.CATCH))
		{
			while (tokIs(KeyWords.CATCH))
			{
				result.addChild(parseCatch()); // 'catch (e:Type) {...}'
				consumeWhitespace(result);
			}
		}
		consumeWhitespace(result);
		if (tokIs(KeyWords.FINALLY))
		{
			result.addChild(parseFinally()); // 'finally {...}'
		}
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseTry():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.TRY, token);
		consume(KeyWords.TRY, result); // 'try'
		result.addChild(parseBlock()); // '{...}'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseCatch():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.CATCH, token);
		consume(KeyWords.CATCH, result); // 'catch'
		consume(Operators.LPAREN, result); // '('
		result.addChild(adapter.copy(AS3NodeKind.NAME, token));		
		nextTokenConsume(result); // name
		if (tokIs(Operators.COLON))
		{
			consume(Operators.COLON, result); // ':'
			result.addChild(adapter.copy(AS3NodeKind.TYPE, token));	// type
			nextTokenConsume(result); // type
		}
		consume(Operators.RPAREN, result); // ')'
		result.addChild(parseBlock()); // '{...}'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseFinally():TokenNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.FINALLY, token);
		consume(KeyWords.FINALLY, result); // 'finally'
		result.addChild(parseBlock()); // '{...}'
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseVar():TokenNode
	{
		var result:TokenNode = parseDeclarationList(null);
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseConst():TokenNode
	{
		var result:TokenNode = parseDeclarationList(null);
		skip(Operators.SEMI, result);
		return result;
	}
	
	/**
	 * @private
	 */
	private function parseASdoc():TokenNode
	{
		var sc:ISourceCodeScanner = ISourceCodeScanner(scanner);
		var result:TokenNode = adapter.create(
			AS3NodeKind.AS_DOC,
			token.text, 
			sc.commentLine,	sc.commentColumn);
		sc.commentLine = -1;
		sc.commentColumn = -1;
		result.start = scanner.offset - token.text.length;
		result.end = scanner.offset;
		
		consume(token.text, null, false);
		
		return result;
	}
	
	// Erik: added so we can parse blocks we find interesting
	public function parseBlockFragment(node:IParserNode):IParserNode
	{
		token = node.startToken;
		AS3Scanner(scanner).moveTo(node.line-1, node.column);
		
		parseBlocks = true;
		return parseBlock();
	}
	
	/**
	 * @private
	 */
	private function addAsDoc(node:TokenNode):void
	{
		if (currentAsDoc)
		{
			currentAsDoc.token.text = "";
			node.addChild(currentAsDoc);
			currentAsDoc = null;
		}
	}
	
	/**
	 * @private
	 */
	internal function parseExpressionStatement():IParserNode
	{
		var result:TokenNode = adapter.empty(AS3NodeKind.EXPR_STMNT, token);
		do
		{
			if (tokIs(Operators.COMMA))
			{
				consume(Operators.COMMA, result);
			}
			result.addChild(parseAssignmentExpression());
		} 
		while (tokIs(Operators.COMMA))
		skip(Operators.SEMI, result);
		return result;
	}
	/**
	 * @private
	 */
	internal function parseMetaDatas():IParserNode
	{
		return parseTypeContent();
	}
}
}