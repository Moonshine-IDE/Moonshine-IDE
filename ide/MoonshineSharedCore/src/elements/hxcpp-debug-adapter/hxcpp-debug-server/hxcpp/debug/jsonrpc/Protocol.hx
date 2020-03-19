package hxcpp.debug.jsonrpc;

abstract RequestMethod<TParams, TResult>(String) to String {
	public inline function new(method)
		this = method;
}

abstract NotificationMethod<TParams>(String) to String {
	public inline function new(method)
		this = method;
}

typedef Message = {
	@:optional var id:Int;
	@:optional var method:String;
	@:optional var params:Dynamic;
	@:optional var result:Dynamic;
	@:optional var error:Error;
}

@:enum
abstract ErrorCode(Int) to Int {
	var internal = 500;
	var wrongRequest = 422;
}

typedef Error = {
	var code:ErrorCode;
	var message:String;
}

@:publicFields
class Protocol {
	static inline var Pause = new RequestMethod<{}, Void>("pause");
	static inline var Continue = new RequestMethod<{threadId:Int}, Void>("continue");
	static inline var StepIn = new RequestMethod<{}, Void>("stepIn");
	static inline var Next = new RequestMethod<{}, Void>("next");
	static inline var StepOut = new RequestMethod<{}, Void>("stepOut");
	static inline var StackTrace = new RequestMethod<{threadId:Int}, Array<StackFrameInfo>>("stackTrace");
	static inline var SetBreakpoints = new RequestMethod<SetBreakpointsParams, Array<{id:Int}>>("setBreakpoints");
	static inline var SetBreakpoint = new RequestMethod<SetBreakpointParams, {id:Int}>("setBreakpoint");
	static inline var RemoveBreakpoint = new RequestMethod<{id:Int}, Void>("removeBreakpoint");
	static inline var SwitchFrame = new RequestMethod<{id:Int}, Void>("switchFrame");
	static inline var GetScopes = new RequestMethod<{frameId:Int}, Array<ScopeInfo>>("getScopes");
	static inline var GetVariables = new RequestMethod<{variablesReference:Int, ?start:Int, ?count:Int}, Array<VarInfo>>("getVariables");
	// static inline var GetScopeVariables = new RequestMethod<{},Array<VarInfo>>("getScopeVariables");
	// static inline var GetStructure = new RequestMethod<{},Array<VarInfo>>("getStructure");
	static inline var SetVariable = new RequestMethod<{expr:String, value:String}, VarInfo>("setVariable");
	static inline var Threads = new RequestMethod<{}, Array<ThreadInfo>>("threads");
	static inline var Evaluate = new RequestMethod<{expr:String, frameId:Int}, VarInfo>("evaluate");
	static inline var Completions = new RequestMethod<CompletionsArguments, Array<CompletionItem>>("completions");
	static inline var SetExceptionOptions = new RequestMethod<Array<String>, Void>("setExceptionOptions");
	static inline var BreakpointStop = new NotificationMethod<{threadId:Int}>("breakpointStop");
	static inline var ExceptionStop = new NotificationMethod<{text:String}>("exceptionStop");
	static inline var PauseStop = new NotificationMethod<{threadId:Int}>("pauseStop");
	static inline var ThreadStart = new NotificationMethod<{threadId:Int}>("threadStart");
	static inline var ThreadExit = new NotificationMethod<{threadId:Int}>("ThreadExit");
}

typedef SetBreakpointsParams = {
	var file:String;
	var breakpoints:Array<{line:Int, ?column:Int, ?condition:String}>;
}

typedef SetBreakpointParams = {
	var file:String;
	var line:Int;
	@:optional var column:Int;
}

typedef StackFrameInfo = {
	var id:Int;
	var name:String;
	var source:String;
	var line:Int;
	var column:Int;
	var endLine:Int;
	var endColumn:Int;
	var artificial:Bool;
}

/** Info about a scope **/
typedef ScopeInfo = {
	/** Scope identifier to use for the `vars` request. **/
	var id:Int;

	/** Name of the scope (e.g. Locals, Captures, etc) **/
	var name:String;

	/** Position information about scope boundaries, if present **/
	@:optional var pos:{
		source:String,
		line:Int,
		column:Int,
		endLine:Int,
		endColumn:Int
	};

	/** The number of named variables in this scope.
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
	 */
	@:optional var namedVariables:Int;

	/** The number of indexed variables in this scope.
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
	 */
	@:optional var indexedVariables:Int;
}

/** Info about a scope variable or its subvariable (a field, array element or something) as returned by Haxe eval debugger **/
typedef VarInfo = {
	/** Variable/field name, for array elements or enum ctor arguments looks like `[0]` **/
	var name:String;

	/** Value type **/
	var type:String;

	/** Current value to display (structured child values are rendered with `...`) **/
	var value:String;

	/** If variablesReference is > 0, the variable is structured and its children can be retrieved by passing variablesReference to the VariablesRequest. */
	var variablesReference:Int;

	/** The number of named child variables.
		The client can use this optional information to present the children in a paged UI and fetch them in chunks.
	 */
	@:optional var namedVariables:Int;

	/** The number of indexed child variables.
		The client can use this optional information to present the children in a paged UI and fetch them in chunks.
	 */
	@:optional var indexedVariables:Int;
}

typedef ThreadInfo = {
	var id:Int;
	var name:String;
}

typedef AccessExpr = String;

typedef CompletionsArguments = {
	@:optional var frameId:Int;
	var text:String;
	var column:Int;
	@:optional var line:Int;
}

typedef CompletionItem = {
	var label:String;
	@:optional var text:String;
	@:optional var start:Int;
	@:optional var length:Int;
};
