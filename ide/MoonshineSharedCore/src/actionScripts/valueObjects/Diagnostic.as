package actionScripts.valueObjects
{
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
