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
 * A block of code that acts as a statement container for nodes such as 
 * <code>if</code>, <code>for</code>, <code>while</code> etc.
 * 
 * <p>The <code>IBlock</code> is usually the last child in a node list
 * and uses parenthetic start and stop tokens. These tokens are the <code>{</code>
 * and <code>}</code> repectively.</p>
 * 
 * <p>Blocks are indented based on the nodes parent indentation in the AST tree.</p>
 * 
 * <p>Blocks are the foundation for nodes to hold <code>IStatement</code>s.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newBlock()
 */
public interface IBlock extends IStatement, IStatementContainer
{
	
}
}