package actionScripts.valueObjects
{
	/**
	 * Implementation of Range interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#range
	 */
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

		public static function parse(original:Object):Range
		{
			var vo:Range = new Range();
			vo.start = Position.parse(original.start);
			vo.end = Position.parse(original.end);
			return vo;
		}
	}
}