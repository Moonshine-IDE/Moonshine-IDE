package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.parser.core.SourceCode;

public class ASTPrinter
{
	private var sourceCode:ISourceCode;
	
	public function ASTPrinter(sourceCode:ISourceCode)
	{
		this.sourceCode = sourceCode;
	}
	
	public function print(ast:IParserNode):void
	{
		for (var tok:LinkedListToken = findStart(ast); tok != null; tok = tok.next)
		{
			printLn(tok);
		}
	}
	
	private function findStart(ast:IParserNode):LinkedListToken
	{
		var result:LinkedListToken = null;
		
		for (var tok:LinkedListToken = ast.startToken; viable(tok); tok = tok.previous)
		{
			result = tok;
		}
		return result;
	}
	
	private function printLn(token:LinkedListToken):void
	{
		if (!sourceCode.code)
			sourceCode.code = "";
		
		if (token.text != null)
			sourceCode.code += token.text;
	}
	
	private function viable(token:LinkedListToken):Boolean
	{
		return token != null && token.kind != "__END__";
	}
	
	public function flush():String
	{
		var result:String = toString();
		sourceCode.code = null;
		return result;
	}
	
	public function toString():String
	{
		return sourceCode.code;
	}
}
}