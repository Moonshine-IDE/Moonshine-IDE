////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package org.as3commons.mxmlblocks.impl
{

import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTTypeBuilder;
import org.as3commons.asblocks.impl.ApplicationUnitNode;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.ParentheticListUpdateDelegate;
import org.as3commons.asblocks.parser.core.TokenNode;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

public class ASTMXMLBuilder
{
	
	
	public static function newApplicationCompilationUnit(qualifiedName:String,
														 superQualifiedName:String):ICompilationUnit
	{
		var packageName:String = ASTTypeBuilder.packageNameFrom(superQualifiedName);
		var className:String = ASTTypeBuilder.typeNameFrom(superQualifiedName);
		
		var appAST:IParserNode = ASTBuilder.newAST(MXMLNodeKind.COMPILATION_UNIT);
		appAST.addChild(ASTBuilder.newAST(MXMLNodeKind.PROC_INST, 
			"<?xml version=\"1.0\" encoding=\"utf-8\"?>"));
		appAST.appendToken(TokenBuilder.newNewline());
		
		var tag:IParserNode = newTag(className, null);
		appAST.addChild(tag);
		
		var ast:IParserNode = ASTTypeBuilder.newClassCompilationUnitAST(qualifiedName);
		
		var unit:ICompilationUnit = new ApplicationUnitNode(ast, appAST);
		unit.packageName = ASTTypeBuilder.packageNameFrom(qualifiedName);
		unit.typeNode.name = ASTTypeBuilder.typeNameFrom(qualifiedName);
		IClassType(unit.typeNode).superClass = superQualifiedName;
		return unit;
	}
	
	public static function newXMLNS(localName:String, uri:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(MXMLNodeKind.XML_NS);
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newToken("xmlns", "xmlns"));
		if (localName)
		{
			var colon:LinkedListToken = TokenBuilder.newColon();
			var name:IParserNode = ASTBuilder.newAST(MXMLNodeKind.LOCAL_NAME, localName);
			name.startToken.prepend(colon);
			name.startToken = colon;
			ast.addChild(name);
		}
		var assign:LinkedListToken = TokenBuilder.newAssign();
		var uriAST:IParserNode = ASTBuilder.newAST(MXMLNodeKind.URI, uri);
		uriAST.startToken.prepend(assign);
		uriAST.startToken = assign;
		assign.append(TokenBuilder.newQuote());
		ast.addChild(uriAST);
		uriAST.appendToken(TokenBuilder.newQuote());
		return ast;
	}
	
	public static function newAttribute(name:String, value:String, state:String = null):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(MXMLNodeKind.ATT);
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newAST(MXMLNodeKind.NAME, name));
		
		if (state)
		{
			var dot:LinkedListToken = TokenBuilder.newDot();
			var stateAST:IParserNode = ASTBuilder.newAST(MXMLNodeKind.STATE, state);
			stateAST.startToken.prepend(dot);
			stateAST.startToken = dot;
			ast.addChild(stateAST);
		}
		
		ast.appendToken(TokenBuilder.newAssign());
		ast.appendToken(TokenBuilder.newQuote());
		ast.addChild(ASTBuilder.newAST(MXMLNodeKind.VALUE, value));
		ast.appendToken(TokenBuilder.newQuote());
		return ast;
	}
	
	public static function newTag(name:String, binding:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST("tag-list");
		var body:IParserNode = ASTBuilder.newAST("body");
		
		ast.appendToken(TokenBuilder.newLess());
		
		if (binding)
		{
			ast.addChild(ASTBuilder.newAST("binding", binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.addChild(ASTBuilder.newAST("local-name", name));
		ast.appendToken(TokenBuilder.newGreater());
		
		ast.addChild(body);
		
		ast.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newToken("text", "</"));
		
		if (binding)
		{
			ast.appendToken(TokenBuilder.newToken("binding", binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.appendToken(TokenBuilder.newToken("text", name));
		ast.appendToken(TokenBuilder.newGreater());
		
		return ast;
	}
	
	public static function newScriptTag(code:String):IParserNode
	{
		if (code == null)
		{
			code = "";
		}
		
		var ast:IParserNode = ASTBuilder.newAST("script");
		
		var contentAST:IParserNode = AS3FragmentParser.parseClassContent(code);
		
		ParentheticListUpdateDelegate(TokenNode(contentAST).tokenListUpdater).
			setBoundaries("lcdata", "rcdata");
		
		contentAST.startToken.text = "<![CDATA[";
		contentAST.startToken.kind = "lcdata";
		contentAST.stopToken.text = "]]>";
		contentAST.stopToken.kind = "rcdata";
		
		var body:IParserNode = ASTBuilder.newAST(MXMLNodeKind.BODY);
		
		var binding:String = "fx";
		var name:String = "Script";
		
		ast.appendToken(TokenBuilder.newLess());
		
		if (binding)
		{
			ast.addChild(ASTBuilder.newAST(MXMLNodeKind.BINDING, binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.addChild(ASTBuilder.newAST(MXMLNodeKind.LOCAL_NAME, name));
		ast.appendToken(TokenBuilder.newGreater());
		ast.appendToken(TokenBuilder.newNewline());
		
		//ASTUtil.addChildWithIndentation(body, contentAST);
		body.addChild(contentAST);
		ast.addChild(body);
		
		contentAST.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newToken("text", "</"));
		
		if (binding)
		{
			ast.appendToken(TokenBuilder.newToken(MXMLNodeKind.BINDING, binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.appendToken(TokenBuilder.newToken("text", name));
		ast.appendToken(TokenBuilder.newGreater());
		
		return ast;
	}
	
	public static function newMetadataTag(code:String):IParserNode
	{
		if (code == null)
		{
			code = "";
		}
		
		var ast:IParserNode = ASTBuilder.newAST("script");
		
		var contentAST:IParserNode = AS3FragmentParser.parseClassContent(code);
		
		ParentheticListUpdateDelegate(TokenNode(contentAST).tokenListUpdater).
			setBoundaries("lcdata", "rcdata");
		
		contentAST.startToken.text = "<![CDATA[";
		contentAST.startToken.kind = "lcdata";
		contentAST.stopToken.text = "]]>";
		contentAST.stopToken.kind = "rcdata";
		
		var body:IParserNode = ASTBuilder.newAST(MXMLNodeKind.BODY);
		
		var binding:String = "fx";
		var name:String = "Metadata";
		
		ast.appendToken(TokenBuilder.newLess());
		
		if (binding)
		{
			ast.addChild(ASTBuilder.newAST(MXMLNodeKind.BINDING, binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.addChild(ASTBuilder.newAST(MXMLNodeKind.LOCAL_NAME, name));
		ast.appendToken(TokenBuilder.newGreater());
		ast.appendToken(TokenBuilder.newNewline());
		
		//ASTUtil.addChildWithIndentation(body, contentAST);
		body.addChild(contentAST);
		ast.addChild(body);
		
		contentAST.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newToken("text", "</"));
		
		if (binding)
		{
			ast.appendToken(TokenBuilder.newToken(MXMLNodeKind.BINDING, binding));
			ast.appendToken(TokenBuilder.newColon());
		}
		
		ast.appendToken(TokenBuilder.newToken("text", name));
		ast.appendToken(TokenBuilder.newGreater());
		
		return ast;
	}
	
	public static function newXMLComment(ast:IParserNode, text:String):IToken
	{
		var comment:LinkedListToken = TokenBuilder.newSLComment("<!-- " + text + "-->");
		var indent:String = ASTUtil.findIndentForComment(ast);
		var stop:LinkedListToken = ASTUtil.findTagStop(ast).previous; // nl
		
		var nl:LinkedListToken = TokenBuilder.newNewline();
		stop.prepend(nl);
		var sp:LinkedListToken = TokenBuilder.newWhiteSpace(indent + "\t");
		nl.append(sp);
		sp.append(comment);
		
		
		
		//ast.appendToken(TokenBuilder.newNewline());
		//ast.appendToken(TokenBuilder.newWhiteSpace(indent));
		//ast.appendToken(comment);
		return comment;
	}
	
}
}