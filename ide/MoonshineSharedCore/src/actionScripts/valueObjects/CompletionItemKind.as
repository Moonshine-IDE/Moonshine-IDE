package actionScripts.valueObjects
{
	/**
	 * Implementation of CompletionItemKind enum from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new values to this class that are specific
	 * to Moonshine IDE or to a particular language.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
	 * @see https://microsoft.github.io/language-server-protocol/specification#completionItem_resolve
	 */
	public class CompletionItemKind
	{
		public static const TEXT:int = 1;
		public static const METHOD:int = 2;
		public static const FUNCTION:int = 3;
		public static const CONSTRUCTOR:int = 4;
		public static const FIELD:int = 5;
		public static const VARIABLE:int = 6;
		public static const CLASS:int = 7;
		public static const INTERFACE:int = 8;
		public static const MODULE:int = 9;
		public static const PROPERTY:int = 10;
		public static const UNIT:int = 11;
		public static const VALUE:int = 12;
		public static const ENUM:int = 13;
		public static const KEYWORD:int = 14;
		public static const SNIPPET:int = 15;
		public static const COLOR:int = 16;
		public static const FILE:int = 17;
		public static const REFERENCE:int = 18;
		public static const FOLDER:int = 19;
		public static const ENUM_MEMBER:int = 20;
		public static const CONSTANT:int = 21;
		public static const STRUCT:int = 22;
		public static const EVENT:int = 23;
		public static const OPERATOR:int = 24;
		public static const TYPE_PARAMETER:int = 25;
    }
}