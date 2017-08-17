package actionScripts.valueObjects
{
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
