package actionScripts.events
{
	import actionScripts.valueObjects.SymbolInformation;

	import flash.events.Event;

	public class SymbolsEvent extends Event
	{
		public static const EVENT_SHOW_SYMBOLS:String = "newShowSymbols";

		//contains SymbolInformation or DocumentSymbol
		public var symbols:Array;

		public function SymbolsEvent(type:String, symbols:Array)
		{
			super(type, false, false);
			this.symbols = symbols;
		}
	}
}
