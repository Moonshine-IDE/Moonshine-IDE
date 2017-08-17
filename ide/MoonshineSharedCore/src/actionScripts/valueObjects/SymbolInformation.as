package actionScripts.valueObjects
{
	public class SymbolInformation
	{
		public static const KIND_FILE:int = 1;
		public static const KIND_MODULE:int = 2;
		public static const KIND_NAMESPACE:int = 3;
		public static const KIND_PACKAGE:int = 4;
		public static const KIND_CLASS:int = 5;
		public static const KIND_METHOD:int = 6;
		public static const KIND_PROPERTY:int = 7;
		public static const KIND_FIELD:int = 8;
		public static const KIND_CONSTRUCTOR:int = 9;
		public static const KIND_ENUM:int = 10;
		public static const KIND_INTERFACE:int = 11;
		public static const KIND_FUNCTION:int = 12;
		public static const KIND_VARIABLE:int = 13;
		public static const KIND_CONSTANT:int = 14;
		public static const KIND_STRING:int = 15;
		public static const KIND_NUMBER:int = 16;
		public static const KIND_BOOLEAN:int = 17;
		public static const KIND_ARRAY:int = 18;

		public function SymbolInformation()
		{
		}
		
		public var name:String;
		public var kind:int;
		public var location:Location;
	}
}
