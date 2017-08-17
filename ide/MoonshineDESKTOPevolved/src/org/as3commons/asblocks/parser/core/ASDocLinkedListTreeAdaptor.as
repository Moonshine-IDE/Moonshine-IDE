package org.as3commons.asblocks.parser.core
{

import org.as3commons.asblocks.parser.api.ASDocNodeKind;

public class ASDocLinkedListTreeAdaptor extends LinkedListTreeAdaptor
{
	public function ASDocLinkedListTreeAdaptor()
	{
		super();
	}
	
	override public function createNode(payload:LinkedListToken):TokenNode 
	{
		var result:TokenNode = new TokenNode(
			payload.kind, 
			payload.text, 
			payload.line, 
			payload.column);
		
		TokenNode(result).token = payload;
		
		TokenNode(result).tokenListUpdater = delegate;
		
		if (payload.kind == ASDocNodeKind.DESCRIPTION)
		{
			TokenNode(result).tokenListUpdater = 
				new ParentheticListUpdateDelegate(
					ASDocNodeKind.ML_START, ASDocNodeKind.ML_END);
		}
		
		if (payload is LinkedListToken) 
		{
			result.startToken = LinkedListToken(payload);
			result.stopToken = LinkedListToken(payload);
		}
		
		return result;
	}
}
}