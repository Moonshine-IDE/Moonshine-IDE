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
 * Type and member modifiers.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public final class Modifier
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	public static const DYNAMIC:Modifier = Modifier.create("dynamic");
	
	public static const FINAL:Modifier = Modifier.create("final");
	
	public static const INTERNAL:Modifier = Modifier.create("internal");
	
	public static const OVERRIDE:Modifier = Modifier.create("override");
	
	public static const PRIVATE:Modifier = Modifier.create("private");
	
	public static const PROTECTED:Modifier = Modifier.create("protected");
	
	public static const PUBLIC:Modifier = Modifier.create("public");
	
	public static const STATIC:Modifier = Modifier.create("static");
	
	private static var list:Array =
		[
			DYNAMIC,
			FINAL,
			INTERNAL,
			OVERRIDE,
			PRIVATE,
			PROTECTED,
			PUBLIC,
			STATIC
		];
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _name:String;
	
	/**
	 * The modifier name.
	 */
	public function get name():String
	{
		return _name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function Modifier(name:String)
	{
		_name = name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function toString():String
	{
		return _name;
	}
	
	/**
	 * @private
	 */
	public function equals(other:Modifier):Boolean
	{
		return _name == other.name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new Modifier.
	 * 
	 * @param name A String indicating the name of the modifier.
	 * @return A new Modifer instance.
	 */
	public static function create(name:String):Modifier
	{
		for each (var element:Modifier in list) 
		{
			if (element.name == name)
				return element;
		}
		
		return new Modifier(name);
	}
}
}