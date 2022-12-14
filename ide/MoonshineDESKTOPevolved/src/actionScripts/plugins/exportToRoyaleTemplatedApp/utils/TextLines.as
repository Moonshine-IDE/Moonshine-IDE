package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
    
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.Dictionary;
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
		
		public static function substringBetweenTokens(source:String, startToken:String, endToken:String):String
		{
			var start:int = source.indexOf(startToken) + startToken.length;
			var end:int = source.indexOf(endToken);
			
			if (start < startToken.length || end < 0 || end <= start)
			{
				return null;
			}
			
			return source.substring(start, end);
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
		
		public function getSection(start:int, end:int):TextLines
		{
			var section:Array = [];
			
			for (var i:int = start; i <= end; i++)
			{
				section.push(_lines[i]);
			}
			
			return new TextLines(section);
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
		
		public function insertSection(section:TextLines, pos:int):void
		{
			if (pos < 0) return;

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
		
		public function replaceOrInsert(section:TextLines, cursor:String):void
		{
			var firstLine:String = section.lines[0];
			var lastLine:String = section.lines[section.lines.length - 1];
			var startToken:String = TextLines.substringBetweenTokens(firstLine, "GENERATED_", ":");
			var endToken:String = TextLines.substringBetweenTokens(lastLine, "GENERATED_", ":");
			
			
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