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

package org.as3commons.asblocks.parser.errors
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.utils.HtmlFormatter;
	
	import no.doomsday.console.ConsoleUtil;

/**
 * A Token error in an IScanner.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class TokenError extends Error
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function TokenError(message:*="")
	{
		trace(message);
		GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(
				ConsoleOutputEvent.CONSOLE_PRINT,
				message,
				false, false, ConsoleOutputEvent.TYPE_INFO
		));
		return;
	}
}
}