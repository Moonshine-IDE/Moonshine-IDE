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
 * The <code>IInterfaceType</code> interface exposes documentation, metadata,
 * and public members of the <code>interface</code> type.
 * 
 * <pre>
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = new ASProject(factory);
 * var unit:ICompilationUnit = project.newInterface("my.domain.IInterfaceType");
 * var type:IInterfaceType = unit.typeNode as IInterfaceType;
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * package my.domain {
 * 	public interface IInterfaceType {
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newInterface()
 * @see org.as3commons.asblocks.api.IASProject#newInterface()
 * @see org.as3commons.asblocks.api.ICompilationUnit
 */
public interface IInterfaceType extends IType, IContentBlock
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  superInterfaces
	//----------------------------------
	
	/**
	 * Returns a Vector of interfaces this interface type extends.
	 */
	function get superInterfaces():Vector.<String>;
	
	//----------------------------------
	//  qualifiedSuperInterfaces
	//----------------------------------
	
	/**
	 * Returns a Vector of qualified interfaces this interface type extends.
	 */
	function get qualifiedSuperInterfaces():Vector.<String>;
	
	//----------------------------------
	//  isSubType
	//----------------------------------
	
	/**
	 * Whether the <code>extends</code> clause is present.
	 */
	function get isSubType():Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds an interface to the <code>extends</code> clause.
	 * 
	 * @param name The name of the interface, if a period is present, the name
	 * will be considered qualified.
	 * @return A <code>Boolean</code> indicating whether the interface name
	 * was successfully added to the <code>extends</code> clause.
	 */
	function addSuperInterface(name:String):Boolean;
	
	/**
	 * Removes an interface from the <code>extends</code> clause.
	 * 
	 * @param name The name of the interface to be removed.
	 * @return A <code>Boolean</code> indicating whether the interface name
	 * was successfully removed from the <code>extends</code> clause.
	 */
	function removeSuperInterface(name:String):Boolean;
}
}