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

package org.as3commons.asblocks.api
{

import flash.events.IEventDispatcher;

import org.as3commons.asblocks.ASBlocksSyntaxError;
import org.as3commons.asblocks.parser.api.ISourceCode;

/**
 * The <code>IParserInfo</code> interface allows for asyncronous parse 
 * operations.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IParserInfo extends IEventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  sourceCode
	//----------------------------------
	
	/**
	 * The source code.
	 */
	function get sourceCode():ISourceCode;
	
	//----------------------------------
	//  entry
	//----------------------------------
	
	/**
	 * The class path entry (base path).
	 */
	function get entry():IClassPathEntry;
	
	//----------------------------------
	//  unit
	//----------------------------------
	
	/**
	 * The parsed compilation unit.
	 */
	function get unit():ICompilationUnit;
	
	//----------------------------------
	//  error
	//----------------------------------
	
	/**
	 * The error thrown during parsing.
	 */
	function get error():ASBlocksSyntaxError;
	
	/**
	 * @private
	 */
	function set error(value:ASBlocksSyntaxError):void;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Parses the sourceCode with the appropriate parser.
	 */
	function parse():void;
}
}