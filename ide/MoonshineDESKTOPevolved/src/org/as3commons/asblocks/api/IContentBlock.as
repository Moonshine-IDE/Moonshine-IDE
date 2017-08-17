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
 * The <code>IClassType</code> is the supertype for the <code>IClassType</code>,
 * <code>IInterfaceType</code> and <code>IFunctionType</code> types.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newClass()
 * @see org.as3commons.asblocks.ASFactory#newInterface()
 * @see org.as3commons.asblocks.ASFactory#newFunction()
 * @see org.as3commons.asblocks.IASProject#newClass()
 * @see org.as3commons.asblocks.IASProject#newInterface()
 * @see org.as3commons.asblocks.IASProject#newFunction()
 */
public interface IContentBlock extends IScriptNode, IMethodAware
{
}
}