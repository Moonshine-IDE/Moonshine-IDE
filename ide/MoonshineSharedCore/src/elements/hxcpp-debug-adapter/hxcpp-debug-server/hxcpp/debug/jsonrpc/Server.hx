package hxcpp.debug.jsonrpc;

import hxcpp.debug.jsonrpc.VariablesPrinter;
import hxcpp.debug.jsonrpc.Protocol;
#if haxe4
import sys.thread.Thread;
import sys.thread.Mutex;
import sys.thread.Deque;
#else
import cpp.vm.Thread;
import cpp.vm.Mutex;
import cpp.vm.Deque;
#end
import cpp.vm.Debugger;
import hxcpp.debug.jsonrpc.eval.Parser;
import hxcpp.debug.jsonrpc.eval.Interp;
import hxcpp.debug.jsonrpc.eval.Expr;
import hxcpp.debug.jsonrpc.eval.Interp;

@:enum abstract ScopeId(String) to String {
	var members = "Members";
	var locals = "Locals";
}

typedef BreakpointInfo = {
	var id:Int;
	var line:Int;
	@:optional var column:Int;
	@:optional var condition:Expr;
}

private class References {
	static var lastId:Int = 1000;

	var references:Map<Int, Value>;

	public function new() {
		references = new Map<Int, Value>();
	}

	public function create(ref:Value):Int {
		var id = lastId;
		references[lastId] = ref;
		lastId++;
		return id;
	}

	public function get(id:Int):Value {
		return references[id];
	}

	public function clear() {
		references = new Map<Int, Value>();
	}
}

@:keep
class Server {
	var host:String;
	var port:Int;
	var listening:sys.net.Socket;
	var socket:sys.net.Socket;
	var stateMutex:Mutex;
	var socketMutex:Mutex;
	var currentThreadInfo:cpp.vm.ThreadInfo;
	var scopes:Map<ScopeId, Array<String>>;
	var threads:Map<Int, String>;
	var breakpoints:Map<String, Array<BreakpointInfo>>;
	var references:References;
	var started:Bool;
	var path2file:Map<String, String>;
	var file2path:Map<String, String>;
	var mainThread:Thread;
	var interp:Interp;
	var parser:Parser;
	var isWindows:Bool;

	static var startQueue:Deque<Bool> = new Deque<Bool>();
	@:keep static var inst = {
		var host:String = Macro.getDefinedValue("HXCPP_DEBUG_HOST", "127.0.0.1");
		var port:Int = Std.parseInt(Macro.getDefinedValue("HXCPP_DEBUG_PORT", "6972"));
		new Server(host, port);
	}

	public function new(host:String, port:Int) {
		trace('Debug Server Started:');
		this.host = host;
		this.port = port;
		stateMutex = new Mutex();
		socketMutex = new Mutex();
		scopes = new Map<ScopeId, Array<String>>();
		breakpoints = new Map<String, Array<BreakpointInfo>>();
		references = new References();
		threads = new Map<Int, String>();
		path2file = new Map<String, String>();
		file2path = new Map<String, String>();
		mainThread = Thread.current();
		parser = new Parser();
		started = false;
		isWindows = Sys.systemName() == "Windows";

		Debugger.enableCurrentThreadDebugging(false);
		if (connect()) {
			Thread.create(debuggerThreadMain);
			startQueue.pop(true);
			Debugger.enableCurrentThreadDebugging(true);
			startQueue.pop(true);
		} else {
			waitForAttach();
		}
	}

	private function connect():Bool {
		var socket:sys.net.Socket = new sys.net.Socket();
		socket.input.bigEndian = false;
		socket.output.bigEndian = false;

		try {
			var host = new sys.net.Host(host);
			if (host.ip == 0) {
				throw "Name lookup error.";
			}
			socket.connect(host, port);
			log('Connected to vsc debugger server at $host:$port');

			this.socket = socket;
			return true;
		} catch (e:Dynamic) {
			log('Failed to connect to vsc debugger server at $host:$port');
		}
		closeSocket();
		return false;
	}

	function waitForAttach() {
		var onMainThread = new haxe.Timer(500);
		onMainThread.run = function() {
			var callOnMainThread:Void->Void = Thread.readMessage(false);
			if (callOnMainThread == null)
				return;
			callOnMainThread();
		}
		Thread.create(createListeningSocket);
	}

