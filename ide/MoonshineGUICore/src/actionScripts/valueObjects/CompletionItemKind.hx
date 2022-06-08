package actionScripts.valueObjects;

/**
 * Implementation of CompletionItemKind enum from Language Server Protocol
 * 
 * <p><strong>DO NOT</strong> add new values to this class that are specific
 * to Moonshine IDE or to a particular language.</p>
 * 
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
 * @see https://microsoft.github.io/language-server-protocol/specification#completionItem_resolve
 */
class CompletionItemKind {
	public static final TEXT:Int = 1;
	public static final METHOD:Int = 2;
	public static final FUNCTION:Int = 3;
	public static final CONSTRUCTOR:Int = 4;
	public static final FIELD:Int = 5;
	public static final VARIABLE:Int = 6;
    @:meta(Bindable("change"))
	public static final CLASS:Int = 7;
	public static final INTERFACE:Int = 8;
	public static final MODULE:Int = 9;
	public static final PROPERTY:Int = 10;
	public static final UNIT:Int = 11;
	public static final VALUE:Int = 12;
	public static final ENUM:Int = 13;
	public static final KEYWORD:Int = 14;
	public static final SNIPPET:Int = 15;
	public static final COLOR:Int = 16;
	public static final FILE:Int = 17;
	public static final REFERENCE:Int = 18;
	public static final FOLDER:Int = 19;
	public static final ENUM_MEMBER:Int = 20;
	public static final CONSTANT:Int = 21;
	public static final STRUCT:Int = 22;
	public static final EVENT:Int = 23;
	public static final OPERATOR:Int = 24;
	public static final TYPE_PARAMETER:Int = 25;

	public function new() {}
}