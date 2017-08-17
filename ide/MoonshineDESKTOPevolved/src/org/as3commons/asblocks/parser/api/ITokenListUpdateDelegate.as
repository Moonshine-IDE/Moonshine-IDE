package org.as3commons.asblocks.parser.api
{

import org.as3commons.asblocks.parser.core.LinkedListToken;

public interface ITokenListUpdateDelegate
{
	function addedChild(parent:IParserNode, 
						child:IParserNode):void;
	
	function addedChildAt(parent:IParserNode, 
						  index:int, 
						  child:IParserNode):void;
	
	function appendToken(parent:IParserNode, 
						 append:LinkedListToken):void;
	
	function addToken(parent:IParserNode, 
					  index:int, 
					  append:LinkedListToken):void;
	
	function deletedChild(parent:IParserNode, 
						  index:int, 
						  child:IParserNode):void;
	
	function replacedChild(tree:IParserNode, 
						   index:int, 
						   child:IParserNode, 
						   oldChild:IParserNode):void;
}
}