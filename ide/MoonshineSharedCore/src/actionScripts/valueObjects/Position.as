package actionScripts.valueObjects
{
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