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

package org.as3commons.asblocks
{

import org.as3commons.asblocks.parser.api.ISourceCode;
import org.as3commons.asblocks.api.ICompilationUnit;

/**
 * Writes the ActionScript code in the given <code>ICompilationUnit</code> 
 * to the given <code>ISourceCode</code>. 
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IASWriter
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Writes the compilation unit to an <code>ISourceCode</code> instance.
	 * 
	 * @param code An <code>ISourceCode</code> instance holding the source
	 * code or fileName to parse.
	 * @param unit An <code>ICompilationUnit</code> instance to be written.
	 */
	function write(code:ISourceCode, unit:ICompilationUnit):void;
}
}