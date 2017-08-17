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

package org.as3commons.asblocks.utils
{

import org.as3commons.asblocks.api.Modifier;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.impl.ASTIterator;

/**
 * @private
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ModifierUtil
{
	public static function hasModifierFlag(node:IParserNode, modifier:Modifier):Boolean
	{
		var modList:IParserNode = findModifiers(node);
		if (!modList)
			return false;
		
		var i:ASTIterator = new ASTIterator(modList);
		while (i.hasNext())
		{
			var child:IParserNode = i.next();
			if (child.stringValue == modifier.name)
			{
				return true;
			}
		}
		return false;
	}
	
	public static function setModifierFlag(ast:IParserNode, flag:Boolean, modifier:Modifier):void
	{
		var list:IParserNode = findModifiers(ast);
		if (!list && flag)
		{
			var index:int = ast.hasKind(AS3NodeKind.META_LIST) ? 1 : 0;
			if (ast.hasKind(AS3NodeKind.AS_DOC))
			{
				index++;
			}
			list = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
			ast.addChildAt(list, index);
		}
		
		var i:ASTIterator = new ASTIterator(list);
		while (i.hasNext())
		{
			var child:IParserNode = i.next();
			if (child.stringValue == modifier.name)
			{
				if (flag)
				{
					return; // already has modifier
				}
				else
				{
					i.remove(); // remove the modifier
				}
				return;
			}
		}
		
		if (flag)
		{
			var mod:IParserNode = ASTBuilder.newAST(AS3NodeKind.MODIFIER, modifier.name);
			mod.appendToken(TokenBuilder.newSpace());
			list.addChild(mod);
		}
	}
	
	public static function getVisibility(ast:IParserNode):Visibility
	{
		var modifiers:IParserNode = findModifiers(ast);
		if (!modifiers || modifiers.numChildren == 0)
			return Visibility.DEFAULT;
		
		var i:ASTIterator = new ASTIterator(modifiers);
		var child:IParserNode;
		while (i.hasNext())
		{
			child = i.next();
			if (Visibility.hasVisibility(child.stringValue))
			{
				return Visibility.getVisibility(child.stringValue);
			}
		}
		
		i.reset();
		
		while (i.hasNext())
		{
			child = i.next();
			if (!isReservedModifier(child.stringValue))
			{
				return Visibility.create(child.stringValue);
			}
		}
		
		return null;
	}
	
	private static var modifiers:Array = 
		[
			"override",
			"static",
			"final",
			"dynamic",
			"native"
		];
	
	public static function isReservedModifier(modifier:String):Boolean
	{
		for each (var mod:String in modifiers)
		{
			if (mod == modifier)
				return true;
		}
		return false;
	}
	
	public static function setVisibility(ast:IParserNode, visibility:Visibility):void
	{
		var list:IParserNode = findModifiers(ast);
		var i:ASTIterator;
		
		if (!list && !visibility.equals(Visibility.DEFAULT))
		{
			var index:int = ast.hasKind(AS3NodeKind.META_LIST) ? 1 : 0;
			if (ast.hasKind(AS3NodeKind.AS_DOC))
			{
				index++;
			}
			list = ASTBuilder.newAST(AS3NodeKind.MOD_LIST);
			ast.addChildAt(list, index);
		}
		
		if (visibility.equals(Visibility.DEFAULT))
		{
			i = new ASTIterator(list);
			while (i.hasNext())
			{
				child = i.next();
				if (Visibility.hasVisibility(child.stringValue))
				{
					i.remove(); // remove the visibility
					break;
				}
			}
			if (list.numChildren == 0)
			{
				ast.removeChild(list);
			}
			return;
		}
		
		// chack for existing visibility
		i = new ASTIterator(list);
		while (i.hasNext())
		{
			var child:IParserNode = i.next();
			if (child.stringValue == visibility.name)
				return;
		}
		
		i = new ASTIterator(list);
		while (i.hasNext())
		{
			child = i.next();
			if (Visibility.hasVisibility(child.stringValue))
			{
				i.remove(); // remove the visibility
				break;
			}
		}
		
		var mod:IParserNode = ASTBuilder.newAST(AS3NodeKind.MODIFIER, visibility.name);
		mod.appendToken(TokenBuilder.newSpace());
		if (list.numChildren == 0)
		{
			list.addChild(mod);
		}
		else
		{
			list.addChildAt(mod, 0);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static function findModifiers(node:IParserNode):IParserNode
	{
		return node.getKind(AS3NodeKind.MOD_LIST);
	}
}
}