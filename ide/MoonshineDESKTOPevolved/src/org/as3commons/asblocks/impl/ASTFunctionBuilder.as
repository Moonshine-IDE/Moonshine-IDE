package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTFunctionBuilder
{
	
	public static function newParameter(name:String, type:String, defaultValue:String):IParserNode
	{
		var ast:IParserNode = newParamterAST();
		var nti:IParserNode = ast.getKind(AS3NodeKind.NAME_TYPE_INIT);
		
		var nameAST:IParserNode = ASTBuilder.newNameAST(name);
		nti.addChild(nameAST);
		
		var typeAST:IParserNode = ASTBuilder.parseTypeAST(type);
		nti.addChild(typeAST);
		
		if (defaultValue != null)
		{
			nti.appendToken(TokenBuilder.newSpace());
			nti.appendToken(TokenBuilder.newAssign());
			nti.appendToken(TokenBuilder.newSpace());
			
			var defaultAST:IParserNode = newParameterInit(defaultValue);
			nti.addChild(defaultAST);
		}
		
		return ast;
	}
	
	public static function newParamterAST():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.PARAMETER);
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.NAME_TYPE_INIT));
		return ast;
	}
	
	public static function newParameterInit(defaultValue:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.INIT);
		var init:IParserNode = AS3FragmentParser.parsePrimaryExpression(defaultValue);
		ast.addChild(init);
		return ast;
	}
	
	public static function newRestParameter(name:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.PARAMETER);
		var restAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.REST, name);
		ast.addChild(restAST);
		var rest:LinkedListToken = TokenBuilder.newToken(AS3NodeKind.REST_PARM, "...");
		ast.startToken.prepend(rest);
		ast.startToken = rest;
		return ast;
	}
	
	public static function newFunctionAST(name:String, 
										  returnType:String, 
										  addModList:Boolean = true):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FUNCTION);
		if (addModList)
		{
			var mods:IParserNode = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
			mods.addChild(ASTBuilder.newAST(AS3NodeKind.MODIFIER, Visibility.PUBLIC.toString()));
			ast.addChild(mods);
		}
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.ACCESSOR_ROLE));
		if (addModList)
		{
			ast.appendToken(TokenBuilder.newSpace());
		}
		ast.appendToken(TokenBuilder.newFunction());
		ast.appendToken(TokenBuilder.newSpace());
		var n:IParserNode = ASTBuilder.newAST(AS3NodeKind.NAME, name);
		ast.addChild(n);
		var params:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.PARAMETER_LIST,
			AS3NodeKind.LPAREN, "(",
			AS3NodeKind.RPAREN, ")");
		ast.addChild(params);
		if (returnType)
		{
			var colon:LinkedListToken = TokenBuilder.newColon();
			var typeAST:IParserNode = AS3FragmentParser.parseType(returnType);
			typeAST.startToken.prepend(colon);
			typeAST.startToken = colon;
			ast.addChild(typeAST);
		}
		ast.appendToken(TokenBuilder.newSpace());
		var block:IParserNode = ASTStatementBuilder.newBlock();
		ast.addChild(block);
		return ast;
	}
}
}