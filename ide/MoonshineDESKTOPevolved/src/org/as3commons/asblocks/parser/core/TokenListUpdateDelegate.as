package org.as3commons.asblocks.parser.core
{

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ITokenListUpdateDelegate;

/**
 * Manages the tokens of the parent tree in the most basic way possible, simply
 * inserting the run of tokens belonging to the child into the run of tokens
 * belonging to the parent and updating start/stop tokens for the parent if
 * required.
 */

public class TokenListUpdateDelegate implements ITokenListUpdateDelegate
{
	public function TokenListUpdateDelegate()
	{
	}
	
	public function addedChild(parent:IParserNode, 
							   child:IParserNode):void
	{
		if (isPlaceholder(parent)) 
		{
			if (isPlaceholder(child)) 
			{
				throw new Error("The parent node");
				//throw new Error("The parent node ("+ASTUtils.tokenName(parent)+") has only a placeholder token, so a child which also has only a placeholder token ("+ASTUtils.tokenName(child)+") can't be added yet");
			}
			var placeholder:LinkedListToken = parent.startToken;
			if (placeholder.previous != null) 
			{
				placeholder.previous.next = child.startToken;
			}
			if (placeholder.next != null) 
			{
				placeholder.next.previous = child.stopToken;
			}
			parent.startToken = child.startToken;
			parent.stopToken = child.stopToken;
			return;
		}
		
		var stop:LinkedListToken = findTokenInsertionPointForChildWithinParent(parent, child);
		if (!parent.startToken)
		{
			parent.startToken = child.startToken;
		}
		if (stop) 
		{
			insertAfter(stop, stop.next, child.startToken, child.stopToken);
		}
		if (child.stopToken) {
			parent.stopToken = child.stopToken;
		}
		
	}
	
	public function addedChildAt(parent:IParserNode, 
								 index:int, 
								 child:IParserNode):void
	{
		var target:LinkedListToken;
		var targetNext:LinkedListToken;
		if (index == 0) 
		{
			var prevFirstChild:IParserNode = parent.getChild(1);
			targetNext = prevFirstChild.startToken;
			target = targetNext.previous;
			if (targetNext == parent.startToken) 
			{
				parent.startToken = child.startToken;
			}
		} 
		else 
		{
			target = parent.getChild(index - 1).stopToken;
			targetNext = target.next;
		}
		
		insertAfter(target, targetNext,	child.startToken, child.stopToken);
	}
	
	
	protected static function insertAfter(target:LinkedListToken, 
										  targetNext:LinkedListToken,
										  start:LinkedListToken, 
										  stop:LinkedListToken):void
	{
		if (target == null && targetNext == null) 
		{
			throw new Error("At least one of target and targetNext must be non-null");
		}
		if (start != null) 
		{
			//			if (start.getPrev() != null || stop.getNext() != null) {
			//				throw new IllegalArgumentException("insertAfter("+target+", "+targetNext+", "+start+", "+stop+") : start.getPrev()="+start.getPrev()+" stop.getNext()="+stop.getNext());
			//			}
			// i.e. we're not adding an imaginary node that currently
			//      has no real children
			if (target != null) {
				target.next = start;
			}
			stop.next = targetNext;
			if (targetNext != null) {
				targetNext.previous = stop;
			}
		}
	}
	
	
	private function isPlaceholder(ast:IParserNode):Boolean
	{
		return ast.startToken == ast.stopToken
			&& ast.startToken != null
			&& ast.startToken.kind == "virtual-placeholder"
			&& PlaceholderLinkedListToken(ast.startToken).held == ast;
	}
	
	private function findTokenInsertionPointForChildWithinParent(parent:IParserNode, 
																 child:IParserNode):LinkedListToken 
	{
		// this fails to take into account am ancestor not
		// having the same kind of TreeTokenListUpdateDelegate
		while (parent != null) 
		{
			if (parent.numChildren == 1) 
			{
				// the just-added child is the only child of 'parent'
				if (parent.stopToken != null) 
				{
					return parent.stopToken;
				}
				if (parent.startToken != null) 
				{
					return parent.startToken;
				}
			}
			var index:int = parent.getChildIndex(child);
			
			if (index > 0 && index < parent.numChildren - 1) 
			{
				// 'child' is not the *first* child of 'parent'
				var precedent:IParserNode = parent.getChild(index - 1);
				if (precedent.stopToken == null) 
				{
					return findTokenInsertionPointForChildWithinParent(parent, precedent);
				}
				return precedent.stopToken;
			}
			if (index == 0 && parent.startToken != null) 
			{
				return parent.startToken;
			}
			if (parent.stopToken != null) 
			{
				return parent.stopToken;
			}
			
			child = parent;
			
			parent = parent.parent;
		}
		return null;
	}
	
	public function appendToken(parent:IParserNode, 
								append:LinkedListToken):void
	{
		if (parent.stopToken == null) 
		{
			parent.startToken = append;
			parent.stopToken = append;
		} 
		else 
		{
			append.next = parent.stopToken.next;
			parent.stopToken.next = append;
			append.previous = parent.stopToken;
			parent.stopToken = append;
		}
		
	}
	
	public function addToken(parent:IParserNode, 
							 index:int, 
							 append:LinkedListToken):void
	{
		if (isPlaceholder(parent)) 
		{
			var placeholder:LinkedListToken = parent.startToken;
			parent.startToken = append;
			parent.stopToken = append;
			placeholder.previous = null;
			placeholder.next = null;
		}
		if (parent.stopToken == null) 
		{
			parent.startToken = append;
			parent.stopToken = append;
		} 
		else 
		{
			var target:LinkedListToken;
			var targetNext:LinkedListToken;
			if (index == 0) 
			{
				targetNext = parent.startToken;
				target = targetNext.previous;
				parent.startToken = append;
			} 
			else if (index == parent.numChildren) 
			{
				target = parent.stopToken;
				targetNext = target.next;
				parent.stopToken = append;
			} 
			else 
			{
				var beforeChild:IParserNode = parent.getChild(index);
				targetNext = beforeChild.startToken;
				target = targetNext.previous;
			}
			insertAfter(target, targetNext, append, append);
		}
		
	}
	
	public function deletedChild(parent:IParserNode, 
								 index:int, 
								 child:IParserNode):void
	{
		// this should update start/stop tokens for the parent
		//        when the first/last child is removed
		var start:LinkedListToken = child.startToken;
		var stop:LinkedListToken = child.stopToken;
		var startPrev:LinkedListToken = start.previous;
		var stopNext:LinkedListToken = stop.next;
		//		if (startPrev == null) {
		//			throw new IllegalArgumentException("No start.prev: "+child);
		//		}
		//		if (stopNext == null) {
		//			throw new IllegalArgumentException("No stop.next: "+child+" (stop="+stop+")");
		//		}
		if (parent.numChildren == 0
			&& start == parent.startToken
			&& stop == parent.stopToken)
		{
			// So, the child provided all the tokens that made up
			// the parent, and removing it will leave nothing!  In
			// this case, we insert a 'placeholder' token just so
			// there's something in the token stream for the parent
			// to reference, and the parent remains anchored to the
			// appropriate location within the source code
			var placeholder:LinkedListToken// = TokenBuilder.newPlaceholder(parent);
			startPrev.next = placeholder;
			stopNext.previous = placeholder;
		} 
		else 
		{
			if (startPrev != null) 
			{
				startPrev.next = stopNext;
			} 
			else if (stopNext != null)
			{  // so try the other way around,
				stopNext.previous = startPrev;
			}
			if (parent.startToken == start) 
			{
				parent.startToken = stopNext;
			}
			if (parent.stopToken == stop) 
			{
				parent.stopToken = startPrev;
			}
		}
		// just to save possible confusion, break links out from the
		// removed token list too,
		start.previous = null;
		stop.next = null;
		
	}
	
	public function replacedChild(tree:IParserNode, 
								  index:int, 
								  child:IParserNode, 
								  oldChild:IParserNode):void
	{
		// defensive assertions to catch bugs,
		if (child.startToken == null) {
			throw new Error("No startToken: "+child);
		}
		if (child.stopToken == null) {
			throw new Error("No stopToken: "+child);
		}
		// link the new child's tokens in place of the old,
		var oldBefore:LinkedListToken = findOldBeforeToken(tree, index, child, oldChild);
		var oldAfter:LinkedListToken = findOldAfterToken(tree, index, child, oldChild);
		if (oldBefore != null) 
		{
			oldBefore.next = child.startToken;
		}
		if (oldAfter != null) 
		{
			oldAfter.previous = child.stopToken;
		}
		// just to save possible confusion, break links out from the
		// removed token list too,
		oldChild.startToken.previous = null;
		oldChild.stopToken.next = null;
		
		if (tree.startToken == oldChild.startToken)
		{
			tree.startToken = child.startToken;
		}
		if (tree.stopToken == oldChild.stopToken)
		{
			tree.stopToken = child.stopToken;
		}
	}
	
	private function findOldBeforeToken(tree:IParserNode, 
										index:int, 
										child:IParserNode, 
										oldChild:IParserNode):LinkedListToken
	{
		var oldStart:LinkedListToken = oldChild.startToken;
		if (oldStart == null) 
		{
			throw new Error("<"+oldChild+">, child "+index+" of <"+tree+">, had no startToken");
		}
		return oldStart.previous;
	}
	
	private function findOldAfterToken(tree:IParserNode, 
									   index:int, 
									   child:IParserNode, 
									   oldChild:IParserNode):LinkedListToken
	{
		var oldStop:LinkedListToken = oldChild.stopToken;
		if (oldStop == null) 
		{
			throw new Error("<"+oldChild+">, child "+index+" of <"+tree+">, had no stopToken");
		}
		return oldStop.next;
	}
	
	
}
}