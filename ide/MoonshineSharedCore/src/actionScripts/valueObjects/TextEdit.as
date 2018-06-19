package actionScripts.valueObjects
{
	/**
	 * Implementation of TextEdit interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textedit
	 */
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