	function createListeningSocket() {
		if (listening == null) {
			var socket:sys.net.Socket = new sys.net.Socket();
			socket.bind(new sys.net.Host("localhost"), 6972);
			socket.listen(1);
			listening = socket;
		}
		while (true) {
			var connectedSocket = listening.accept();
			mainThread.sendMessage(function() {
				if (this.socket == null) {
					this.socket = connectedSocket;
					onDebuggerAttached();
				}
			});
		}
	}

	function onDebuggerAttached() {
		Debugger.enableCurrentThreadDebugging(false);
		Thread.create(debuggerThreadMain);
		startQueue.pop(true);
		Debugger.enableCurrentThreadDebugging(true);
	}

	function onDebuggerDetached() {
		closeSocket();
		Debugger.setEventNotificationHandler(function(_, _, _, _, _, _, _) {});
		stateMutex.acquire();
		if (currentThreadInfo != null) {
			var threadId:Int = currentThreadInfo.number;
			currentThreadInfo = null;
			Debugger.continueThreads(threadId, 1);
			mainThread.sendMessage(function() {
				Debugger.enableCurrentThreadDebugging(false);
			});
		}
		stateMutex.release();
	}

	private function debuggerThreadMain() {
		Debugger.setEventNotificationHandler(handleThreadEvent);
		Debugger.enableCurrentThreadDebugging(false);
		Debugger.breakNow(true);

		var fullPathes = Debugger.getFilesFullPath();
		var files = Debugger.getFiles();
		for (i in 0...files.length) {
			var file = files[i];
			var path = fullPathes[i];
			path2file[path2Key(path)] = file;
			file2path[path2Key(file)] = path;
		}

		var classes = Debugger.getClasses();
		@:privateAccess Interp.globals = new Map<String, Dynamic>();
		// globals declared inside hxcpp library not exposed to classes
		Interp.globals.set("Math", Math);
		Interp.globals.set("String", String);

		var appStructure = {};
		for (c in classes) {
			var pack = c.split(".");
			var klass = Type.resolveClass(c);
			var globalValue = klass;
			var currentNode = appStructure;

			var globalName = pack.pop();
			while (pack.length > 0) {
				var pathPart = pack.shift();
				if (!Reflect.hasField(currentNode, pathPart)) {
					Reflect.setField(currentNode, pathPart, {});
				}
				currentNode = Reflect.field(currentNode, pathPart);
			}
			Reflect.setField(currentNode, globalName, globalValue);
		}

		for (key in Reflect.fields(appStructure)) {
			var value = Reflect.field(appStructure, key);
			Interp.globals.set(key, value);
		}

		startQueue.push(true);
		while (true) {
			var m = try {
				readMessage();
			} catch (e:Dynamic) {
				onDebuggerDetached();
				return;
			}
			try {
				processMessage(m);
			} catch (e:Dynamic) {
				m.error = {code: ErrorCode.internal, message: Std.string(e)};
			}
			try {
				sendResponse(m);
			} catch (e:Dynamic) {
				onDebuggerDetached();
				return;
			}
		}
	}

	private function readMessage():Message {
		if (socket == null)
			return null;

		var length:Int = socket.input.readInt32();
		// trace('Message Length: $length');
		var rawString = socket.input.readString(length);
		return haxe.Json.parse(rawString);
	}

	private function sendResponse(m:Message) {
		if (socket == null)
			return;

		socketMutex.acquire();
		var serialized:String = haxe.Json.stringify(m);
		socket.output.writeInt32(serialized.length);
		socket.output.writeString(serialized);
		// trace('sendResponse: ${m.id} ${m.method}');
		socketMutex.release();
	}

