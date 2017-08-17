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
 * The <strong>ISourceCodeScanner</strong> interface marks a class as having 
 * the ability to scan and create Tokens for a source code specific domain type.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface ISourceCodeScanner
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  commentLine
	//----------------------------------
	
	/**
	 * The current comment line.
	 */
	function get commentLine():int;
	
	/**
	 * @private
	 */
	function set commentLine(value:int):void;
	
	//----------------------------------
	//  commentColumn
	//----------------------------------
	
	/**
	 * The current comment column.
	 */
	function get commentColumn():int;
	
	/**
	 * @private
	 */
	function set commentColumn(value:int):void;
	
	//----------------------------------
	//  inBlock
	//----------------------------------
	
	/**
	 * Set whether the scanner is an a { } block.
	 */
	function get inBlock():Boolean;
	
	/**
	 * @private
	 */
	function set inBlock(value:Boolean):void;
}
}