package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.IMetaData;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.LinkedListTreeAdaptor;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTBuilder
{
	private static var adapter:LinkedListTreeAdaptor = new LinkedListTreeAdaptor();
	
	public static function newAST(kind:String, text:String = null):IParserNode
	{
		return adapter.create(kind, text);
	}
	
	public static function newPrimaryAST(name:String = null):IParserNode
	{
		return newAST(AS3NodeKind.PRIMARY, name);
	}
	
	public static function newNameAST(name:String):IParserNode
	{
		return newAST(AS3NodeKind.NAME, name);
	}
	
	public static function newTypeAST(type:String):IParserNode
	{
		return newAST(AS3NodeKind.TYPE, type);
	}
	
	public static function parseTypeAST(type:String):IParserNode
	{
		var ast:IParserNode = AS3FragmentParser.parseType(type);
		var colon:LinkedListToken = TokenBuilder.newColon();
		ast.startToken.prepend(colon);
		ast.startToken = colon;
		return ast;
	}
	
	public static function newMetaData(name:String):IParserNode
	{
		var ast:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.META, 
			AS3NodeKind.LBRACKET, "[", 
			AS3NodeKind.RBRACKET, "]");
		ast.addChild(newNameAST(name));
		return ast;
	}
	
	public static function newCondition(expression:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.CONDITION, 
			AS3NodeKind.LPAREN, "(", 
			AS3NodeKind.RPAREN, ")");
		ast.addChild(expression);
		return ast;
	}
	
	public static function newComment(ast:IParserNode, text:String):IToken
	{
		var comment:LinkedListToken = TokenBuilder.newSLComment("//" + text);
		var indent:String = ASTUtil.findIndentForComment(ast);
		ast.appendToken(TokenBuilder.newNewline());
		ast.appendToken(TokenBuilder.newWhiteSpace(indent));
		ast.appendToken(comment);
		return comment;
	}
	
	public static function spaceEitherSide(token:LinkedListToken):void
	{
		token.prepend(TokenBuilder.newSpace());
		token.append(TokenBuilder.newSpace());
	}
	
	public static function parenthise(expression:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.ENCAPSULATED, 
			AS3NodeKind.LPAREN, "(", 
			AS3NodeKind.RPAREN, ")");
		ast.addChild(expression);
		return ast;
	}
	
	public static function precidence(ast:IParserNode):int
	{
		switch (ast.kind) 
		{
			case AS3NodeKind.ASSIGN:
			case AS3NodeKind.STAR_ASSIGN:
			case AS3NodeKind.DIV_ASSIGN:
			case AS3NodeKind.MOD_ASSIGN:
			case AS3NodeKind.PLUS_ASSIGN:
			case AS3NodeKind.MINUS_ASSIGN:
			case AS3NodeKind.SL_ASSIGN:
			case AS3NodeKind.SR_ASSIGN:
			case AS3NodeKind.BSR_ASSIGN:
			case AS3NodeKind.BAND_ASSIGN:
			case AS3NodeKind.BXOR_ASSIGN:
			case AS3NodeKind.BOR_ASSIGN:
			case AS3NodeKind.LAND_ASSIGN:
			case AS3NodeKind.LOR_ASSIGN:
				return 13;
			case AS3NodeKind.QUESTION:
				return 12;
			case AS3NodeKind.LOR:
				return 11;
			case AS3NodeKind.LAND:
				return 10;
			case AS3NodeKind.BOR:
				return 9;
			case AS3NodeKind.BXOR:
				return 8;
			case AS3NodeKind.BAND:
				return 7;
			case AS3NodeKind.STRICT_EQUAL:
			case AS3NodeKind.STRICT_NOT_EQUAL:
			case AS3NodeKind.NOT_EQUAL:
			case AS3NodeKind.EQUAL:
				return 6;
			case AS3NodeKind.IN:
			case AS3NodeKind.LT:
			case AS3NodeKind.GT:
			case AS3NodeKind.LE:
			case AS3NodeKind.GE:
			case AS3NodeKind.IS:
			case AS3NodeKind.AS:
			case AS3NodeKind.INSTANCE_OF:
				return 5;
			case AS3NodeKind.SL:
			case AS3NodeKind.SR:
			case AS3NodeKind.BSR:
				return 4;
			case AS3NodeKind.PLUS:
			case AS3NodeKind.MINUS:
				return 3;
			case AS3NodeKind.STAR:
			case AS3NodeKind.DIV:
			case AS3NodeKind.MOD:
				return 2;
			default:
				return 1;
		}
	}
}
}