	private function processMessage(m:Message) {
		switch (m.method) {
			case Protocol.SetBreakpoints:
				var params:SetBreakpointsParams = m.params;
				var result = [];

				if (!breakpoints.exists(path2Key(params.file)))
					breakpoints[path2Key(params.file)] = [];

				for (rm in breakpoints[path2Key(params.file)]) {
					Debugger.deleteBreakpoint(rm.id);
				}
				for (b in params.breakpoints) {
					var bInfo:BreakpointInfo = {id: 0, line: b.line};
					if (b.condition != null) {
						try {
							var ast:Expr = parser.parseString(b.condition);
							bInfo.condition = ast;
						} catch (e:Dynamic) {
							m.error = {code: ErrorCode.wrongRequest, message: "can't parse condition"};
							continue;
						}
					}
					bInfo.id = Debugger.addFileLineBreakpoint(path2file[path2Key(params.file)], bInfo.line);
					result.push(bInfo);
				}
				breakpoints[path2Key(params.file)] = result;
				m.result = [for (b in result) b.id];

			case Protocol.Pause:
				Debugger.breakNow(true);

			case Protocol.Continue:
				Debugger.continueThreads(m.params.threadId, 1);
				if (!started) {
					started = true;
					startQueue.push(true);
				}

			case Protocol.Threads:
				stateMutex.acquire();
				m.result = [
					for (tid in threads.keys())
						{id: tid, name: threads[tid]}
				];
				stateMutex.release();

			case Protocol.GetScopes:
				m.result = [];

				stateMutex.acquire();
				if (currentThreadInfo != null) {
					var threadId:Int = currentThreadInfo.number;
					var frameId:Int = m.params.frameId;

					var stackVariables:Array<String> = Debugger.getStackVariables(threadId, frameId, false);
					var localsId = 0;
					var localsNames:Array<String> = [];
					var localsVals:Array<Dynamic> = [];
					for (varName in stackVariables) {
						if (varName == "this") {
							var value:Dynamic = Debugger.getStackVariableValue(threadId, frameId, "this", false);
							var id = references.create(VariablesPrinter.resolveValue(value));
							m.result.push({id: id, name: ScopeId.members});
						} else {
							if (localsId == 0) {
								localsId = references.create(NameValueList(localsNames, localsVals));
								m.result.push({id: localsId, name: ScopeId.locals});
							}
							localsNames.push(varName);
							localsVals.push(Debugger.getStackVariableValue(threadId, frameId, varName, false));
						}
					}
				}
				stateMutex.release();

			case Protocol.GetVariables:
				m.result = [];

				stateMutex.acquire();

				try {
					if (currentThreadInfo != null) {
						var refId = m.params.variablesReference;
						var value:Value = references.get(refId);
						var vars = VariablesPrinter.getInnerVariables(value, m.params.start, m.params.count);

						for (v in vars) {
							var varInfo:VarInfo = {
								name: v.name,
								type: v.type,
								value: "",
								variablesReference: 0,
							}
							switch (v.value) {
								case NameValueList(names, values):
									throw "impossible";

								case IntIndexed(value, length, _):
									var refId = references.create(v.value);
									varInfo.variablesReference = refId;
									varInfo.indexedVariables = length;
									varInfo.value = Std.string(value);

								case StringIndexed(value, printedValue, names, _):
									var refId = references.create(v.value);
									varInfo.variablesReference = refId;
									varInfo.namedVariables = names.length;
									varInfo.value = printedValue;

								case Single(value):
									varInfo.value = value;
							}
							m.result.push(varInfo);
						}
					}
				} catch (e:Dynamic) {
					stateMutex.release();
					throw e;
				}
				stateMutex.release();

			case Protocol.SetVariable if (currentThreadInfo != null):
				stateMutex.acquire();
				var name = m.params.expr;
				var value:String = m.params.value;
				var stringPattern = ~/"(.*?)"/;
				if (stringPattern.match(value)) {
					value = stringPattern.matched(1);
				}
				var frameId = currentThreadInfo.stack.length - 3; // top of stack, minus cpp.vm.Debugger and jsonrpc.Server frames
				var result = Debugger.setStackVariableValue(currentThreadInfo.number, frameId, name, value, false);
				m.result = {
					value: switch (VariablesPrinter.resolveValue(result)) {
						case Single(val): val;
						case _: Std.string(result);
					}
				};
				stateMutex.release();

			case Protocol.Completions if (currentThreadInfo != null):
				stateMutex.acquire();
				var frameId = getTopFrame();
				var completions:Array<CompletionItem> = [];
				var variables = Debugger.getStackVariables(currentThreadInfo.number, frameId, false);
				for (variable in variables) {
					completions.push({label: variable});
				}
				// TODO: this can cause a "critical error in debugger thread" for some reason?
				/*if (variables.indexOf("this") != -1) {
					var thisReference = Debugger.getStackVariableValue(currentThreadInfo.number, frameId, "this", false);
					for (field in Type.getInstanceFields(thisReference)) {
						completions.push({label: field});
					}
				}*/
				m.result = completions;
				stateMutex.release();

			case Protocol.Evaluate:
				var expr = m.params.expr;
				m.result = {
					name: expr,
					value: "",
					type: "",
					variablesReference: 0
				};
				stateMutex.acquire();
				if (currentThreadInfo != null) {
					var threadId = currentThreadInfo.number;
					var frameId = m.params.frameId;
					var v = VariablesPrinter.evaluate(parser, expr, threadId, frameId);

					if (v != null) {
						m.result.type = v.type;
						switch (v.value) {
							case NameValueList(names, values):
								throw "impossible";

							case IntIndexed(value, length, _):
								var refId = references.create(v.value);
								m.result.variablesReference = refId;
								m.result.indexedVariables = length;
								m.result.value = Std.string(value);

							case StringIndexed(value, printedValue, names, _):
								var refId = references.create(v.value);
								m.result.variablesReference = refId;
								m.result.namedVariables = names.length;
								m.result.value = printedValue;

							case Single(value):
								m.result.value = value;
						}
					}
				}
				stateMutex.release();

			case Protocol.StackTrace:
				m.result = [];

				stateMutex.acquire();
				if (currentThreadInfo != null) {
					var i = 0;
					for (s in currentThreadInfo.stack) {
						if (s.fileName == "hxcpp/debug/jsonrpc/Server.hx")
							break;

						m.result.unshift({
							id: i++,
							name: '${s.className}.${s.functionName}',
							source: file2path[path2Key(s.fileName)],
							line: s.lineNumber,
							column: 0,
							artificial: false
						});
					}
				}
				stateMutex.release();

			case Protocol.Next:
				Debugger.stepThread(0, Debugger.STEP_OVER, 1);

			case Protocol.StepIn:
				Debugger.stepThread(0, Debugger.STEP_INTO, 1);

			case Protocol.StepOut:
				Debugger.stepThread(0, Debugger.STEP_OUT, 1);
		}
	}

