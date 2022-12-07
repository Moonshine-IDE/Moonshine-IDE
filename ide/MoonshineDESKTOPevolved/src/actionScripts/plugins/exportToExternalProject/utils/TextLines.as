package actionScripts.plugins.exportToExternalProject.utils
{
    
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;

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
            var content:String = location.fileBridge.read().toString();
            		
			var lines:Array = [];

			if (content)
			{
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
		
		public function findFirstLine(token:String):int
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
		
		public function findLastLine(token:String):int
		{
			for (var i:int = _lines.length - 1; i >= 0; i--)
			{
				if (_lines[i].indexOf(token) > -1)
				{
					return i;
				}
			}

			return -1;
		}
		
		public function getLine(token:String):String
		{
			var index:int = findFirstLine(token);
			if(index > -1)
			{
				return _lines[index];
			}
			else
			{
				return null;
			}
		}
		
		public function replaceLine(pattern:String, replacement:String):void
		{
			var pos:int = findFirstLine(pattern);
			_lines[pos] = _lines[pos].replace(pattern, replacement);
		}
		
		public function findSection(startToken:String, endToken:String):Array
		{
			var start:int = findFirstLine(startToken);
			var end:int = findLastLine(endToken);
			
			if (start < end)
			{
				return [start, end];
			}
			else
			{
				return null;
			}
		}
		
		public function getSection(startToken:String, endToken:String):TextLines
		{
			var range:Array = findSection(startToken, endToken);
			var start:int = range[0];
			var end:int = range[1];
			var section:Array = [];
			
			for (var i:int = start; i <= end; i++)
			{
				section.push(_lines[i]);
			}
			
			return new TextLines(section);
		}	
		
		public function insertSection(section:TextLines, pos:int):void
		{
			for(var i:int = 0; i < section.lines.length; i++)
			{
				_lines.insertAt(pos + i, section.lines[i]);
			}
		}
		
		public function replaceSection(section:TextLines, start:int, end:int):void
		{
			_lines.splice(start, end - start + 1);
			insertSection(section, start);
		}
		
		public function replaceOrInsert(section:TextLines, startToken:String, endToken:String, cursor:String):void
		{
			var range:Array = findSection(startToken, endToken);
			if (range)
			{
				replaceSection(section, range[0], range[1]);
			}
			else
			{
				var pos:int = findFirstLine(cursor);
				insertSection(section, pos)
			}
		}
	}
}