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

package org.as3commons.mxmlblocks
{

import flash.events.IEventDispatcher;

import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IParserInfo;
import org.as3commons.asblocks.parser.api.ISourceCode;

/**
 * Parse an entire MXML source file from the given 
 * <code>ISourceCode</code>, returning an <code>ICompilationUnit</code> 
 * which details the type  contained in the file.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IMXMLParser
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Parses the <code>ISourceCode</code>'s source code data asynchronously
	 * when the <code>parse()</code> method of the info is called.
	 * 
	 * @param code An <code>ISourceCode</code> instance holding the source
	 * code or fileName to parse into an <code>ICompilationUnit</code>.
	 * @param entry The <code>IClassPathEntry</code> for the source code.
	 * @return An <code>IParserInfo</code> holding the parser and source code.
	 * 
	 * @see org.as3commons.asblocks.impl.IParserInfo#parse()
	 */
	function parseAsync(sourceCode:ISourceCode, entry:IClassPathEntry):IParserInfo;
	
	/**
	 * Parses the <code>ISourceCode</code>'s source code data.
	 * 
	 * @param code An <code>ISourceCode</code> instance holding the source
	 * code or fileName to parse into an <code>ICompilationUnit</code>.
	 * @param entry The <code>IClassPathEntry</code> for the source code.
	 * @return An <code>ICompilationUnit</code> detailing the source code.
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError
	 */
	function parse(code:ISourceCode, entry:IClassPathEntry):ICompilationUnit;
	
	/**
	 * Parses the <code>String</code> source code data.
	 * 
	 * @param source The <code>String</code> source code.
	 * @return An <code>ICompilationUnit</code> detailing the source code.
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError
	 */
	function parseString(source:String):ICompilationUnit;
}
}