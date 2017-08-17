package actionScripts.valueObjects
{
	public class TextEdit
	{
		public var range: Range;
		
		/**
		 * The string to be inserted. For delete operations use an
		 * empty string.
		 */
		public var newText: String ="";
		public function TextEdit()
		{
		}
	}
}