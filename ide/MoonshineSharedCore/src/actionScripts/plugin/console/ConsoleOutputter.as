////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.console
{
	import flash.events.EventDispatcher;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.utils.HtmlFormatter;
	
	import no.doomsday.console.ConsoleUtil;
	
	public class ConsoleOutputter extends EventDispatcher
	{
		public static var DEBUG:Boolean = true;

		protected static var _name:String = "";
		public function get name():String
		{
			return _name;
		}

        protected function success(str:String, ...replacements):void
        {
            formatOutput(HtmlFormatter.sprintfa(str, replacements), 'success');
        }

		// Console output functions, use %s for substitution
		protected function notice(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'notice');
		}
		
		protected function error(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'error');
		}
		
		protected function warning(str:String, ...replacements):void
		{
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'warning');
		}
		
		protected function print(str:String, ...replacements):void 
		{
			ConsoleUtil.print(str);
			formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
		}
		
		protected function debug(str:String, ...replacements):void
		{
			if(DEBUG)
			{
				formatOutput(HtmlFormatter.sprintfa(str, replacements), 'weak');
			}
		}
		
		public function formatOutput(str:String, style:String, showWhenDone:Boolean=true):Vector.<TextLineModel>
		{
			var textLines:Array =  str.split("\n");
			var lines:Vector.<TextLineModel> = Vector.<TextLineModel>([]);
			for (var i:int = 0; i < textLines.length; i++)
			{
				if (textLines[i] == "") continue;
				var text:String = HtmlFormatter.sprintf("<%x>%x:</%x> %x", style, _name, style, textLines[i]); 
				var lineModel:TextLineModel = new ConsoleTextLineModel(text, style);
				lines.push(lineModel);
			}
			
			if (showWhenDone) 
			{
				outputMsg(lines);
				return null;
			}
			
			return lines;
		}
		
		protected function outputMsg(msg:*):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, msg));
		}
		
		protected function clearOutput():void 
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_CLEAR, null, true));
		}
	}
}