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

import org.as3commons.asblocks.api.IClassPathEntry;

/**
 * A class path entry such as an <code>.as</code> file or <code>.swc</code>.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ClassPathEntry implements IClassPathEntry
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  filePath
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _filePath:String;
	
	/**
	 * @copy org.as3commons.asblocks.api.IClassPathEntry#filePath
	 */
	public function get filePath():String
	{
		return _filePath;
	}
	
	/**
	 * @private
	 */	
	public function set filePath(value:String):void
	{
		_filePath = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ClassPathEntry(filePath:String)
	{
		super();
		
		this.filePath = filePath;
	}
}
}