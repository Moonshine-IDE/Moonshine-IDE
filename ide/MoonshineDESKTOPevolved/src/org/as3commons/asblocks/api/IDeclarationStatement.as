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
 * A variable or constant declaration; (<code>var foo:int 0</code>),
 * (<code>var foo:int 0, bar:Number = 42</code>) or 
 * (<code>const foo:int 0</code>).
 * 
 * <pre>
 * var ds:IDeclarationStatement = factory.newDeclaration("foo:int = 0");
 * </pre>
 * 
 * <p>Will produce; <code>var foo:int = 0;</code>.</p>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var ds:IDeclarationStatement = block.newDeclaration("foo:int = 0, bar:int = 42");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	var foo:int = 0, bar:int = 42;
 * }
 * </pre>
 * 
 * <pre>
 * var ds:IDeclarationStatement = factory.newDeclaration("foo:int = 0");
 * ds.isConstant = true;
 * </pre>
 * 
 * <p>Will produce; <code>const foo:int = 0;</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newDeclaration()
 * @see org.as3commons.asblocks.api.IStatementContainer#newDeclaration()
 */
public interface IDeclarationStatement extends IStatement
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * The name of the first declaration.
	 * 
	 * <p>This is a shortcut for statements where there is one
	 * known declaration.</p>
	 */
	function get name():String;
	
	//----------------------------------
	//  type
	//----------------------------------
	
	/**
	 * The type of the first declaration.
	 * 
	 * <p>This is a shortcut for statements where there is one
	 * known declaration.</p>
	 */
	function get type():String;
	
	//----------------------------------
	//  initializer
	//----------------------------------
	
	/**
	 * The initializer of the first declaration.
	 * 
	 * <p>This is a shortcut for statements where there is one
	 * known declaration.</p>
	 */
	function get initializer():IExpression;
	
	//----------------------------------
	//  vars
	//----------------------------------
	
	/**
	 * A Vector of <code>IDeclaration</code> instances found on this statement.
	 */
	function get declarations():Vector.<IDeclaration>;
	
	//----------------------------------
	//  isConstant
	//----------------------------------
	
	/**
	 * When <code>false</code> the statement begins with a <code>var</code>,
	 * when <code>true</code> the statement begins with <code>const</code>.
	 */
	function get isConstant():Boolean;
	
	/**
	 * @private
	 */
	function set isConstant(value:Boolean):void;
}
}