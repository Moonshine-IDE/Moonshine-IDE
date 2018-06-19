package actionScripts.valueObjects
{
	/**
	 * Implementation of Position interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#position
	 */
	public class Position
	{
		public var line:int;

		/**
		 * Character offset on a line in a document (zero-based).
		 */
		public var character:int;

		public function Position(line:int = 0, character:int = 0)
		{
			this.line = line;
			this.character = character;
		}
	}
}