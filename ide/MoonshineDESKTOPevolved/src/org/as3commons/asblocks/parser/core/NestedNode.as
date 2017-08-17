////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.parser.core
{

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.api.ITokenListUpdateDelegate;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * A parser node that contains parser node children.
 * 
 * <p>Initial API; Adobe Systems, Incorporated</p>
 * 
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
public class NestedNode
{
	public var noUpdate:Boolean = false;
	
	public var tokenListUpdater:ITokenListUpdateDelegate;
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  parent
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _parent:IParserNode;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#parent
	 */
	public function get parent():IParserNode
	{
		return _parent;
	}
	
	/**
	 * @private
	 */	
	public function set parent(value:IParserNode):void
	{
		_parent = value;
	}
	
	//----------------------------------
	//  kind
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _kind:String;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#kind
	 */
	public function get kind():String
	{
		return _kind;
	}
	
	/**
	 * @private
	 */
	public function set kind(value:String):void
	{
		_kind = value;
	}
	
	//----------------------------------
	//  children
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _children:Vector.<IParserNode>;
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#children
	 */
	public function get children():Vector.<IParserNode>
	{
		return _children;
	}
	
	//----------------------------------
	//  numChildren
	//----------------------------------
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#numChildren
	 */
	public function get numChildren():int
	{
		if (_children == null)
			return 0;
		return _children.length;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new Node instance.
	 * 
	 * @param kind A String parser node kind.
	 * @param child The node child.
	 */
	public function NestedNode(kind:String, child:IParserNode)
	{
		_kind = kind;
		
		addChild(child);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#contains()
	 */
	public function contains(node:IParserNode):Boolean
	{
		if (numChildren == 0)
			return false;
		
		var kind:String = node.kind;
		var unique:Vector.<IParserNode> = ASTUtil.getNodes(kind, IParserNode(this));
		if (!unique || unique.length == 0)
			return false;
		
		var len:int = unique.length;
		for (var i:int = 0; i < len; i++)
		{
			if (unique[i] === node)
				return true;
		}
		
		return false;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#isKind()
	 */
	public function isKind(kind:String):Boolean
	{
		if (_kind == kind)
			return true;
		return false;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#hasKind()
	 */
	public function hasKind(kind:String):Boolean
	{
		if (numChildren == 0)
			return false;
		
		var len:int = children.length;
		for (var i:int = 0; i < len; i++)
		{
			if (children[i].isKind(kind))
				return true;
		}
		
		return false;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getChild()
	 */
	public function getChild(index:int):IParserNode
	{
		if (_children == null || _children.length == 0)
			return null;
		
		if (index < 0 || index > _children.length - 1)
			return null;
		
		return _children[index];
	}
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getChildIndex()
	 */
	public function getChildIndex(child:IParserNode):int
	{
		if (numChildren == 0)
			return -1;
		
		var len:int = children.length;
		for (var i:int = 0; i < len; i++)
		{
			if (children[i] === child)
				return i;
		}
		
		return -1;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getKind()
	 */
	public function getKind(kind:String):IParserNode
	{
		if (numChildren == 0)
			return null;
		
		var len:int = children.length;
		for (var i:int = 0; i < len; i++)
		{
			if (children[i].isKind(kind))
				return children[i];
		}
		
		return null;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getFirstChild()
	 */
	public function getFirstChild():IParserNode
	{
		if (_children == null || _children.length == 0)
			return null;
		
		return _children[0];
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#getLastChild()
	 */
	public function getLastChild():IParserNode
	{
		if (_children == null || _children.length == 0)
			return null;
		
		return _children[_children.length - 1];
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addChild()
	 */
	public function addChild(child:IParserNode):IParserNode
	{
		if (child == null)
			return null;
		
		if (_children == null)
			_children = new Vector.<IParserNode>();
		
		_children.push(child);
		
		if (child)
			child.parent = this as IParserNode;
		
		if (!noUpdate && tokenListUpdater)
		{
			tokenListUpdater.addedChild(this as IParserNode, child);
		}
		
		return child;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addChildAt()
	 */
	public function addChildAt(child:IParserNode, index:int):IParserNode
	{
		if (child == null)
			return null;
		
		if (index > numChildren)
			index = numChildren;
		
		if (_children == null)
			_children = new Vector.<IParserNode>();
		
		_children.splice(index, 0, child);
		
		if (child)
			child.parent = this as IParserNode;
		
		if (!noUpdate && tokenListUpdater)
		{
			tokenListUpdater.addedChildAt(this as IParserNode, index, child);
		}
		
		return child;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeKind()
	 */
	public function removeKind(kind:String):Boolean
	{
		if (!hasKind(kind))
			return false;
		
		var len:int = children.length;
		for (var i:int = 0; i < len; i++)
		{
			if (children[i].isKind(kind))
			{
				children.splice(i, 1);
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeChild()
	 */
	public function removeChild(node:IParserNode):IParserNode
	{
		if (numChildren == 0)
			return null;
		
		var len:int = children.length;
		for (var i:int = 0; i < len; i++)
		{
			if (children[i] === node)
			{
				children.splice(i, 1);
				
				if (!noUpdate && tokenListUpdater)
				{
					tokenListUpdater.deletedChild(this as IParserNode, i, node);
					node.parent = null
				}
				return node;
			}
		}
		
		return null;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#removeChildAt()
	 */
	public function removeChildAt(index:int):IParserNode
	{
		if (numChildren == 0)
			return null;
		
		var old:IParserNode = getChild(index);
		children.splice(index, 1);
		
		if (!noUpdate && tokenListUpdater)
		{
			tokenListUpdater.deletedChild(this as IParserNode, index, old);
			old.parent = null
		}
		
		return old;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#setChildAt()
	 */
	public function setChildAt(child:IParserNode, index:int):IParserNode
	{
		if (child == null)
			return null;
		
		if (index > numChildren)
			index = numChildren;
		
		if (_children == null)
			_children = new Vector.<IParserNode>();
		
		var old:IParserNode = getChild(index);
		if (old)
			old.parent = null;
		_children.splice(index, 1, child) as IParserNode;
		
		if (!noUpdate && tokenListUpdater)
		{
			tokenListUpdater.replacedChild(IParserNode(this), index, child, old);
		}
		
		return old;
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#addTokenAt()
	 */
	public function addTokenAt(token:LinkedListToken, index:int):void
	{
		tokenListUpdater.addToken(IParserNode(this), index, token);
	}
	
	/**
	 * @copy org.as3commons.as3parser.api.IParserNode#appendToken()
	 */
	public function appendToken(token:LinkedListToken):void
	{
		if (!noUpdate && tokenListUpdater)
		{
			tokenListUpdater.appendToken(IParserNode(this), token);
		}
	}
	
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function addRawChild(kind:String,
								line:int,
								column:int,
								stringValue:String):IParserNode
	{
		return addChild(Node.create(kind, line, column, stringValue));
	}
	
	/**
	 * @private
	 */
	public function addNodeChild(kind:String,
								 line:int,
								 column:int,
								 sibling:IParserNode):IParserNode
	{
		var node:IParserNode = Node.create(kind, line, column, null);
		node.addChild(sibling);
		return addChild(node);
	}
}
}