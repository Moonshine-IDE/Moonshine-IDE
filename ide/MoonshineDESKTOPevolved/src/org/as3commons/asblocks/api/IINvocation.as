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
 * An invocation expression target( arguments ); <code>super(arg0, arg1)</code>, 
 * <code>new Class(arg)</code>, <code>foo(arg0)</code> etc.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public interface IINvocation
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * The target expression of the invocation, before the <code>()</code>.
	 */
	function get target():IExpression;
	
	/**
	 * @private
	 */
	function set target(value:IExpression):void;
	
	//----------------------------------
	//  arguments
	//----------------------------------
	
	/**
	 * The argument expressions of the invocation, between the <code>(args,...)</code>.
	 */
	function get arguments():Vector.<IExpression>;
	
	/**
	 * @private
	 */
	function set arguments(value:Vector.<IExpression>):void;
}
}