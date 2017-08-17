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

package org.as3commons.mxmlblocks.impl
{

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.impl.ASTBuilder;
import org.as3commons.asblocks.impl.ScriptNode;
import org.as3commons.asblocks.impl.TokenBuilder;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.mxmlblocks.api.IXMLNamespace;
import org.as3commons.mxmlblocks.parser.api.MXMLNodeKind;

/**
 * The <code>IXMLNamespace</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class XMLNamespaceNode extends ScriptNode implements IXMLNamespace
{
	//--------------------------------------------------------------------------
	//
	//  IXMLNamespace API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  localName
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IXMLNamespace#localName
	 */
	public function get localName():String
	{
		var ast:IParserNode = findLocalName();
		if (!ast)
			return null;
		return ast.stringValue;
	}
	
	/**
	 * @private
	 */	
	public function set localName(value:String):void
	{
		var ast:IParserNode = findLocalName();
		if (value == null)
		{
			if (ast)
			{
				node.removeChild(ast);
			}
			return;
		}
		
		if (!ast)
		{
			// need to add a colon to the beginning so the local name owns it
			// then it will be removed when the local name is set to null
			var colon:LinkedListToken = TokenBuilder.newColon();
			ast = ASTBuilder.newAST(MXMLNodeKind.LOCAL_NAME, value);
			ast.startToken.prepend(colon);
			ast.startToken = colon;
			node.addChildAt(ast, 0);
		}
		else
		{
			ast.stringValue = value;
		}
	}
	
	//----------------------------------
	//  uri
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IXMLNamespace#uri
	 */
	public function get uri():String
	{
		var ast:IParserNode = findURI();
		if (!ast)
			return null;
		return ast.stringValue;
	}
	
	/**
	 * @private
	 */	
	public function set uri(value:String):void
	{
		var ast:IParserNode = findURI();
		if (value == null)
		{
			throw new ASBlocksSyntaxError("uri for IXMLNamespace cannot be null");
		}
		
		if (!ast)
		{
			ast = ASTBuilder.newAST(MXMLNodeKind.URI, value);
			node.addChild(ast);
		}
		else
		{
			ast.stringValue = value;
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function XMLNamespaceNode(node:IParserNode)
	{
		super(node);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private function findLocalName():IParserNode
	{
		return node.getKind(MXMLNodeKind.LOCAL_NAME);
	}
	
	/**
	 * @private
	 */
	private function findURI():IParserNode
	{
		return node.getKind(MXMLNodeKind.URI);
	}
}
}