package actionScripts.valueObjects
{
	/**
	 * Implementation of SymbolKind enum from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new values to this class that are specific
	 * to Moonshine IDE or to a particular language.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
	 * @see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
	 */
	public class SymbolKind
	{
		public static const FILE:int = 1;
		public static const MODULE:int = 2;
		public static const NAMESPACE:int = 3;
		public static const PACKAGE:int = 4;
		public static const CLASS:int = 5;
		public static const METHOD:int = 6;
		public static const PROPERTY:int = 7;
		public static const FIELD:int = 8;
		public static const CONSTRUCTOR:int = 9;
		public static const ENUM:int = 10;
		public static const INTERFACE:int = 11;
		public static const FUNCTION:int = 12;
		public static const VARIABLE:int = 13;
		public static const CONSTANT:int = 14;
		public static const STRING:int = 15;
		public static const NUMBER:int = 16;
		public static const BOOLEAN:int = 17;
		public static const ARRAY:int = 18;
		public static const OBJECT:int = 19;
		public static const KEY:int = 20;
		public static const NULL:int = 21;
		public static const ENUM_MEMBER:int = 22;
		public static const STRUCT:int = 23;
		public static const EVENT:int = 24;
		public static const OPERATOR:int = 25;
		public static const TYPE_PARAMETER:int = 26;
    }
}