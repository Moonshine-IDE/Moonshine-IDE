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

import org.as3commons.asblocks.api.IClassType;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.api.IField;
import org.as3commons.asblocks.api.IFunctionType;
import org.as3commons.asblocks.api.IInterfaceType;
import org.as3commons.asblocks.api.IMember;
import org.as3commons.asblocks.api.IMethod;
import org.as3commons.asblocks.api.IPackage;
import org.as3commons.asblocks.api.IType;

/**
 * Walks any node of a <code>IASProject</code> project.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.IASVisitor
 */
public interface IASWalker
{
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Walks an <code>IASProject</code> and recurses through all nodes
	 * in the AST tree.
	 * 
	 * @param element The <code>IASProject</code>.
	 */
	function walkProject(element:IASProject):void;
	
	/**
	 * Walks an <code>ICompilationUnit</code> of the <code>IASProject</code>.
	 * 
	 * @param element The <code>ICompilationUnit</code> of the 
	 * <code>IASProject</code>.
	 */
	function walkCompilationUnit(element:ICompilationUnit):void;
	
	/**
	 * Walks an <code>IPackage</code> of the <code>ICompilationUnit</code>.
	 * 
	 * @param element The <code>IPackage</code> of the 
	 * <code>ICompilationUnit</code>.
	 */
	function walkPackage(element:IPackage):void;
	
	/**
	 * Called just before <code>visitClass()</code> or 
	 * <code>visitInterface()</code>. 
	 * 
	 * @param element The <code>IType</code> of the 
	 * <code>ICompilationUnit</code>.
	 */
	function walkType(element:IType):void;
	
	/**
	 * Walks an <code>IClassType</code> of the <code>IPackage</code>.
	 * 
	 * @param element The <code>IClassType</code> of the 
	 * <code>IPackage</code>.
	 */
	function walkClass(element:IClassType):void;
	
	/**
	 * Walks an <code>IInterfaceType</code> of the <code>IPackage</code>.
	 * 
	 * @param element The <code>IInterfaceType</code> of the 
	 * <code>IPackage</code>.
	 */
	function walkInterface(element:IInterfaceType):void;
	
	/**
	 * Walks an <code>IFunctionType</code> of the <code>IPackage</code>.
	 * 
	 * @param element The <code>IFunctionType</code> of the 
	 * <code>IPackage</code>.
	 */
	function walkFunction(element:IFunctionType):void;
	
	/**
	 * Called just before <code>visitMethod()</code> or 
	 * <code>visitField()</code>. 
	 * 
	 * @param element The <code>IMember</code> of the 
	 * <code>IType</code>.
	 */
	function walkMember(element:IMember):void;
	
	/**
	 * Walks an <code>IMethod</code> of the <code>IType</code>.
	 * 
	 * @param element The <code>IMethod</code> of the 
	 * <code>IType</code>.
	 */
	function walkMethod(element:IMethod):void;
	
	/**
	 * Walks an <code>IField</code> of the <code>IType</code>.
	 * 
	 * @param element The <code>IField</code> of the 
	 * <code>IType</code>.
	 */
	function walkField(element:IField):void;
}
}