package actionScripts.events
{
	import actionScripts.valueObjects.SymbolInformation;

	import flash.events.Event;

	public class SymbolsEvent extends Event
	{
		public static const EVENT_SHOW_SYMBOLS:String = "newShowSymbols";

		public var symbols:Vector.<SymbolInformation>;

		public function SymbolsEvent(type:String, symbols:Vector.<SymbolInformation>)
		{
			super(type, false, false);
			this.symbols = symbols;
		}
	}
}
