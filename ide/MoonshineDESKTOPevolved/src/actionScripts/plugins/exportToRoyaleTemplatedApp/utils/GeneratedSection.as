package actionScripts.plugins.exportToRoyaleTemplatedApp.utils
{
    import actionScripts.plugins.exportToRoyaleTemplatedApp.utils.TextLines;
    import haxe.Exception;

	public class GeneratedSection extends TextLines 
	{		
		private var _fullName:String;

		private function get fullName():String
		{
			return _fullName;
		}
		
		public function GeneratedSection(lines:Array)
		{
			super(lines);
			
			var name:String = betweenTokens(lines[0], ExportConstants.NAME_START, ExportConstants.NAME_END);
			_fullName = ExportConstants.NAME_START + name;			
		}
		
		private static function betweenTokens(source:String, startToken:String, endToken:String):String
		{
			var start:int = source.indexOf(startToken) + startToken.length;
			var end:int = source.indexOf(endToken);
			
			return source.substring(start, end);
		}
		
		public function getStartToken():String
		{
			return betweenTokens(lines[0], ExportConstants.TOKEN_START, ExportConstants.TOKEN_END);
		}
		
		public function getEndToken():String
		{
			return betweenTokens(lines[lines.length - 1], ExportConstants.TOKEN_START, ExportConstants.TOKEN_END);
		}
	}
}