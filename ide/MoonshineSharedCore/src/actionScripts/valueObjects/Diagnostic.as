package actionScripts.valueObjects
{
	/**
	 * Implementation of Diagnostic interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#diagnostic
	 */
	public class Diagnostic
	{
		public static const SEVERITY_ERROR:int = 1;
		public static const SEVERITY_WARNING:int = 2;
		public static const SEVERITY_INFORMATION:int = 3;
		public static const SEVERITY_HINT:int = 4;

		public function Diagnostic()
		{
		}

		public var path:String;
		public var message:String;
		public var range:Range;
		public var severity:int;
		public var code:String;
	}
}
