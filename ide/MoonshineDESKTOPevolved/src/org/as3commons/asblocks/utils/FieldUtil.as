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

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.Visibility;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ASTTypeBuilder;
import org.as3commons.asblocks.impl.FieldNode;
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
public class FieldUtil
{
	public static function getFields(ast:IParserNode):Vector.<IField>
	{
		var result:Vector.<IField> = new Vector.<IField>();
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var member:IParserNode = i.search(AS3NodeKind.FIELD_LIST);
			if (member)
			{
				result.push(new FieldNode(member));
			}
		}
		return result;
	}
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassType#newField()
	 */
	public static function newField(ast:IParserNode,
									name:String, 
									visibility:Visibility, 
									type:String):IField
	{
		if (containsField(ast, name))
		{
			throw new ASBlocksSyntaxError("IField " + name + " already exists on node");
		}
		
		var fieldAST:IParserNode = ASTTypeBuilder.newFieldAST(name, visibility, type);
		var field:IField = new FieldNode(fieldAST);
		addField(ast, field);
		return field;
	}
	
	/**
	 * @private
	 */
	public static function addField(ast:IParserNode, field:IField):void
	{
		ASTUtil.addChildWithIndentation(ast, field.node);
	}
	
	public static function getField(ast:IParserNode, name:String):IField
	{
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FIELD_LIST))
			{
				var field:IField = new FieldNode(member);
				if (field.name == name)
				{
					return field;
				}
			}
		}
		return null;
	}
	
	public static function removeField(ast:IParserNode, name:String):IField
	{
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FIELD_LIST))
			{
				var field:IField = new FieldNode(member);
				if (field.name == name)
				{
					i.remove();
					return field;
				}
			}
		}
		return null;
	}
	
	private static function containsField(ast:IParserNode, name:String):Boolean
	{
		var i:ASTIterator = new ASTIterator(ast);
		while (i.hasNext())
		{
			var member:IParserNode = i.next();
			if (member.isKind(AS3NodeKind.FIELD_LIST))
			{
				var field:IField = new FieldNode(member);
				if (field.name == name)
				{
					return true;
				}
			}
		}
		return false;
	}
}
}