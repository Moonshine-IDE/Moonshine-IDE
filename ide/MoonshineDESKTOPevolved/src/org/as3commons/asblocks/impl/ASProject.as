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

import flash.events.EventDispatcher;

import org.as3commons.asblocks.ASFactory;
import org.as3commons.asblocks.IASProject;
import org.as3commons.asblocks.api.IClassPathEntry;
import org.as3commons.asblocks.api.ICompilationUnit;
import org.as3commons.asblocks.parser.core.SourceCode;
import org.as3commons.asblocks.utils.FileUtil;

/**
 * The default implementation of the <code>IASProject</code> API.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ASProject extends EventDispatcher implements IASProject
{
	//--------------------------------------------------------------------------
	//
	//  IASProject API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  factory
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _factory:ASFactory;
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#factory
	 */
	public function get factory():ASFactory
	{
		return _factory;
	}
	
	//----------------------------------
	//  compilationUnits
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _compilationUnits:Vector.<ICompilationUnit> = new Vector.<ICompilationUnit>();
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#compilationUnits
	 */
	public function get compilationUnits():Vector.<ICompilationUnit>
	{
		var result:Vector.<ICompilationUnit> = new Vector.<ICompilationUnit>();
		var len:int = _compilationUnits.length;
		for (var i:int = 0; i < len; i++)
		{
			result.push(_compilationUnits[i]);
		}
		return result;
	}
	
	//----------------------------------
	//  classPathEntries
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _classPathEntries:Vector.<IClassPathEntry> = new Vector.<IClassPathEntry>();
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#classPathEntries
	 */
	public function get classPathEntries():Vector.<IClassPathEntry>
	{
		var result:Vector.<IClassPathEntry> = new Vector.<IClassPathEntry>();
		var len:int = _classPathEntries.length;
		for (var i:int = 0; i < len; i++)
		{
			result.push(_classPathEntries[i]);
			
		}
		return result;
	}
	
	//----------------------------------
	//  resourceRoots
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _resourceRoots:Vector.<IResourceRoot> = new Vector.<IResourceRoot>();
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#resourceRoots
	 */
	public function get resourceRoots():Vector.<IResourceRoot>
	{
		var result:Vector.<IResourceRoot> = new Vector.<IResourceRoot>();
		var len:int = _resourceRoots.length;
		for (var i:int = 0; i < len; i++)
		{
			result.push(_resourceRoots[i]);
		}
		return result;
	}
	
	//----------------------------------
	//  outputLocation
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _outputLocation:String;
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#outputLocation
	 */
	public function get outputLocation():String
	{
		return _outputLocation;
	}
	
	/**
	 * @private
	 */	
	public function set outputLocation(value:String):void
	{
		_outputLocation = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor, creates a new project with the associated factory.
	 * 
	 * @param factory The <code>ASFactory</code> implementation used with the
	 * project. This instance will be used when creating types.
	 */
	public function ASProject(factory:ASFactory)
	{
		_factory = factory;
	}
	
	//--------------------------------------------------------------------------
	//
	//  IASProject API :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#addCompilationUnit()
	 * 
	 * @see #compilationUnitAdded()
	 */
	public function addCompilationUnit(unit:ICompilationUnit):Boolean
	{
		if (_compilationUnits.indexOf(unit) != -1)
			return false;
		
		_compilationUnits.push(unit);
		compilationUnitAdded(unit);
		return true;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#removeCompilationUnit()
	 * 
	 * @see #compilationUnitRemoved()
	 */
	public function removeCompilationUnit(unit:ICompilationUnit):Boolean
	{
		var len:int = _compilationUnits.length;
		for (var i:int = 0; i < len; i++)
		{
			var element:ICompilationUnit = _compilationUnits[i] as ICompilationUnit;
			if (element === unit)
			{
				_compilationUnits.splice(i, 1);
				compilationUnitRemoved(unit);
				return true;
			}	
		}
		return false;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#addClassPath()
	 */
	public function addClassPath(classPath:String):IClassPathEntry
	{
		var entry:IClassPathEntry;
		
		for each (entry in _classPathEntries) 
		{
			if (entry.filePath == classPath)
				return null;
		}
		
		entry = new ClassPathEntry(classPath);
		_classPathEntries.push(entry);
		return entry;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#removeClassPath()
	 */
	public function removeClassPath(classPath:String):Boolean
	{
		var len:int = _classPathEntries.length;
		for (var i:int = 0; i < len; i++)
		{
			var element:IClassPathEntry = _classPathEntries[i] as IClassPathEntry;
			if (element.filePath == classPath)
			{
				_classPathEntries.splice(i, 1);
				return true;
			}	
		}
		return false;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#addResourceRoot()
	 */
	public function addResourceRoot(resource:IResourceRoot):Boolean
	{
		if (_resourceRoots.indexOf(resource) != -1)
			return false;
		
		_resourceRoots.push(resource);
		return true;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#removeResourceRoot()
	 */
	public function removeResourceRoot(resource:IResourceRoot):Boolean
	{
		var len:int = _resourceRoots.length;
		for (var i:int = 0; i < len; i++)
		{
			var element:IResourceRoot = _resourceRoots[i] as IResourceRoot;
			if (element == resource)
			{
				_resourceRoots.splice(i, 1);
				return true;
			}	
		}
		return false;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#newClass()
	 */
	public function newClass(qualifiedName:String):ICompilationUnit
	{
		var cu:ICompilationUnit = factory.newClass(qualifiedName);
		addCompilationUnit(cu);
		return cu;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#newInterface()
	 */
	public function newInterface(qualifiedName:String):ICompilationUnit
	{
		var cu:ICompilationUnit = factory.newInterface(qualifiedName);
		addCompilationUnit(cu);
		return cu;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#newApplication()
	 */
	public function newApplication(qualifiedName:String, 
								   superQualifiedName:String):ICompilationUnit
	{
		var cu:ICompilationUnit = factory.newApplication(qualifiedName, superQualifiedName);
		addCompilationUnit(cu);
		return cu;
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#readAllAsync()
	 */
	public function readAllAsync():void
	{
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#readAll()
	 */
	public function readAll():void
	{
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#writeAll()
	 * 
	 * @see #write()
	 */
	public function writeAll():void
	{
		clearBuffer();
		
		var len:int = compilationUnits.length;
		for (var i:int = 0; i < len; i++)
		{
			var element:ICompilationUnit = compilationUnits[i] as ICompilationUnit;
			write(outputLocation, element);
		}
	}
	
	/**
	 * @copy org.as3commons.asblocks.IASProject#writeAll()
	 */
	public function writeAllAsync():void
	{
		
	}
	
	//--------------------------------------------------------------------------
	//
	//  Protected :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Addition hook.
	 * 
	 * @param unit A successfully added compilation unit.
	 * @see #addCompilationUnit()
	 */
	protected function compilationUnitAdded(unit:ICompilationUnit):void
	{
		// TODO (mschmalle) remove this concrete CompilationUnitNode ref
		if (unit is CompilationUnitNode)
		{
			CompilationUnitNode(unit)._project = this;
		}
	}
	
	/**
	 * Removal hook.
	 * 
	 * @param unit A successfully removed compilation unit.
	 * @see #removeCompilationUnit()
	 */
	protected function compilationUnitRemoved(unit:ICompilationUnit):void
	{
		// TODO (mschmalle) remove this concrete CompilationUnitNode ref
		if (unit is CompilationUnitNode)
		{
			CompilationUnitNode(unit)._project = null;
		}
	}
	
	/**
	 * @private
	 */
	protected function clearBuffer():void
	{
		_sourceCodeList = [];
	}
	
	/**
	 * @private
	 */
	protected function write(location:String, unit:ICompilationUnit):void
	{
		var fileName:String = FileUtil.fileNameFor(unit);
		
		// subclass for new implementation
		var code:SourceCode = new SourceCode(null, fileName);
		factory.newWriter().write(code, unit);
		
		_sourceCodeList.push(code);
	}
	
	//--------------------------------------------------------------------------
	//
	//  TODO
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private var _sourceCodeList:Array = [];
	
	/**
	 * @private
	 */
	public function get sourceCodeList():Array
	{
		return _sourceCodeList;
	}
}
}