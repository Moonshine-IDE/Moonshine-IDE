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

/**
 * A Boolean literal; <code>true</code> or <code>false</code>.
 * 
 * <pre>
 * var bl:IBooleanLiteral = factory.newBooleanLiteral(true);
 * </pre>
 * 
 * <p>Will produce; <code>true</code>.</p>
 * 
 * <pre>
 * var bl:IBooleanLiteral = factory.newBooleanLiteral(true);
 * bl.value = false;
 * </pre>
 * 
 * <p>Will produce; <code>false</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newBooleanLiteral()
 */
public interface IBooleanLiteral extends ILiteral
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  value
	//----------------------------------
	
	/**
	 * A Boolean; <code>true</code> or <code>false</code>.
	 */
	function get value():Boolean;
	
	/**
	 * @private
	 */
	function set value(value:Boolean):void;
}
}