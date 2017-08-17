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
 * A for each ( in ) statement; <code>for each (declaration in target) { }</code>.
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var declaration:IExpression = factory.newExpression("foo");
 * var target:IExpression = factory.newExpression("bar");
 * var fs:IForEachInStatement = block.newForEachIn(declaration, target);
 * fs.addStatement("trace('do work')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for each (foo in bar) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 * 
 * <pre>
 * var block:IBlock = factory.newBlock();
 * var declaration:IExpression = factory.newDeclaration("foo:String");
 * var target:IExpression = factory.newExpression("getObject(baz)");
 * var fs:IForEachInStatement = block.newForEachIn(declaration, target);
 * fs.addStatement("trace('do work')");
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * {
 * 	for each (var foo:String in getObject(baz)) {
 * 		trace('do work');
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.api.IStatementContainer#newForEachIn()
 * @see org.as3commons.asblocks.ASFactory#newDeclaration()
 */
public interface IForEachInStatement extends IForInStatement
{
}
}