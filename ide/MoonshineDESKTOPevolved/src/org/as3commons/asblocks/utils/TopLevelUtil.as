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

package org.as3commons.asblocks.utils
{

/**
 * Toplevel types in the Flash Player.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TopLevelUtil
{
	//--------------------------------------------------------------------------
	//
	//  Private Class :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static var toplevel:Object =
		{
			ArgumentError:true,
			arguments:true,
			Array:true,
			Boolean:true,
			Class:true,
			Date:true,
			DefinitionError:true,
			Error:true,
			EvalError:true,
			Function:true,
			int:true,
			Math:true,
			Namespace:true,
			Number:true,
			Object:true,
			QName:true,
			RangeError:true,
			ReferenceError:true,
			RegExp:true,
			SecurityError:true,
			String:true,
			SyntaxError:true,
			TypeError:true,
			uint:true,
			URIError:true,
			Vector:true,
			VerifyError:true,
			XML:true,
			XMLList:true
			// specail
			// *:true,
			// void:true,
			// Null:true
		}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Returns whether the type is a toplevel type in the Flash Player.
	 * 
	 * @param type A String type name.
	 * @return A Boolean indicating whether the type is a Flash Player 
	 * toplevel type.
	 */
	public static function isTopLevel(type:String):Boolean
	{
		if (type == "*" || type == "void" || type == "Null")
			return true;
		
		return toplevel[type];
	}
}
}