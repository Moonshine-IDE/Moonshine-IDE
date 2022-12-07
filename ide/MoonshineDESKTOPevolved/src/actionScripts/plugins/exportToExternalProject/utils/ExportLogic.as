package actionScripts.plugins.exportToExternalProject.utils
{
    
	import actionScripts.factory.FileLocation;
	import flash.filesystem.File;

	public class ExportLogic  
	{		
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
        
        public static function save(textLines:TextLines, location:FileLocation):void
		{
			try
			{
				var content:String = textLines.lines.join(File.lineEnding);
				location.fileBridge.save(content);
			}
			catch (e:Error)
			{

			}
		}
		
		public static function hasContent(textLines:TextLines):Boolean
		{
			return textLines != null && textLines.lines.length > 0;
		}
		
		public static function isRoyaleApp(textLines:TextLines):Boolean
		{
			return textLines.findFirstLine(ExportContext.J_APPLICATION) > -1;
		}
		
		public static function hasSrcFolder(location:FileLocation):Boolean
		{
			return new RegExp("^\\S+\\bsrc\\b").test(location.fileBridge.nativePath);
		}
	}
}