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

import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.IASVisitor;
import org.as3commons.asblocks.IASWalker;
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
 * Default implementation of the <code>IASWalker</code> API.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ASWalker implements IASWalker
{
	//--------------------------------------------------------------------------
	//
	//  Protected :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected var visitor:IASVisitor;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ASWalker(visitor:IASVisitor)
	{
		this.visitor = visitor;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IASWalker API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkProject()
	 */
	public function walkProject(element:IASProject):void
	{
		visitor.visitProject(element);
		
		var len:int = element.compilationUnits.length;
		for (var i:int = 0; i < len; i++)
		{
			var unit:ICompilationUnit = element.compilationUnits[i];
			walkCompilationUnit(unit);
		}
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkCompilationUnit()
	 */
	public function walkCompilationUnit(element:ICompilationUnit):void
	{
		visitor.visitCompilationUnit(element);
		walkPackage(element.packageNode);
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkPackage()
	 */
	public function walkPackage(element:IPackage):void
	{
		visitor.visitPackage(element);
		walkType(element.typeNode);
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkType()
	 */
	public function walkType(element:IType):void
	{
		visitor.visitType(element);
		if (element is IClassType)
		{
			walkClass(IClassType(element));
		}
		else if (element is IInterfaceType)
		{
			walkInterface(IInterfaceType(element));
		}
		else if (element is IFunctionType)
		{
			walkFunction(IFunctionType(element));
		}
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkClass()
	 */
	public function walkClass(element:IClassType):void
	{
		visitor.visitClass(element);
		var len:int;
		var i:int;
		
		var fields:Vector.<IField> = element.fields;
		len = fields.length;
		for (i = 0; i < len; i++)
		{
			var field:IField = fields[i];
			walkMember(field);
			walkField(field);
		}
		
		var methods:Vector.<IMethod> = element.methods;
		len = methods.length;
		for (i = 0; i < len; i++)
		{
			var method:IMethod = methods[i];
			walkMember(method);
			walkMethod(method);
		}
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkInterface()
	 */
	public function walkInterface(element:IInterfaceType):void
	{
		visitor.visitInterface(element);
		var len:int;
		var i:int;
		
		var methods:Vector.<IMethod> = element.methods;
		len = methods.length;
		for (i = 0; i < len; i++)
		{
			var method:IMethod = methods[i];
			walkMember(method);
			walkMethod(method);
		}
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkFunction()
	 */
	public function walkFunction(element:IFunctionType):void
	{
		visitor.visitFunction(element);
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#visitMember()
	 */
	public function walkMember(element:IMember):void
	{
		visitor.visitMember(element);
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#visitMethod()
	 */
	public function walkMethod(element:IMethod):void
	{
		visitor.visitMethod(element);
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASWalker#walkField()
	 */
	public function walkField(element:IField):void
	{
		visitor.visitField(element);
	}
}
}