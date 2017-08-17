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

package org.as3commons.asblocks
{

/**
 * Thrown when ActionScript code which is syntactically invalid is encountered.
 * 
 * <p>The <code>cause</code>, if defined, may contain further details 
 * describing what syntactic problem was encountered.</p>
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ASBlocksSyntaxError extends Error
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The original syntax error.
	 */
	public var cause:Error;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new instance of <code>ASBlocksSyntaxError</code>.
	 * 
	 * @param message A String error message.
	 * @param cause The Error that triggered the syntax error.
	 */
	public function ASBlocksSyntaxError(message:String, cause:Error = null)
	{
		super(message);
		
		this.cause = cause;
	}
}
}