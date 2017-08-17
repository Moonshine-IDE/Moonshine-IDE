package actionScripts.valueObjects
{
	public class Range
	{
		public var start:Position;

		/**
		 * The range's end position.
		 */
		public var end:Position;

		public function Range(start:Position = null, end:Position = null)
		{
			this.start = start;
			this.end = end;
		}
	}
}