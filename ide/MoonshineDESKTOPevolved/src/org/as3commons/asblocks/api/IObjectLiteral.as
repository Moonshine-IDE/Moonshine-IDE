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
 * An Object literal; <code>{a:1, b:2, c:3}</code>.
 * 
 * <pre>
 * var ol:IObjectLiteral = factory.newObjectLiteral()
 * </pre>
 * 
 * <p>Will produce; <code>{}</code></p>
 * 
 * <pre>
 * var ol:IObjectLiteral = factory.newObjectLiteral()
 * ol.newField("a", factory.newExpression("bar"));
 * ol.newField("b", factory.newExpression("2"));
 * ol.newField("c", factory.newExpression("{}"));
 * </pre>
 * 
 * <p>Will produce; <code>{a:bar, b:2, c:{}}</code></p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 * 
 * @see org.as3commons.asblocks.ASFactory#newObjectLiteral()
 */
public interface IObjectLiteral 
	extends IExpression, ILiteral, IScriptNode
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The object literal's Vector of property fields.
	 */
	function get fields():Vector.<IPropertyField>;
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>IPropertyField</code> on the object literal.
	 * 
	 * @param A <code>String</code> indicating the name of the field.
	 * @param An <code>IExpression</code> attatched to the field name.
	 * @return A new <code>IPropertyField</code> instance.
	 */
	function newField(name:String, expression:IExpression):IPropertyField;
}
}