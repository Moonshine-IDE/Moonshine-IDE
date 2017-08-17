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

import org.as3commons.mxmlblocks.api.IBlockTag;
import org.as3commons.asblocks.parser.api.IParserNode;
import org.as3commons.mxmlblocks.impl.TagList;

/**
 * The <code>ICompilationUnit</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ApplicationUnitNode extends CompilationUnitNode
{
	public var mxml:IParserNode;
	
	//----------------------------------
	//  mxmlNode
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get procInstruction():IBlockTag
	{
		return null;
	}
	
	//----------------------------------
	//  mxmlNode
	//----------------------------------
	
	/**
	 * doc
	 */
	public function get mxmlNode():IBlockTag
	{
		return new TagList(mxml.getLastChild()); //tag-list
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ApplicationUnitNode(node:IParserNode, application:IParserNode)
	{
		super(node);
		
		this.mxml = application; // mxml ast tree with tags
	}
}
}