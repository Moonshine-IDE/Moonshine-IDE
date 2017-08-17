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
 * A try statement; <code>try { } catch (e:Error) { } finally { }</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var statement:ITryStatement = block.newTryCatch("e", "Error");
 * statement.addStatement("Try this code");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	try {
 * 		trace("Try this code");
 * 	} catch (e:Error) {
 * 	}
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var statement:ITryStatement = block.newTryFinally();
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	try {
 * 	} finally {
 * 	}
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var statement:ITryStatement = block.newTryCatch("e", "Error");
 * statement.addStatement("Try this code");
 * statement.catchClauses[0].addStatement("Catch the Error");
 * var fstatement:IFinallyClause = statement.newFinallyClasue();
 * fstatement.addStatement("Always executes");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	try {
 * 		trace("Try this code");
 * 	} catch (e:Error) {
 * 		trace("Catch the Error");
 * 	} finally {
 * 		trace("Always executes");
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newTryCatch()
 * @see org.as3commons.asblocks.api.IStatementContainer#newTryFinally()
 */
public interface ITryStatement extends IStatement, IStatementContainer
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  catchClauses
	//----------------------------------
	
	/**
	 * The try statement's catch clauses in order of addition.
	 */
	function get catchClauses():Vector.<ICatchClause>;
	
	//----------------------------------
	//  finallyClause
	//----------------------------------
	
	/**
	 * The try statement's single finally clause.
	 */
	function get finallyClause():IFinallyClause;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Appends and returns a new <code>ICatchClause</code> to the try statement.
	 * 
	 * @param name The name identifier of the error object.
	 * @param type The type of error object.
	 * @return A new <code>ICatchClause</code> statement.
	 */
	function newCatchClause(name:String, type:String):ICatchClause;
	
	/**
	 * Removes the catch statement and returns the statement.
	 * 
	 * @param statement The catch statement to remove.
	 * @return The removed <code>ICatchClause</code> clause if found or
	 * <code>null</code> if not found.
	 */
	function removeCatch(statement:ICatchClause):ICatchClause;
	
	/**
	 * Adds and returns a new <code>IFinallyClause</code> to the try statement.
	 * 
	 * <p>Note: Only one finally statement is allowed, the method will throw an
	 * <code>ASBlocksSyntaxError</code> error if called more than once.</p>
	 * 
	 * @throws org.as3commons.asblocks.ASBlocksSyntaxError only one finally-clause allowed
	 */
	function newFinallyClause():IFinallyClause;
	
	/**
	 * Removes the finally statement and returns the statement.
	 * 
	 * @return The removed <code>IFinallyClause</code> clause.
	 */
	function removeFinally():IFinallyClause;
}
}