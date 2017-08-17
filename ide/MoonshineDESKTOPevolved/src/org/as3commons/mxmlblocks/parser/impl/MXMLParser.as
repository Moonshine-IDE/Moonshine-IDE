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
import org.as3commons.asblocks.parser.api.IScanner;
import org.as3commons.asblocks.parser.api.ISourceCodeScanner;
import org.as3commons.asblocks.parser.api.Operators;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.core.ParentheticListUpdateDelegate;
import org.as3commons.asblocks.parser.core.Token;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.errors.Position;
import org.as3commons.asblocks.parser.errors.UnExpectedTokenError;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.parser.impl.ParserBase;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

/**
 * The default implementation of an .mxml parser.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class MXMLParser extends ParserBase
{
	//--------------------------------------------------------------------------
	//
	//  Private :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var pendingASDoc:IParserNode = null;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function MXMLParser()
	{
		super();
		
		adapter = new LinkedListTreeAdaptor();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	override protected function createScanner():IScanner
	{
		var s:IScanner = new MXMLScanner();
		s.allowWhiteSpace = true;
		return s;
	}
	
	/**
	 * @private
	 */
	override protected function initialize():void
	{
		pendingASDoc = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Internal Parser :: Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  compilation-unit
	//----------------------------------
	
	/**
	 * @private
	 */
	override public function parseCompilationUnit():IParserNode
	{
		var result:TokenNode = adapter.create(MXMLNodeKind.COMPILATION_UNIT);
		
		nextToken(); // start the parse
		
		if (!tokIs("<?"))
		{
			throw new UnExpectedTokenError(
				"<?", 
				token.text, 
				new Position(token.line, token.column, -1), 
				fileName);
		}
		
		result.addChild(parseProcInst());
		
		nextTokenConsume(result); // chomp all whitespace
		
		if (tokenStartsWith("<!---")) // this will be the class asdoc
		{
			pendingASDoc = parseASDoc();
		}
		
		if (tokIs("<")) // first tag is application/component
		{
			result.addChild(parseTagList());
		}
		
		return result;
	}
	
	//----------------------------------
	//  proc-inst
	//----------------------------------
	
	/*
	* - PROC_INST
	*/
	internal function parseProcInst():TokenNode
	{
		var result:TokenNode = adapter.copy(MXMLNodeKind.PROC_INST, token);
		// current token "<?"
		var text:String = "";
		
		var line:int = token.line;
		var column:int = token.column;
		
		while (!tokIs("?>"))
		{
			text += token.text;
			nextToken();
		}
		
		text += "?>";
		result.stringValue = text;
		return result;
	}
	
	//----------------------------------
	//  as-doc
	//----------------------------------
	
	/**
	 * @private
	 */
	private var asdocColumn:int;
	
	/**
	 * @private
	 */
	private var asdocLine:int;
	
	/*
	* - AS_DOC
	*/
	internal function parseASDoc():TokenNode
	{
		// current token "<!--- doc. -->"
		asdocLine = ISourceCodeScanner(scanner).commentLine;
		asdocColumn = ISourceCodeScanner(scanner).commentColumn;
		
		var result:TokenNode =
			adapter.create(MXMLNodeKind.AS_DOC,
				token.text,
				asdocLine,
				asdocColumn);
		
		nextTokenConsume(result);
		
		return result;
	}
	
	//----------------------------------
	//  tag-list
	//----------------------------------
	
	/*
	* TAG_LIST
	*   - AS_DOC (optional)
	*   - ATT_LIST
	*   - BODY
	*/
	
	internal function parseTagList():TokenNode
	{
		// current token "<"
		var result:TokenNode = adapter.empty(MXMLNodeKind.TAG_LIST, token);
		
		var text:String = "";
		
		if (pendingASDoc != null)
		{
			result.addChild(pendingASDoc);
			pendingASDoc = null;
		}
		
		// <, s, :, Application
		
		consume("<", result);
		
		var bindingFound:Boolean = false;
		
		var localNameToken:Token = token;
		var firstNode:TokenNode = adapter.empty(MXMLNodeKind.LOCAL_NAME, localNameToken);
		var tagName:String = localNameToken.text;
		
		nextTokenConsume(firstNode); // (:|TAG_NAME)
		
		if (tokIs(Operators.COLON))
		{
			bindingFound = true;
			
			firstNode.kind = MXMLNodeKind.BINDING;
			firstNode.stringValue = localNameToken.text;
			result.addChild(firstNode);
			
			consume(Operators.COLON, result);
			localNameToken = token;
			tagName = localNameToken.text;
			
			result.addChild(adapter.create(
				MXMLNodeKind.LOCAL_NAME, tagName, 
				localNameToken.line, localNameToken.column));
		}
		else
		{
			bindingFound = false;
			
			firstNode.kind = MXMLNodeKind.LOCAL_NAME;
			tagName = localNameToken.text;
			firstNode.stringValue = tagName;
			result.addChild(firstNode);
		}
		
		// only call next if there was a binding, if not we are already there
		if (bindingFound)
		{
			nextTokenConsume(result); // maybe xmlns or att or <
		}
		
		// added to solve . error in tag name (state)
		// edit ast to include tag state
		if (tokIs("."))
		{
			nextTokenConsume(result);
			tagName = tagName + "." + token.text;
			nextTokenConsume(result); // maybe xmlns or att or <
		}
		
		var inAttList:Boolean = true;
		var closing:Boolean = false;
		
		var body:TokenNode = adapter.empty("body", token);
		
		while (!tokIs("/>") && !tokIs("</"))
		{
			if (tokIs(">"))
			{
				inAttList = false;
				result.addChild(body);
				consume(">", body);
			}
			else if (tokenStartsWith("<!---"))
			{
				pendingASDoc = parseASDoc();
			}
			else if (tokIs("<"))
			{
				body.addChild(parseTagList());
			}
			else if (inAttList)
			{
				result.addChild(parseAttList());
			}
			else
			{
				if (!tokIs(">"))
				{
					var contentAST:IParserNode;
					
					if (token.kind == "cdata")
					{
						if (tagName == "Script")
						{
							contentAST = AS3FragmentParser.parseClassContent(token.text);
						}
						else if (tagName == "Metadata")
						{
							contentAST = AS3FragmentParser.parsePackageContent(token.text);
						}
						
						ParentheticListUpdateDelegate(TokenNode(contentAST).tokenListUpdater).
							setBoundaries("lcdata", "rcdata");
						
						contentAST.startToken.text = "<![CDATA[";
						contentAST.startToken.kind = "lcdata";
						contentAST.stopToken.text = "]]>";
						contentAST.stopToken.kind = "rcdata";
						
						body.addChild(contentAST);
					}
					else
					{
						var t:String = parseText();
						if (tagName == "Metadata")
						{
							contentAST = AS3FragmentParser.parsePackageContent(t);
						}
						body.addChild(contentAST);
					}
				}
				
				if (!tokIs("</"))
				{
					nextTokenConsume(result);
				}
			}
		}
		
		// these tokens are required to leave this method
		// to types of end tag tokens
		if (tokIs("/>") || tokIs("</"))
		{
			var end:Boolean = tokIs("/>");
			consume(token.text, result);
			
			if (!end)
			{
				// binding : LocalName
				if (!bindingFound)
				{
					consume(tagName, result);
					consume(">", result);
				}
				else
				{
					consume(firstNode.stringValue, result);
					consume(":", result);
					consume(tagName, result);
					// FIXME (mschmalle) '>' mxml parse; what is going on at the end of the 
					try {
						consume(">", result);
					}
					catch(e:Error){trace(e.message)}
				}	
			}
		}
		else
		{
			throw new Error("parseTagList() error");
		}
		
		if (tagName == "Script")
		{
			result.kind = "script";
		}
		else if (tagName == "Metadata")
		{
			result.kind = "metadata";
		}
		return result;
	}
	
	private function parseText():String
	{
		var text:String = "";
		
			while (!tokIs("</"))
			{
				if(token)
					text += token.text;
					nextToken();
			}
		
		return text;
	}
	
	internal function parseAttList():TokenNode
	{
		var result:TokenNode = adapter.empty(MXMLNodeKind.ATT_LIST, token);
		
		while (!tokIs(">") && !tokIs("/>"))
		{
			if (tokIs("xmlns"))
			{
				result.addChild(parseXmlNs());
			}
			else
			{
				result.addChild(parseAtt());
			}
			nextTokenConsume(result);
		}
		
		return result;
	}
	
	//----------------------------------
	//  xmlns
	//----------------------------------
	
	/*
	* - XMLNS
	*   - LOCAL_NAME
	*   - URI
	*/
	internal function parseXmlNs():TokenNode
	{
		// current token "xmlns"
		var result:TokenNode = adapter.empty(MXMLNodeKind.XML_NS, token);
		
		consume("xmlns", result);
		
		if (tokIs(":"))
		{
			consume(":", result);
			result.addChild(adapter.copy(MXMLNodeKind.LOCAL_NAME, token));
			nextTokenConsume(result); // s binding
		}
		
		consume("=", result);
		
		result.appendToken(new LinkedListToken(Operators.QUOTE, "\""));
		result.addChild(adapter.create(
			MXMLNodeKind.URI,
			trimQuotes(token.text),
			token.line,
			token.column));// should +1 since quotes are trimmed;
		result.appendToken(new LinkedListToken(Operators.QUOTE, "\""));
		
		return result;
	}
	
	//----------------------------------
	//  cdata
	//----------------------------------
	
	/*
	* - CDATA
	*/
	internal function parseCData():TokenNode
	{
		// current token "all string data in between CDATA tags"
		var result:TokenNode = adapter.copy(MXMLNodeKind.CDATA, token);
		
		nextTokenConsume(result);
		
		return result;
	}
	
	//----------------------------------
	//  att
	//----------------------------------
	
	/*
	* - ATT
	*   - NAME
	*   - STATE
	*   - VALUE
	*/
	internal function parseAtt():TokenNode
	{
		// current token "attributName"
		var result:TokenNode = adapter.empty(MXMLNodeKind.ATT, token);
		
		result.addChild(adapter.copy(MXMLNodeKind.NAME, token));
		
		nextTokenConsume(result);
		if (tokIs("."))
		{
			skip(".", result);
			result.addChild(adapter.copy(MXMLNodeKind.STATE, token));
			nextTokenConsume(result);
		}
		
		if (!tokIs("="))
		{
			return null;
		}
		
		consume("=", result);
		
		result.appendToken(new LinkedListToken(Operators.QUOTE, "\""));
		if(token)
		{
		result.addChild(adapter.create(MXMLNodeKind.VALUE,
			trimQuotes(token.text),
			token.line,
			token.column));
		result.appendToken(new LinkedListToken(Operators.QUOTE, "\""));
		}
		return result;
	}
	
	override protected function nextTokenConsume(node:TokenNode):void
	{
		if (!consumeWhitespace(node))
		{
			nextToken();
			
			if (tokIs(" ") || tokIs("\t") || tokIs("\n")
				|| (tokenStartsWith("<!--") && !tokenStartsWith("<!---")))
			{
				nextTokenConsume(node);
			}
		}
	}
	
	override protected function tokIsWhitespace():Boolean
	{
		return token.text == "\n" || token.text == "\t" || 
			token.text == " " || tokenStartsWith("<!--");
	}
	
	override protected function consumeWhitespace(node:TokenNode):Boolean
	{
		if (!node || !token)
		{
			return false;
		}
		
		var advanced:Boolean = false;
		
		while (tokIs(" ") || tokIs("\t") || tokIs("\n")
			|| (tokenStartsWith("<!--") && ! tokenStartsWith("<!---")))
		{
			if (tokIs(" "))
			{
				appendSpace(node);
			}
			else if (tokIs("\t"))
			{
				appendTab(node);
			}
			else if (tokIs("\n"))
			{
				appendNewline(node);
			}
			else if (tokenStartsWith("<!--") && !tokenStartsWith("<!---"))
			{
				appendComment(node);
			}
			
			advanced = true;
		}
		
		return advanced;
	}
}
}