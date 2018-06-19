package actionScripts.valueObjects
{
	/**
	 * Implementation of Location interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#location
	 */
	public class Location
	{
		public var uri:String;
		public var range:Range;

		public function Location(uri:String = null, range:Range = null)
		{
			this.uri = uri;
			this.range = range;
		}
	}
}
