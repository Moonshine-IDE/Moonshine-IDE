package actionScripts.valueObjects
{
	public class DocumentSymbol
	{
		public function DocumentSymbol()
		{
		}

		public var name:String;
		public var detail:String;
		public var kind:int;
		public var deprecated:Boolean;
		public var range:Range;
		public var selectionRange:Range;
		public var children:Vector.<DocumentSymbol>;
	}
}
