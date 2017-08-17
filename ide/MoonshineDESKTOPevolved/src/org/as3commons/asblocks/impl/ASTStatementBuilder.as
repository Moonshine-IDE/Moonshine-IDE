package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.IArgument;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.impl.AS3FragmentParser;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTStatementBuilder
{
	public static function newBlock(kind:String = null):IParserNode
	{
		if (!kind)
		{
			kind = AS3NodeKind.BLOCK;
		}
		
		var ast:IParserNode = ASTUtil.newParentheticAST(
			kind, 
			AS3NodeKind.LCURLY, "{", 
			AS3NodeKind.RCURLY, "}");
		var nl:LinkedListToken = TokenBuilder.newNewline();
		// insert the \n after the {
		ast.initialInsertionAfter.append(nl);
		// set new insertion point after \n
		ast.initialInsertionAfter = nl;
		return ast;
	}
	
	public static function newBreak(label:String = null):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.BREAK, "break");
		if (label)
		{
			ast.appendToken(TokenBuilder.newSpace());
			ast.addChild(ASTBuilder.newPrimaryAST(label));
		}
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newCatchClause(name:String, type:String):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.CATCH, "catch");
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newLParen());
		ast.addChild(ASTBuilder.newNameAST(name));
		if (type)
		{
			ast.appendToken(TokenBuilder.newColon());
			ast.addChild(ASTBuilder.newTypeAST(type));
		}
		ast.appendToken(TokenBuilder.newRParen());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(newBlock());
		return ast;
	}
	
	public static function newContinue(label:String = null):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.CONTINUE, "continue");
		if (label)
		{
			ast.appendToken(TokenBuilder.newSpace());
			ast.addChild(ASTBuilder.newPrimaryAST(label));
		}
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newDeclaration(assignment:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.DEC_LIST);
		var role:IParserNode = ASTBuilder.newAST(AS3NodeKind.DEC_ROLE, "var");
		ast.addChild(role);
		if (assignment)
		{
			ast.appendToken(TokenBuilder.newSpace());
			ast.addChild(assignment);
		}
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newDefaultXMLNamespace(namespace:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.XML_NAMESPACE);
		ast.appendToken(TokenBuilder.newDefault());
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newXML());
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newNamespace());
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newAssign());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(namespace);
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newDoWhile(condition:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.DO, "do");
		ast.appendToken(TokenBuilder.newSpace());
		var block:IParserNode = newBlock();
		ast.addChild(block);
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newWhile());
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newCondition(condition));
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newFinallyClause():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FINALLY, "finally");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(newBlock());
		return ast;
	}
	
	public static function newForEachIn(declaration:IParserNode, 
										target:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FOREACH, "for");
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newEach());
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newLParen());
		var initAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.INIT);
		initAST.addChild(declaration);
		ast.addChild(initAST);
		ast.appendToken(TokenBuilder.newSpace());
		var inAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.IN, "in");
		inAST.appendToken(TokenBuilder.newSpace());
		inAST.addChild(target);
		ast.addChild(inAST);
		ast.appendToken(TokenBuilder.newRParen());
		return ast;
	}
	
	public static function newForIn(declaration:IParserNode, 
									target:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FORIN, "for");
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newLParen());
		var initAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.INIT);
		initAST.addChild(declaration);
		ast.addChild(initAST);
		ast.appendToken(TokenBuilder.newSpace());
		var inAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.IN, "in");
		inAST.appendToken(TokenBuilder.newSpace());
		inAST.addChild(target);
		ast.addChild(inAST);
		ast.appendToken(TokenBuilder.newRParen());
		return ast;
	}
	
	public static function newLabel(ast:IParserNode):IParserNode
	{
		var result:IParserNode = ASTBuilder.newAST(AS3NodeKind.LABEL);
		result.addChild(ast);
		result.appendToken(TokenBuilder.newSpace());
		result.appendToken(TokenBuilder.newColon());
		result.appendToken(TokenBuilder.newSpace());
		result.addChild(newBlock());
		return result;
	}
	
	public static function newForLabel(ast:IParserNode, kind:String):IParserNode
	{
		var result:IParserNode = ASTBuilder.newAST(AS3NodeKind.LABEL);
		result.addChild(ast);
		result.appendToken(TokenBuilder.newSpace());
		result.appendToken(TokenBuilder.newColon());
		result.appendToken(TokenBuilder.newSpace());
		if (kind == AS3NodeKind.FOR)
		{
			result.addChild(newFor(null, null, null));
		}
		
		return result;
	}
	
	public static function newFor(initializer:IParserNode, 
								  condition:IParserNode, 
								  iterator:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.FOR, "for");
		
		ast.appendToken(TokenBuilder.newSpace());
		ast.appendToken(TokenBuilder.newLParen());
		
		ast.addChild(newForInit(initializer));
		
		ast.appendToken(TokenBuilder.newSemi());
		ast.appendToken(TokenBuilder.newSpace());
		
		ast.addChild(newForCond(condition));
		
		ast.appendToken(TokenBuilder.newSemi());
		ast.appendToken(TokenBuilder.newSpace());
		
		ast.addChild(newForIter(iterator));
		
		ast.appendToken(TokenBuilder.newRParen());
		return ast;
	}
	
	public static function newForInit(initializer:IParserNode):IParserNode
	{
		if (!initializer)
			return ASTBuilder.newAST(AS3NodeKind.INIT);
		
		var ast:IParserNode = initializer;
		// check that node is init
		if (!initializer.isKind(AS3NodeKind.INIT))
		{
			ast = ASTBuilder.newAST(AS3NodeKind.INIT);
			ast.addChild(initializer);
		}
		return ast;
	}
	
	public static function newForCond(condition:IParserNode):IParserNode
	{
		if (!condition)
			return ASTBuilder.newAST(AS3NodeKind.COND);
		
		var ast:IParserNode = condition;
		// check that node is cond
		if (!condition.isKind(AS3NodeKind.COND))
		{
			ast = ASTBuilder.newAST(AS3NodeKind.COND);
			ast.addChild(condition);
		}
		return ast;
	}
	
	public static function newForIter(iterator:IParserNode):IParserNode
	{
		if (!iterator)
			return ASTBuilder.newAST(AS3NodeKind.ITER);
		
		var ast:IParserNode = iterator;
		// check that node is iter
		if (!iterator.isKind(AS3NodeKind.ITER))
		{
			ast = ASTBuilder.newAST(AS3NodeKind.ITER);
			ast.addChild(iterator);
		}
		return ast;
	}
	
	public static function newIf(ast:IParserNode):IParserNode
	{
		var ifStmnt:IParserNode = ASTBuilder.newAST(AS3NodeKind.IF, "if");
		ifStmnt.appendToken(TokenBuilder.newSpace());
		ifStmnt.addChild(ASTBuilder.newCondition(ast));
		ifStmnt.appendToken(TokenBuilder.newSpace());
		ifStmnt.addChild(newBlock());
		
		return ifStmnt;
	}
	
	public static function newReturn(expression:IParserNode = null):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.RETURN, "return");
		if (expression)
		{
			ast.appendToken(TokenBuilder.newSpace());
			ast.addChild(expression);
		}
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newSuper(arguments:Vector.<IExpression>):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.SUPER, "super");
		var callAST:IParserNode = ASTBuilder.newAST(AS3NodeKind.CALL);
		callAST.addChild(ASTBuilder.newAST(AS3NodeKind.PRIMARY));
		var argumentAST:IParserNode = ASTUtil.newParentheticAST(
			AS3NodeKind.ARGUMENTS, 
			AS3NodeKind.LPAREN, "(", 
			AS3NodeKind.RPAREN, ")");
		if (argumentAST != null)
		{
			callAST.addChild(argumentAST);
		}
		ast.addChild(callAST);
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newSwitch(condition:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.SWITCH, "switch");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newCondition(condition));
		ast.appendToken(TokenBuilder.newSpace());
		var block:IParserNode = newBlock(AS3NodeKind.CASES);
		ast.addChild(block);
		return ast;
	}
	
	public static function newSwitchCase(node:IParserNode, label:String):IParserNode
	{
		var cases:IParserNode = node.getKind(AS3NodeKind.CASES);
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.CASE, "case");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(AS3FragmentParser.parseExpression(label));
		ast.appendToken(TokenBuilder.newColon());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.SWITCH_BLOCK));
		ASTUtil.addChildWithIndentation(cases, ast);
		return ast;
	}
	
	public static function newSwitchDefault(node:IParserNode):IParserNode
	{
		var cases:IParserNode = node.getKind(AS3NodeKind.CASES);
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.DEFAULT, "default");
		ast.appendToken(TokenBuilder.newColon());
		ast.addChild(ASTBuilder.newAST(AS3NodeKind.SWITCH_BLOCK));
		ASTUtil.addChildWithIndentation(cases, ast);
		return ast;
	}
	
	public static function newThis(expression:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.THIS, "this");
		ast.appendToken(TokenBuilder.newDot());
		ast.addChild(expression);
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newThrow(expression:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.THROW, "throw");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(expression);
		ast.appendToken(TokenBuilder.newSemi());
		return ast;
	}
	
	public static function newTryStatement():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.TRY_STMNT);
		ast.addChild(newTry());
		return ast;
	}
	
	public static function newTry():IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.TRY, "try");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(newBlock());
		return ast;
	}
	
	public static function newWhile(condition:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.WHILE, "while");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newCondition(condition));
		var block:IParserNode = newBlock();
		ast.addChild(block);
		return ast;
	}
	
	public static function newWith(condition:IParserNode):IParserNode
	{
		var ast:IParserNode = ASTBuilder.newAST(AS3NodeKind.WITH, "with");
		ast.appendToken(TokenBuilder.newSpace());
		ast.addChild(ASTBuilder.newCondition(condition));
		var block:IParserNode = newBlock();
		ast.addChild(block);
		return ast;
	}
}
}