	private function sendEvent<T>(event:NotificationMethod<T>, ?params:T) {
		var m = {
			method: event,
			params: params
		};
		sendResponse(m);
	}

	function handleThreadEvent(threadNumber:Int, event:Int, stackFrame:Int, className:String, functionName:String, fileName:String, lineNumber:Int) {
		// if (!started) return;

		switch (event) {
			case Debugger.THREAD_TERMINATED:
				stateMutex.acquire();
				threads.remove(threadNumber);
				if (currentThreadInfo != null && threadNumber == currentThreadInfo.number) {
					currentThreadInfo = null;
				}
				stateMutex.release();
				sendEvent(Protocol.ThreadExit, {threadId: threadNumber});

			case Debugger.THREAD_CREATED | Debugger.THREAD_STARTED:
				stateMutex.acquire();
				threads.set(threadNumber, 'Thread${threadNumber}');
				if (currentThreadInfo != null && threadNumber == currentThreadInfo.number) {
					currentThreadInfo = null;
				}
				stateMutex.release();
				sendEvent(Protocol.ThreadStart, {threadId: threadNumber});

			case Debugger.THREAD_STOPPED:
				stateMutex.acquire();
				currentThreadInfo = Debugger.getThreadInfo(threadNumber, false);
				references.clear();
				stateMutex.release();

				if (currentThreadInfo.status == cpp.vm.ThreadInfo.STATUS_STOPPED_BREAK_IMMEDIATE) {
					sendEvent(Protocol.PauseStop, {threadId: threadNumber});
				} else if (currentThreadInfo.status == cpp.vm.ThreadInfo.STATUS_STOPPED_BREAKPOINT) {
					var bId = currentThreadInfo.breakpoint;
					var path = file2path[path2Key(fileName)];
					var thisFileBreakpoints = breakpoints[path2Key(path)];
					for (b in thisFileBreakpoints) {
						if (b.id != bId)
							continue;

						interp = VariablesPrinter.initInterp(threadNumber, getTopFrame(), true);
						if (b.condition != null) {
							if (!isConditionPass(b.condition)) {
								Debugger.continueThreads(threadNumber, 1);
								return;
							}
						}
					}
					sendEvent(Protocol.BreakpointStop, {threadId: threadNumber});
				} else {
					sendEvent(Protocol.ExceptionStop, {text: currentThreadInfo.criticalErrorDescription});
				}
				// ThreadStopped(threadNumber, stackFrame, className,
				//                functionName, fileName, lineNumber));
		}
	}

	function isConditionPass(condition:Expr):Bool {
		try {
			var evalRes:Bool = interp.execute(condition);
			return evalRes;
		} catch (e:Dynamic) {}

		return false;
	}

	function getTopFrame():Int {
		// top of stack, minus cpp.vm.Debugger and jsonrpc.Server frames
		return (currentThreadInfo != null) ? currentThreadInfo.stack.length - 3 : -1;
	}

	function closeSocket() {
		if (socket != null) {
			socket.close();
			socket = null;
		}
	}

	function path2Key(path:String):String {
		return (isWindows) ? path.toUpperCase() : path;
	}

	public static function log(message:String) {
		trace(message);
	}
}
