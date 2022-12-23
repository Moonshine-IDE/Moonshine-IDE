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

package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{    
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import flash.text.engine.TextLine;

	public class TextLines  
	{
		public function TextLines(lines:Array)
		{
            _lines = lines;
		}
		
		private var _lines:Array;

		public function get lines():Array
		{
			return _lines;
		}
		
		public function hasContent():Boolean
		{
			return _lines != null && _lines.length > 0;
		}
		
		public static function load(location:FileLocation):TextLines
        {
            var readContent:Object = location.fileBridge.read();
            		
			var lines:Array = [];

			if (readContent)
			{
				var content:String = readContent.toString();
				lines = content.split(File.lineEnding);
			}

            return new TextLines(lines);
        }
        
        public function save(location:FileLocation):void
		{
			try
			{
				var content:String = _lines.join(File.lineEnding);
				location.fileBridge.save(content);
			}
			catch (e:Error)
			{

			}
		}
		
		public function findLine(token:String):int
		{
			for (var i:int = 0; i < _lines.length; i++)
			{
				if (_lines[i].indexOf(token) > -1)
				{
					return i;
				}
			}

			return -1;
		}
		
		public function findAllLines(token:String):Array
		{
			var result:Array = [];
			
			for (var i:int = 0; i < _lines.length; i++)
			{
				if (_lines[i].indexOf(token) > -1)
				{
					result.push(i)
				}
			}

			return result;
		}
		
		public function getSection(start:int, end:int):GeneratedSection
		{
			var section:Array = [];
			
			for (var i:int = start; i <= end; i++)
			{
				section.push(_lines[i]);
			}
			
			return new GeneratedSection(section);
		}
		
		public function findAllSections(startToken:String, endToken:String):Array
		{
			var result:Array = new Array();
			var startTokens:Array = findAllLines(startToken);
			var endTokens:Array = findAllLines(endToken);
			var length:int = startTokens.length;
			if (endTokens.length != length)
			{
				return null;
			}
			for (var i:int = 0; i < length; i++)
			{
				var start:int = startTokens[i];
				var end:int = endTokens[i];
				if(start < end)
				{
					result.push([start, end]);
				}
				else
				{
					return null;
				}
			}
			return result;
		}
		
		public function insertSection(section:GeneratedSection, pos:int):void
		{
			if (pos < 0) return;

			for(var i:int = 0; i < section.lines.length; i++)
			{
				_lines.insertAt(pos + i, section.lines[i]);
			}
		}
		
		public function replaceSection(section:GeneratedSection, start:int, end:int):void
		{
			_lines.splice(start, end - start + 1);
			insertSection(section, start);
		}
		
		public function replaceOrInsert(section:GeneratedSection, cursor:String):void
		{
			var startToken:String = section.getStartToken();
			var endToken:String = section.getEndToken();			
			
			var range:Array = findAllSections(startToken, endToken)[0];
			if (range)
			{
				replaceSection(section, range[0], range[1]);
			}
			else
			{
				var pos:int = findLine(cursor);
				insertSection(section, pos)
			}
		}
	}
}