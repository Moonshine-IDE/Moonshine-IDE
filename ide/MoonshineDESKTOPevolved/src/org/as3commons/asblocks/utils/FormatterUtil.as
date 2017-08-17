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

import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.api.IScriptNode;
import org.as3commons.asblocks.impl.TokenBuilder;

/**
 * @private
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class FormatterUtil
{
	public static function breakParentheticNode(element:IScriptNode, 
												kind:String, 
												breakIt:Boolean):void
	{
		var paren:LinkedListToken = findFirstToken(element.node, kind);
		
		// to do this both ways
		// - find the paren
		// - check to see if a nl is before any token other than ws
		
		if (paren && breakIt)
		{
			// add the nl before the curly
			paren.prepend(TokenBuilder.newNewline());
			
			// add indentation
			var indent:String = ASTUtil.findIndent(element.node);
			paren.prepend(TokenBuilder.newWhiteSpace(indent));
		}

	}
	
	public static function findFirstToken(ast:IParserNode, kind:String):LinkedListToken
	{
		for (var tok:LinkedListToken = ast.startToken; tok != null; tok = tok.next)
		{
			if (tok.kind == kind)
				return tok;
			
			if (tok == ast.stopToken)
				break;
		}
		
		return null;
	}
	
	public static function appendNewlines(ast:IParserNode, token:LinkedListToken, count:int):void
	{
		var indent:String = ASTUtil.findIndent(ast);
		var len:int = count;
		for (var i:int = 0; i < len; i++)
		{
			token.prepend(TokenBuilder.newNewline());
			token.prepend(TokenBuilder.newWhiteSpace(indent));
		}
	}
}
}