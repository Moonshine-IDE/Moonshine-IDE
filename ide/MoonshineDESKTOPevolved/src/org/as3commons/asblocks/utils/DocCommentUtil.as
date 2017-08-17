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

package org.as3commons.asblocks.utils
{

import mx.utils.StringUtil;

import org.as3commons.asblocks.api.IDocComment;
import org.as3commons.asblocks.api.IDocTag;
import org.as3commons.asblocks.impl.ASTAsDocBuilder;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.DocCommentNode;
import org.as3commons.asblocks.impl.DocTagNode;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.ASDocNodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.impl.AS3Parser;
import org.as3commons.asblocks.parser.impl.ASDocFragmentParser;
import org.as3commons.asblocks.parser.impl.ASDocParser;
import org.as3commons.asblocks.parser.impl.ASTIterator;

/**
 * @private
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class DocCommentUtil
{
	/**
	 * @private
	 */
	public static function createDocComment(ast:IParserNode):IDocComment
	{
		return new DocCommentNode(ast);
	}
	
	/**
	 * @private
	 * Returns the as-doc node on the doccomment aware node
	 */
	public static function buildCompilationUnit(parent:IParserNode):IParserNode
	{
		// find the as-doc node
		var ast:IParserNode = parent.getKind(AS3NodeKind.AS_DOC);
		
		// if there is no node, can't build anyting, just return
		if (!ast)
			return null;
		
		// rebuild an ast of the asdoc using the existing string value of the token
		var asdocAST:IParserNode = ASDocFragmentParser.
			parseCompilationUnit(ast.stringValue);
		
		return asdocAST;
	}
	
	public static function buildOrAddCompilationUnit(parent:IParserNode):IParserNode
	{
		var ast:IParserNode = buildCompilationUnit(parent);
		if (ast != null)
			return ast;
		
		ast = ASTBuilder.newAST(AS3NodeKind.AS_DOC, "/**\n */");
		
		var index:int = !parent.hasKind(AS3NodeKind.META_LIST) ? 0 : 1;
		parent.appendToken(TokenBuilder.newMLComment(""));
		parent.addChildAt(ast, index);
		
		return buildCompilationUnit(parent);
	}
	
	public static function newAsDocAST(parent:IParserNode, text:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.AS_DOC, text);
		ast.startToken.text = null;
		
		var index:int = 0;
		if (parent.hasKind(AS3NodeKind.META_LIST))
		{
			index++;
		}
		
		TokenNode(parent).absolute = true;
		parent.addChildAt(ast, index);
		TokenNode(parent).absolute = false;
		
		var token:LinkedListToken = TokenBuilder.newMLComment(text);
		ast.startToken.prepend(token);
		
		//token.append(TokenBuilder.newNewline());
		// append the \n\t to the end of the */
		appendNewline(parent, ast);
		
		return ast;
	}
	
	public static function getDescription(comment:IDocComment):String
	{
		var parent:IParserNode = comment.node;
		var ast:IParserNode = buildCompilationUnit(parent);
		if (ast == null)
			return null;
		
		var desc:IParserNode = ast.getKind(ASDocNodeKind.DESCRIPTION);
		var body:IParserNode = desc.getKind(ASDocNodeKind.BODY);
		return stringify(body);
	}
	
	public static function setDescription(comment:IDocComment, description:String):void
	{
		// find the token in the parent
		var parent:IParserNode = comment.node;
		var asdoc:IParserNode = parent.getKind(AS3NodeKind.AS_DOC);
		
		//if (!asdoc)
		//{
		//	var body:String = getCommentBody(asdoc);
		//	asdoc = parse(body);
		//}
		//else
		//{
		//	
		//}
		
		// '\n\t * '
		var newline:String = getNewlineText(parent, asdoc);
		// this allows the description to start with a newline atrix '/**\n ws* description'
		if (description.indexOf("\n") != 0)
		{
			description = "\n" + description;
		}
		
		// replace all \n in the description with proper '\n\t * ' newline headers
		description = description.replace(/\n/g, newline);
		
		// create the ast for the description
		var descriptionAST:IParserNode = parseDescription(description);
		
		// find the indent based on the parent nodes indentation
		var indent:String = ASTUtil.findIndent(parent);
		
		// token before this comment takes care of it's own \n\t indent
		// !!! Tokens and blocks always end with [newline][indent]
		var result:String = "/**" + ASTUtil.stringifyNode(descriptionAST) + "\n" + indent + " */";
		
		if (asdoc == null)
		{
			asdoc = newAsDocAST(parent, result);
			DocCommentNode(comment).asdocNode = asdoc;
		}
		else
		{
			asdoc.stringValue = "/**" + description + "\n" + indent + " */";
			asdoc.startToken.text = null;
			var atok:LinkedListToken = getASDocToken(asdoc);
			atok.text = asdoc.stringValue;
		}
	}
	
	public static function getASDocToken(asdoc:IParserNode):LinkedListToken
	{
		for (var tok:LinkedListToken =  asdoc.startToken; tok != null; tok = tok.previous)
		{
			if (tok.kind == AS3NodeKind.ML_COMMENT)
				return tok;
		}
		return null;
	}
	
	public static function getNewlineText(ast:IParserNode, asdoc:IParserNode):String
	{
		var newline:String = null;
		//if (asdoc != null)
		//{
		//	newline = findNewline(asdoc);
		//}
		if (newline == null)
		{
			newline = "\n" + ASTUtil.findIndent(ast) + " * ";
		}
		return newline;
	}
	
	public static function appendNewline(parent:IParserNode, ast:IParserNode):void
	{
		var indent:String = ASTUtil.findIndent(parent);
		var indentTok:LinkedListToken = TokenBuilder.newWhiteSpace(indent);
		ast.appendToken(TokenBuilder.newNewline());
		ast.appendToken(indentTok);
	}
	
	public static function findNewline(ast:IParserNode):String
	{
		var tok:LinkedListToken = ast.stopToken;
		if (tok.text == "\n")
		{
			// Skip the very-last NL, since this will precede the
			// closing-comment marker, and therefore will lack the
			// '*' that should be present at the start of every
			// other line,
			tok = tok.previous;
		}
		for (; tok != null; tok = tok.previous)
		{
			if (tok.text == "\n")
			{
				return tok.text;
			}
		}
		return null;
	}
	
	public static function stringify(ast:IParserNode):String
	{
		var result:String = "";
		
		var tok:LinkedListToken = ast.startToken;
		while (tok != null && tok.kind != null)
		{
			if (tok.text != null 
				&& tok.channel != "hidden"
				&& tok.kind != "astrix"
				&& tok.kind != "ws"
				|| (tok.channel == null && tok.kind == "nl"))
			{
				if (tok.kind == "nl")
				{
					result += "\n";
				}
				else
				{
					result += tok.text;
				}
			}
			
			if (tok == ast.stopToken)
			{
				break;
			}
			
			tok = tok.next;
		}
		
		return result;
	}
	
	public static function newDocTag(comment:IDocComment, 
									 name:String, 
									 body:String = null):IDocTag
	{
		var asdoc:IParserNode = buildCompilationUnit(comment.node);
		if (!asdoc)
		{
			asdoc = newAsDocAST(comment.node, "/**\n */");
			DocCommentNode(comment).asdocNode = asdoc;
		}
		
		var list:IParserNode = findDoctagList(comment.node);
		if (!list)
		{
			list = ASTAsDocBuilder.newDocTagList(comment.node);
			var description:IParserNode = asdoc.getKind(ASDocNodeKind.DESCRIPTION);
			description.addChild(list);
			
			//var i:String = ASTUtil.findIndent(node);
			//var newline:String = DocCommentUtil.getNewlineText(node, list);
			//var ws:LinkedListToken = TokenBuilder.newWhiteSpace("\n" + i + " * ");
			//list.startToken.prepend(ws);
			//list.startToken = ws;
		}
		
		// "
		//  * @foo"
		var tag:IParserNode = ASTAsDocBuilder.addDocTag(comment.node, name, body);
		
		list.addChild(tag);
		
		rebuildAST(comment.node, asdoc);
		
		return new DocTagNode(tag);
	}
	
	public static function removeDocTag(comment:IDocComment, tag:IDocTag):Boolean
	{
		//var asdoc:IParserNode = buildASDoc(comment.node);
		//if (!asdoc)
		//	return false;
		
		var asdoc:IParserNode = comment.asdocNode;
		if (!asdoc)
			return false;
		
		var list:TokenNode = findDoctagList(asdoc) as TokenNode;
		if (!list)
			return false;
		
		var i:ASTIterator = new ASTIterator(list);
		while (i.hasNext())
		{
			var ast:IParserNode = i.next();
			if (ast === tag.node)
			{
				list.removeChild(ast);
				if (list.numChildren == 0)
				{
					list.parent.removeChild(list);
				}
				rebuildAST(comment.node, asdoc);
				return true;
			}
		}
		return false;
	}
	
	public static function hasDocTag(parent:IParserNode, name:String):Boolean
	{
		var list:TokenNode = findDoctagList(parent) as TokenNode;
		if (!list)
			return false;
		
		var i:ASTIterator = new ASTIterator(list);
		while (i.hasNext())
		{
			var tag:IDocTag = new DocTagNode(i.next());
			if (tag.name == name)
				return true;
		}
		return false;
	}
	
	public static function rebuildAST(parent:IParserNode, asdoc:IParserNode):void
	{
		var result:String = ASTUtil.stringifyNode(asdoc);
		
		var ast:IParserNode = parent.getKind(AS3NodeKind.AS_DOC);
		ast.stringValue = result;
		ast.startToken.text = null;
		
		var tok:LinkedListToken = DocCommentUtil.getASDocToken(ast);
		tok.text = result;
	}
	
	private static function _convertDescription(description:String, indent:String):String
	{
		var result:String = "";
		
		var split:Array = description.split("\n");
		var len:int = split.length;
		for (var i:int = 0; i < len; i++)
		{
			var middle:String = (i == 0) ? "" : " * ";
			result += indent + middle + split[i] + "\n";
		}
		
		return result;
	}
	
	private static function parseDescription(input:String):IParserNode
	{
		var ast:IParserNode = ASDocFragmentParser.parseDescription(input);
		return ast;
	}
	
	private static function parseBody(input:String):IParserNode
	{
		var ast:IParserNode = ASDocFragmentParser.parseBody(input);
		return ast;
	}
	
	private static function getCommentBody(ast:IParserNode):String
	{
		var result:String = ast.stringValue;
		return result.substring(3, result.length - 2);
	}
	
	private static function findContent(ast:IParserNode):IParserNode
	{
		if (!ast)
			return null;
		return ast.getKind(ASDocNodeKind.DESCRIPTION);
	}
	
	private static function findDoctagList(ast:IParserNode):IParserNode
	{
		var ast:IParserNode = findContent(ast);
		if (!ast)
			return null;
		return ast.getKind(ASDocNodeKind.DOCTAG_LIST);
	}
}
}