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