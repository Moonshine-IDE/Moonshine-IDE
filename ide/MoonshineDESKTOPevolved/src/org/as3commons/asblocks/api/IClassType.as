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
 * The <code>IClassType</code> interface exposes documentation, metadata,
 * and public members of the <code>class</code> type.
 * 
 * <pre>
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = new ASProject(factory);
 * var unit:ICompilationUnit = project.newClass("my.domain.ClassType");
 * var type:IClassType = unit.typeNode as IClassType;
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * package my.domain {
 * 	public class ClassType {
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newClass()
 * @see org.as3commons.asblocks.api.IASProject#newClass()
 * @see org.as3commons.asblocks.api.ICompilationUnit
 */
public interface IClassType extends IType, IContentBlock, IFieldAware
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  isDynamic
	//----------------------------------
	
	/**
	 * Whether the class type has a <code>dynamic</code> modifier.
	 * 
	 * <p>Setting this property to <code>true</code> will add the <code>dynamic</code>,
	 * setting the property to <code>false</code> will remove the <code>dynamic</code>
	 * modifier.</p>
	 */
	function get isDynamic():Boolean;
	
	/**
	 * @private
	 */
	function set isDynamic(value:Boolean):void;
	
	//----------------------------------
	//  isFinal
	//----------------------------------
	
	/**
	 * Whether the class type has a <code>final</code> modifier.
	 * 
	 * <p>Setting this property to <code>true</code> will add the <code>final</code>,
	 * setting the property to <code>false</code> will remove the <code>final</code>
	 * modifier.</p>
	 */
	function get isFinal():Boolean;
	
	/**
	 * @private
	 */
	function set isFinal(value:Boolean):void;
	
	//----------------------------------
	//  superClass
	//----------------------------------
	
	/**
	 * The current String value located after the <code>extends</code> keyword.
	 * 
	 * <p>This value can be a qualified or simple name. When setting this 
	 * property to <code>null</code> or <code>""</code>, the type will completly
	 * remove the <code>extends</code> keyword along with the name from the AST.</p>
	 */
	function get superClass():String;
	
	/**
	 * @private
	 */
	function set superClass(value:String):void;
	
	//----------------------------------
	//  qualifiedSuperClass
	//----------------------------------
	
	/**
	 * The qualified super class name.
	 */
	function get qualifiedSuperClass():String
	
	//----------------------------------
	//  isSubType
	//----------------------------------
	
	/**
	 * Whether the <code>extends</code> clause is present.
	 */
	function get isSubType():Boolean;
	
	//----------------------------------
	//  implementedInterfaces
	//----------------------------------
	
	/**
	 * Returns all String values declared after the <code>implements</code>
	 * keyword.
	 * 
	 * <p>These values can be a qualified or simple names. This property will
	 * never return <code>null</code>, if implementations are not found, an
	 * empty Vector is returned.</p>
	 */
	function get implementedInterfaces():Vector.<String>;
	
	//----------------------------------
	//  qualifiedImplementedInterfaces
	//----------------------------------
	
	/**
	 * Returns all qualified String values declared after the 
	 * <code>implements</code> keyword.
	 * 
	 * @see #implementedInterfaces
	 */
	function get qualifiedImplementedInterfaces():Vector.<String>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Adds a qualified or simple name implementation to the class type.
	 * 
	 * <p>If no implementations exists the <code>implements</code> keyword
	 * will be added to the token list.</p>
	 * 
	 * @param name A String indicating the new implementation name.
	 * @return A Boolean indicating whether the implementation was added.
	 */
	function addImplementedInterface(name:String):Boolean;
	
	/**
	 * Removes a qualified or simple name implementation from the class type.
	 * 
	 * <p>If implementations exist and this implementation removed is the
	 * last, the <code>implements</code> keyword will be removed from the 
	 * token list.</p>
	 * 
	 * @param name A String indicating the new implementation name.
	 * @return A Boolean indicating whether the implementation was added.
	 */
	function removeImplementedInterface(name:String):Boolean;
}
}