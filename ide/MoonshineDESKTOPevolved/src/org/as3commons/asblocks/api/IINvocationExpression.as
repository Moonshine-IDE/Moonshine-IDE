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
 * An invocation expression; <code>super(arg0, arg1)</code>, 
 * <code>new Class(arg)</code>, <code>foo(arg0)</code> etc.
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("foo");
 * var ii:IINvocationExpression = factory.newInvocationExpression(target, null);
 * </pre>
 * 
 * <p>Will produce; <code>foo()</code>.</p>
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("foo");
 * var arguments:Vector.<IExpression> = new Vector.<IExpression>();
 * arguments.push(factory.newExpression("bar"));
 * arguments.push(factory.newExpression("\"baz\""));
 * var ii:IINvocationExpression = factory.newInvocationExpression(target, arguments);
 * </pre>
 * 
 * <p>Will produce; <code>foo(bar, "baz")</code>.</p>
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("foo");
 * var ii:IINvocationExpression = factory.newInvocationExpression(target, null);
 * ii.target = factory.newExpression("bar");
 * </pre>
 * 
 * <p>Will produce; <code>bar()</code>.</p>
 * 
 * <pre>
 * var target:IExpression = factory.newExpression("baz");
 * var ii:IINvocationExpression = factory.newInvocationExpression(target, null);
 * var arguments:Vector.<IExpression> = new Vector.<IExpression>();
 * arguments.push(factory.newExpression("bar"));
 * arguments.push(factory.newExpression("\"foo\""));
 * ii.arguments = arguments;
 * </pre>
 * 
 * <p>Will produce; <code>baz(bar, "foo")</code>.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newInvocationExpression()
 */
public interface IINvocationExpression extends IExpression, IINvocation
{
}
}