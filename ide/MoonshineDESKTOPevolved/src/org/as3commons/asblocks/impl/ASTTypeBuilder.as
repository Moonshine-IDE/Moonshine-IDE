package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTTypeBuilder
{
	public static function newClassCompilationUnit(qualifiedName:String):ICompilationUnit
	{
		return new CompilationUnitNode(newClassCompilationUnitAST(qualifiedName));
	}
	
	public static function newClassCompilationUnitAST(qualifiedName:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.COMPILATION_UNIT);
		var past:IParserNode = ASTBuilder.newAST(AS3NodeKind.PACKAGE, "package");
		
		//past.appendToken(TokenBuilder.newSpace());
		ast.addChild(past);
		past.appendToken(TokenBuilder.newSpace());
		
		var packageName:String = packageNameFrom(qualifiedName);
		if (packageName)
		{
			past.addChild(AS3FragmentParser.parseName(packageName));
			past.appendToken(TokenBuilder.newSpace());
		}
		
		var block:IParserNode = ASTStatementBuilder.newBlock(AS3NodeKind.CONTENT);
		past.addChild(block);
		
		var className:String = typeNameFrom(qualifiedName);
		var clazz:IParserNode = newClassAST(className);
		ASTUtil.addChildWithIndentation(block, clazz);
		
		return ast;
	}
	
	public static function newClassAST(className:String, addModList:Boolean = true):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.CLASS);
		if (addModList)
		{
			var mods:IParserNode = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
			var mod:IParserNode = ASTBuilder.newAST(AS3NodeKind.MODIFIER, "public");
			mod.appendToken(TokenBuilder.newSpace());
			mods.addChild(mod);
			ast.addChild(mods);
		}
		ast.appendToken(TokenBuilder.newClass());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.NAME, className));
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTStatementBuilder.newBlock(AS3NodeKind.CONTENT));
		return ast;
	}
	
	public static function newInterfaceCompilationUnit(qualifiedName:String):ICompilationUnit
	{
		return new CompilationUnitNode(newInterfaceCompilationUnitAST(qualifiedName));
	}
	
	public static function newInterfaceCompilationUnitAST(qualifiedName:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.COMPILATION_UNIT);
		var past:IParserNode = ASTBuilder.newAST(AS3NodeKind.PACKAGE, "package");
		
		ast.addChild(past);
		past.appendToken(TokenBuilder.newSpace());
		
		var packageName:String = packageNameFrom(qualifiedName);
		if (packageName)
		{
			past.addChild(AS3FragmentParser.parseName(packageName));
			past.appendToken(TokenBuilder.newSpace());
		}
		
		var block:IParserNode = ASTStatementBuilder.newBlock(AS3NodeKind.CONTENT);
		past.addChild(block);
		
		var interfaceName:String = typeNameFrom(qualifiedName);
		var interfaze:IParserNode = newInterfaceAST(interfaceName);
		ASTUtil.addChildWithIndentation(block, interfaze);
		
		return ast;
	}
	
	private static function newInterfaceAST(name:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.INTERFACE);
		//var metas:IParserNode = ASTUtil.newAST(AS3NodeKind.META_LIST);
		//ast.addChild(metas);
		var mods:IParserNode = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
		var mod:IParserNode = ASTBuilder.newAST(AS3NodeKind.MODIFIER, "public");
		mod.appendToken(TokenBuilder.newSpace());
		mods.addChild(mod);
		ast.addChild(mods);
		ast.appendToken(TokenBuilder.newInterface());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.NAME, name));
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTStatementBuilder.newBlock(AS3NodeKind.CONTENT));
		return ast;
	}
	
	public static function newFunctionCompilationUnit(qualifiedName:String, 
													  returnType:String):ICompilationUnit
	{
		var ast:IParserNode = newFunctionCompilationUnitAST(qualifiedName, returnType);
		return new CompilationUnitNode(ast);
	}
	
	public static function newFunctionCompilationUnitAST(qualifiedName:String, 
														 returnType:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.COMPILATION_UNIT);
		var past:IParserNode = ASTBuilder.newAST(AS3NodeKind.PACKAGE, "package");
		
		ast.addChild(past);
		past.appendToken(TokenBuilder.newSpace());
		
		var packageName:String = packageNameFrom(qualifiedName);
		if (packageName)
		{
			past.addChild(AS3FragmentParser.parseName(packageName));
			past.appendToken(TokenBuilder.newSpace());
		}
		
		var block:IParserNode = ASTStatementBuilder.newBlock(AS3NodeKind.CONTENT);
		past.addChild(block);
		
		var functionName:String = typeNameFrom(qualifiedName);
		var func:IParserNode = ASTFunctionBuilder.newFunctionAST(functionName, returnType);
		ASTUtil.addChildWithIndentation(block, func);
		
		return ast;
	}
	
	public static function newFieldAST(name:String, 
									   visibility:Visibility, 
									   type:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FIELD_LIST);
		// field-list/mod-list
		var mods:IParserNode = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
		var mod:IParserNode = ASTBuilder.newAST(AS3NodeKind.MODIFIER, visibility.name);
		mods.addChild(mod);
		mod.appendToken(TokenBuilder.newSpace());
		ast.addChild(mods);
		// field-list/field-role
		var frole:IParserNode = ASTBuilder.newAST(AS3NodeKind.FIELD_ROLE);
		frole.addChild(ASTBuilder.newAST(AS3NodeKind.VAR, "var"));
		ast.addChild(frole);
		ast.appendToken(TokenBuilder.newSpace());
		// field-list/name-type-init
		var nti:IParserNode = ASTBuilder.newAST(AS3NodeKind.NAME_TYPE_INIT);
		ast.addChild(nti);
		// field-list/name-type-init/name
		nti.addChild(ASTBuilder.newNameAST(name));
		if (type)
		{
			// field-list/name-type-init/type
			nti.appendToken(TokenBuilder.newColon());
			nti.addChild(AS3FragmentParser.parseType(type));
		}
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newMethodAST(name:String, 
										visibility:Visibility, 
										returnType:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FUNCTION);
		var mods:IParserNode = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
		mods.addChild(ASTBuilder.newAST(AS3NodeKind.MODIFIER, visibility.name));
		ast.addChild(mods);
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newFunction());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.ACCESSOR_ROLE));
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
	
	public static function newInterfaceMethodAST(name:String,
												 returnType:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FUNCTION);
		ast.appendToken(TokenBuilder.newFunction());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.ACCESSOR_ROLE));
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
		ast.appendToken(TokenBuilder.newSemi());
		
		return ast;
	}
	
	public static function packageNameFrom(qualifiedName:String):String
	{
		var p:int = qualifiedName.lastIndexOf(".");
		if (p == -1) 
		{
			return null;
		}
		return qualifiedName.substring(0, p);
	}
	
	public static function typeNameFrom(qualifiedName:String):String
	{
		var p:int = qualifiedName.lastIndexOf('.');
		if (p == -1) 
		{
			return qualifiedName;
		}
		return qualifiedName.substring(p + 1);
	}
}
}