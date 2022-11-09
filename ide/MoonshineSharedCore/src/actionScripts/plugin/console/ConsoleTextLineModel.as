////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
	import __AS3__.vec.Vector;
	
	import actionScripts.ui.editor.text.TextLineModel;
	
	public class ConsoleTextLineModel extends TextLineModel
	{
		protected var markupText:String;
		private var consoleOutputType:String;

		public function ConsoleTextLineModel(text:String, consoleOutputType:String)
		{
			this.markupText = text;
			this.consoleOutputType = consoleOutputType;
			
			super( decode(text) );
		}

		public function getTextColor():uint
		{
			var consoleOutType:uint = ConsoleStyle.name2style[consoleOutputType];
			switch(consoleOutType)
			{
				case ConsoleStyle.ERROR:
					return 0xff6666;
					break;
				case ConsoleStyle.WARNING:
					return 0xFFBF0F;
					break;
				case ConsoleStyle.SUCCESS:
					return 0x33cc33;
                    break;
				default:
					return 0xFFFFFF;
					break;
			}
		}

		private function decode(markup:String):String
		{
			var t:String = "";
			var m:Vector.<int> = Vector.<int>([]);
			
			var style2int:Object = ConsoleStyle.name2style;
			
			XML.ignoreWhitespace = false;
			var xml:XML = new XML("<markup>" + markup + "</markup>");
			
			var kids:XMLList = xml.children();
			for each (var node:XML in kids)
			{
				// Add style position
				m[m.length] = t.length;
				
				// Add style value
				if (node.name()  && style2int.hasOwnProperty(node.name()))
				{
					m[m.length] = style2int[node.name().toString().toLowerCase()]; 
				}
				else
				{
					m[m.length] = 0; // Default style
				}
				
				// Build string without markup
				t += node.toString();
			}
			
			meta = m;
			return t;
		}
		
	}
}