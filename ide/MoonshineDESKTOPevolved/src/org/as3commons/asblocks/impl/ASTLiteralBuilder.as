package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.KeyWords;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTLiteralBuilder
{
	/**
	 * @private
	 */
	public static function newNumberLiteral(number:Number):IParserNode
	{
		return ASTBuilder.newAST(AS3NodeKind.NUMBER, number.toString());
	}
	
	/**
	 * @private
	 */
	public static function newNullLiteral():IParserNode
	{
		return ASTBuilder.newAST(AS3NodeKind.NULL, KeyWords.NULL);
	}
	
	/**
	 * @private
	 */
	public static function newUndefinedLiteral():IParserNode
	{
		return ASTBuilder.newAST(AS3NodeKind.UNDEFINED, KeyWords.UNDEFINED);
	}
	
	/**
	 * @private
	 */
	public static function newBooleanLiteral(boolean:Boolean):IParserNode
	{
		var kind:String = (boolean) ? AS3NodeKind.TRUE : AS3NodeKind.FALSE;
		var text:String = (boolean) ? KeyWords.TRUE : KeyWords.FALSE;
		return ASTBuilder.newAST(kind, text);
	}
	
	/**
	 * @private
	 */
	public static function newStringLiteral(string:String):IParserNode
	{
		return ASTBuilder.newAST(AS3NodeKind.STRING, ASTUtil.escapeString(string));
	}
	
	/**
	 * @private
	 */
	public static function newArrayLiteral():IParserNode
	{
		var ast:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.ARRAY, 
			AS3NodeKind.LBRACKET, "[", 
			AS3NodeKind.RBRACKET, "]");
		return ast;
	}
	
	/**
	 * @private
	 */
	public static function newObjectLiteral():IParserNode
	{
		return ASTStatementBuilder.newBlock(AS3NodeKind.OBJECT);
	}
	
	/**
	 * @private
	 */
	public static function newObjectField(name:String, 
										  node:IParserNode):IParserNode
	{
		var field:IParserNode = ASTBuilder.newAST(AS3NodeKind.PROP);
		field.addChild(AS3FragmentParser.parsePrimaryExpression(name));
		field.appendToken(TokenBuilder.newColon());
		field.appendToken(TokenBuilder.newSpace());
		field.addChild(node);
		return field;
	}
	
	/**
	 * @private
	 */
	public static function newFunctionLiteral():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.LAMBDA);
		ast.appendToken(TokenBuilder.newFunction());
		//ast.appendToken(TokenBuilder.newSpace());
		
		var paren:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.PARAMETER_LIST, 
			AS3NodeKind.LPAREN, "(", 
			AS3NodeKind.RPAREN, ")");
		ast.addChild(paren);
		// added, best practices say put :void as default
		
		var colon:LinkedListToken = TokenBuilder.newColon();
		var typeAST:IParserNode = AS3FragmentParser.parseType("void");
		typeAST.startToken.prepend(colon);
		typeAST.startToken = colon;
		ast.addChild(typeAST);
		
		ast.appendToken(TokenBuilder.newSpace());
		var block:IParserNode = ASTStatementBuilder.newBlock();
		ast.addChild(block);
		return ast;
	}
}
}