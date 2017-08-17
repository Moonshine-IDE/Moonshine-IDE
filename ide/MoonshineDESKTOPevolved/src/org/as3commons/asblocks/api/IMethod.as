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
 * A type method.
 * 
 * <pre>
 * var method:IMethod = type.newMethod("foo", Visibility.PUBLIC, "int");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * ...
 * {
 * 	public function foo():int {
 * 	}
 * }
 * ...
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IClassType#newMethod()
 * @see org.as3commons.asblocks.api.IInterfaceType#newMethod()
 */
public interface IMethod 
	extends IFunction, IStatementContainer, IMember
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  accessorRole
	//----------------------------------
	
	/**
	 * The access role of the function <code>AccessorRole#NORMAL</code>,
	 * <code>AccessorRole#GETTER</code> or <code>AccessorRole#SETTER</code>.
	 */
	function get accessorRole():AccessorRole;
	
	/**
	 * @private
	 */
	function set accessorRole(value:AccessorRole):void;
}
}