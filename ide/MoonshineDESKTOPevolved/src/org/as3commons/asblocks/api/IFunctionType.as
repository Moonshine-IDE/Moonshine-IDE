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
 * The <code>IFunctionType</code> interface exposes documentation, metadata,
 * and single public <code>function</code> type.
 * 
 * <pre>
 * var factory:ASFactory = new ASFactory();
 * var project:IASProject = new ASFactory(factory);
 * var unit:ICompilationUnit = project.newFunction("my.domain.myFunction");
 * var type:IFunctionType = unit.typeNode as IFunctionType;
 * </pre>
 * 
 * <p>Will produce;</p>
 * <pre>
 * package my.domain {
 * 	public function myFunction():void {
 * 	}
 * }
 * </pre>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newFunction()
 * @see org.as3commons.asblocks.api.IASProject#newFunction()
 * @see org.as3commons.asblocks.api.ICompilationUnit
 */
public interface IFunctionType extends IType, IFunction, IStatementContainer
{

}
}