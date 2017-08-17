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

package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.IContentBlock;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * The <code>IContentBlock</code> implementation and abstract base class for the
 * <code>ClassTypeNode</code>, <code>InterfaceTypeNode</code> and
 * <code>FunctionTypeNode</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ContentBlockNode extends ScriptNode implements IContentBlock
{
	//--------------------------------------------------------------------------
	//
	//  IContentBlock API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  methods
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IContentBlock#methods
	 */
	public function get methods():Vector.<IMethod>
	{
		var result:Vector.<IMethod> = new Vector.<IMethod>();
		var i:ASTIterator = new ASTIterator(findContent());
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FUNCTION)
				|| member.isKind(AS3NodeKind.GET)
				|| member.isKind(AS3NodeKind.SET))
			{
				result.push(new MethodNode(member));
			}
		}
		return result;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ContentBlockNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  IContentBlock API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IContentBlock#newMethod()
	 */
	public function newMethod(name:String, 
							  visibility:Visibility, 
							  returnType:String):IMethod
	{
		return null;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IContentBlock#getMethod()
	 */
	public function getMethod(name:String):IMethod
	{
		var i:ASTIterator = new ASTIterator(findContent());
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FUNCTION)
				|| member.isKind(AS3NodeKind.GET)
				|| member.isKind(AS3NodeKind.SET))
			{
				var meth:IMethod = new MethodNode(member);
				if (meth.name == name)
				{
					return meth;
				}
			}
		}
		return null;
	}
	
	/**
	 * @private
	 * FIXME (mschmalle) add IContentBlock#addMethod() to public api ?
	 */
	public function addMethod(method:IMethod):void
	{
		ASTUtil.addChildWithIndentation(findContent(), method.node);
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IContentBlock#removeMethod()
	 */
	public function removeMethod(name:String):IMethod
	{
		var i:ASTIterator = new ASTIterator(findContent());
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FUNCTION)
				|| member.isKind(AS3NodeKind.GET)
				|| member.isKind(AS3NodeKind.SET))
			{
				var meth:IMethod = new MethodNode(member);
				if (meth.name == name)
				{
					i.remove();
					return meth;
				}
			}
		}
		return null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected function findContent():IParserNode
	{
		return node.getKind(AS3NodeKind.CONTENT);
	}
}
}