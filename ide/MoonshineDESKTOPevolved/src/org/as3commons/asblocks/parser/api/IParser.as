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

package org.as3commons.asblocks.parser.api
{

/**
 * The <strong>IParser</strong> interface marks a class as having the ability
 * to create and AST (Abstract Syntax Tree) for a specific domain type.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IParser
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Builds and returns an AST rooted as an <code>IParserNode</code>.
	 * 
	 * <p>The method will attempt to load the file data and source line Vector.</p>
	 * 
	 * @param filePath A String indicating the location of the source.
	 */
	function buildFileAst(filePath:String):IParserNode;
	
	/**
	 * Builds and returns an AST rooted as an <code>IParserNode</code>.
	 * 
	 * @param lines A Vector of String lines to be parsed into an AST.
	 * @param filePath A String indicating the location of the source.
	 */
	function buildAst(lines:Vector.<String>, filePath:String):IParserNode;
}
}