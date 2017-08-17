package org.as3commons.asblocks.parser.impl
{

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.utils.ASTUtil;

public class ASTIterator
{
	private var parent:IParserNode;
	
	private var index:int = -1;
	
	public function get current():IParserNode
	{
		return parent.getChild(index);
	}
	
	public function ASTIterator(parent:IParserNode)
	{
		if (parent == null) 
		{
			//IllegalArgumentException
			throw new Error("null not allowed");
		}
		this.parent = parent;
	}
	
	public function hasNext():Boolean
	{
		return index < parent.numChildren - 1;
	}
	
	public function next(tokenKind:String = null):IParserNode
	{
		if (!hasNext())
		{
			// IllegalStateException
			throw new Error("expected " + ASTUtil.tokenName(tokenKind) + " but reached last child");
		}
		if (tokenKind && parent.getChild(index + 1).kind != tokenKind)
		{
			// IllegalStateException
			throw new Error("expected " + ASTUtil.tokenName(tokenKind) + " but got " + parent.getChild(index + 1));
		}
		
		if (!hasNext()) 
		{
			// NoSuchElementException
			throw new Error();
		}
		
		index++;
		
		return parent.getChild(index);
	}
	
	/**
	 * After a call to remove, another call to next() is required to access
	 * the element following the one just deleted.
	 */
	public function remove():void
	{
		parent.removeChildAt(index);
		index--;
	}
	
	public function replace(replacement:IParserNode):void
	{
		parent.setChildAt(replacement, index);
	}
	
	public function moveTo(index:int):IParserNode
	{
		while (hasNext())
		{
			var ast:IParserNode = next();
			if (this.index == index)
			{
				return ast;
			}
		}
		return null;
	}
	
	public function search(tokenKind:String):IParserNode
	{
		while (hasNext())
		{
			var ast:IParserNode = next();
			if (ast.isKind(tokenKind))
			{
				return ast;
			}
		}
		return null;
	}
	
	public function find(tokenKind:String):IParserNode
	{
		var result:IParserNode = search(tokenKind);
		if (result != null) 
		{
			return result;
		}
		// IllegalStateException
		throw new Error("expected " + ASTUtil.tokenName(tokenKind) + " but not found");
	}
	
	
	public function insertBeforeCurrent(insert:IParserNode):void
	{
		parent.addChildAt(insert, index);
	}
	
	public function insertAfterCurrent(insert:IParserNode):void
	{
		parent.addChildAt(insert, index + 1);
	}
	
	public function get currentIndex():int
	{
		return index;
	}
	
	public function reset(parent:IParserNode = null):void
	{
		if (parent)
		{
			this.parent = parent;
		}
		index = -1;
	}

}
}