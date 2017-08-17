package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.parser.api.ASDocNodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;
import org.as3commons.asblocks.utils.DocCommentUtil;

public class ASTAsDocBuilder
{
	public static function newDocTagList(parent:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(ASDocNodeKind.DOCTAG_LIST);	
		ast.appendToken(TokenBuilder.newNewline());
		var indent:String = ASTUtil.findIndent(parent);
		ast.appendToken(TokenBuilder.newWhiteSpace(indent + " * "));
		return ast;
	}
	
	public static function newDocTag():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(ASDocNodeKind.DOCTAG);
		return ast;
	}
	
	public static function addDocTag(parent:IParserNode, name:String, body:String):IParserNode
	{
		var indent:String = ASTUtil.findIndent(parent);
		
		var ast:IParserNode = newDocTag();
		ast.appendToken(TokenBuilder.newToken(ASDocNodeKind.NL, "\n"));
		ast.appendToken(TokenBuilder.newToken(ASDocNodeKind.WS, indent + " "));
		ast.appendToken(TokenBuilder.newToken(ASDocNodeKind.ASTRIX, "*"));
		ast.appendToken(TokenBuilder.newToken(ASDocNodeKind.WS, " "));
		ast.appendToken(TokenBuilder.newToken(ASDocNodeKind.AT, "@"));
		ast.addChild(ASTBuilder.newNameAST(name));
		
		if (body)
		{
			ast.appendToken(TokenBuilder.newSpace());
			var nl:String = DocCommentUtil.getNewlineText(parent, ast);
			
			body = body.replace(/\n/g, nl);
			ast.addChild(ASTBuilder.newAST(ASDocNodeKind.BODY, body));
		}
		
		return ast;
	}
}
}