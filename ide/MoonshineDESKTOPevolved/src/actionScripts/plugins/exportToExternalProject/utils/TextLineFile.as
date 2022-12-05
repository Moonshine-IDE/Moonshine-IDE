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
package actionScripts.plugins.exportToExternalProject.utils
{
    import actionScripts.factory.FileLocation;

	import flash.filesystem.File;

	public class TextLineFile
	{
		private const JEWEL_ROYALE_APPLICATION_FILE:String = "<j:Application";
		private const APPLICATION_CSS_CURSOR:String = "APPLICATION_CSS_CURSOR";
		private const GENERATED_MAINCONTENTMANAGER_CURSOR:String = "GENERATED_MAINCONTENTMANAGER_CURSOR";
		private const GENERATED_MENU_CURSOR:String = "GENERATED_MENU_CURSOR";
		private const GENERATED_VIEWS_CURSOR:String = "GENERATED_VIEWS_CURSOR";

		private const START_GENERATED_SCRIPT_CSSSTYLES:String = "START_GENERATED_SCRIPT_CSSSTYLES_";
		private const END_GENERATED_SCRIPT_CSSSTYLES:String = "END_GENERATED_SCRIPT_CSSSTYLES_";

		private const START_GENERATED_MAINCONTENTMANAGER:String = "START_GENERATED_SCRIPT_MAINCONTENTMANAGER_";
		private const END_GENERATED_MAINCONTENTMANAGER:String = "END_GENERATED_SCRIPT_MAINCONTENTMANAGER_";

		private const START_GENERATED_MENU:String = "START_GENERATED_MENU_";
		private const END_GENERATED_MENU:String = "END_GENERATED_MENU_";

		private const START_GENERATED_SCROLLABLE_SECTION:String = "START_GENERATED_SCROLLABLE_SECTION_";
		private const END_GENERATED_SCROLLABLE_SECTION:String = "END_GENERATED_SCROLLABLE_SECTION_";

		public function TextLineFile(lines:Array)
		{
            _lines = lines;
		}

		private var _lines:Array;

		public function get lines():Array
		{
			return _lines;
		}

        public static function load(path:String):TextLineFile
        {
            var file:FileLocation = new FileLocation(path);
            var content:String = file.fileBridge.read().toString();
			var fileLines:Array = [];

			if (content)
			{
				fileLines = content.split(File.lineEnding);
			}

            return new TextLineFile(fileLines);
        }

		public function save(path:String):void
		{
			try
			{
				var content:String = this.lines.join(File.lineEnding);
				var file:FileLocation = new FileLocation(path);
				file.fileBridge.save(content);
			}
			catch (e:Error)
			{

			}
		}

		public function hasContent():Boolean
		{
			return lines != null && lines.length > 0;
		}

		public function checkIfRoyaleApplicationFile():Boolean
		{
			var cursor:int = find(JEWEL_ROYALE_APPLICATION_FILE);

			return cursor > -1;
		}

		public function insertApplicationCssCursor(content:Array):void
		{
			var cursor:int = find(APPLICATION_CSS_CURSOR);
			if(cursor > -1)
			{
				for each (var line:String in content)
				{
					lines.insertAt(cursor, line);
					cursor++;
				}
			}
		}

		public function insertMainContentManagerCursor(content:Array):void
		{
			var cursor:int = find(GENERATED_MAINCONTENTMANAGER_CURSOR);
			if(cursor > -1)
			{
				for each (var line:String in content)
				{
					lines.insertAt(cursor, line);
					cursor++;
				}
			}
		}

		public function insertMenuContentCursor(content:Array):void
		{
			var cursor:int = find(GENERATED_MENU_CURSOR);
			if(cursor > -1)
			{
				for each (var line:String in content)
				{
					lines.insertAt(cursor, line);
					cursor++;
				}
			}
		}

		public function insertViewsCursor(content:Array):void
		{
			var cursor:int = find(GENERATED_VIEWS_CURSOR);
			if(cursor > -1)
			{
				for each (var line:String in content)
				{
					lines.insertAt(cursor, line);
					cursor++;
				}
			}
		}

		public function findScriptCssStyles(projectName:String):Array
		{
			var outFind:Array = [];

			var startToken:String = START_GENERATED_SCRIPT_CSSSTYLES + projectName;
			var endToken:String = END_GENERATED_SCRIPT_CSSSTYLES + projectName;

			var findScript:Array = findPair(startToken, endToken);

			for (var i:int = findScript[0]; i <= findScript[1]; i++)
			{
				var line:String = lines[i];
				outFind.push(line);
			}

			return outFind;
		}

		public function findMainContentManager(projectName:String):Array
		{
			var outFind:Array = [];

			var startToken:String = START_GENERATED_MAINCONTENTMANAGER + projectName;
			var endToken:String = END_GENERATED_MAINCONTENTMANAGER + projectName;

			var findScript:Array = findPair(startToken, endToken);

			for (var i:int = findScript[0]; i <= findScript[1]; i++)
			{
				var line:String = lines[i];
				outFind.push(line);
			}

			return outFind;
		}

		public function findMenuContent(projectName:String):Array
		{
			var outFind:Array = [];

			var startToken:String = START_GENERATED_MENU + projectName;
			var endToken:String = END_GENERATED_MENU + projectName;

			var findAll:Array = findAllPairs(startToken, endToken);

			for (var i:int = 0; i < findAll.length; i++)
			{
				for (var j:int = findAll[i][0]; j <= findAll[i][1]; j++)
				{
					var line:String = lines[j];
					outFind.push(line);
				}
			}

			return outFind;
		}

		public function findViews(projectName:String):Array
		{
			var outFind:Array = [];

			var startToken:String = START_GENERATED_SCROLLABLE_SECTION + projectName;
			var endToken:String = END_GENERATED_SCROLLABLE_SECTION + projectName;

			var findAll:Array = findAllPairs(startToken, endToken);

			for (var i:int = 0; i < findAll.length; i++)
			{
				for (var j:int = findAll[i][0]; j <= findAll[i][1]; j++)
				{
					var line:String = lines[j];
					outFind.push(line);
				}
			}

			return outFind;
		}

		private function find(token:String):int
		{
			// iterate over lines
			// use string.find on evry line
			// if found return index
			// if not found return -1
			var linesCount:int = lines.length;
			var itemIndex:int = -1;

			for (var i:int = 0; i < linesCount; i++)
			{
				var line:String = lines[i];
				var lineIndexOf:int = line.indexOf(token);
				if (lineIndexOf > -1)
				{
					itemIndex = i;
					break;
				}
			}

			return itemIndex;
		}

		private function findPair(beginToken:String, endToken:String):Array
		{
			var linesCount:int = lines.length;
			var beginTokenIndex:int = -1;
			var endTokenIndex:int = -1;

			for (var i:int = 0; i < linesCount; i++)
			{
				var line:String = lines[i];
				if (beginTokenIndex == -1)
				{
					var beginIndexOf:int = line.indexOf(beginToken);
					if (beginIndexOf > -1)
					{
						beginTokenIndex = i;
						continue;
					}
				}

				if (endTokenIndex == -1)
				{
					var endIndexOf:int = line.indexOf(endToken);
					if (endIndexOf > -1)
					{
						endTokenIndex = i;
						continue;
					}
				}

				if (beginTokenIndex > -1 && endTokenIndex > -1)
				{
					break;
				}
			}

			return [beginTokenIndex, endTokenIndex];
		}

		private function findAllPairs(beginToken:String, endToken:String):Array
		{
			var pairs:Array = [];
			var linesCount:int = lines.length;
			var beginTokenIndex:int = -1;
			var endTokenIndex:int = -1;

			for (var i:int = 0; i < linesCount; i++)
			{
				var line:String = lines[i];
				if (beginTokenIndex == -1)
				{
					var beginIndexOf:int = line.indexOf(beginToken);
					if (beginIndexOf > -1)
					{
						beginTokenIndex = i;
					//	continue;
					}
				}

				if (endTokenIndex == -1)
				{
					var endIndexOf:int = line.indexOf(endToken);
					if (endIndexOf > -1)
					{
						endTokenIndex = i;
						//continue;
					}
				}

				if (beginTokenIndex > -1 && endTokenIndex > -1)
				{
					pairs.push([beginTokenIndex, endTokenIndex]);

					beginTokenIndex = -1;
					endTokenIndex = -1;
				}
			}

			return pairs;
		}
	}
}
