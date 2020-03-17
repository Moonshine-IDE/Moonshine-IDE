import js.node.stream.Readable.ReadableEvent;
import js.node.net.Socket;
import js.node.Buffer;
import hxcpp.debug.jsonrpc.Protocol;

typedef RequestCallback<T> = Null<Error>->Null<T>->Void;

class Connection {
	var socket:Socket;
	var buffer:Buffer;
	var index:Int;
	var nextMessageLength:Int;
	var callbacks:Map<Int, RequestCallback<Dynamic>>;

	static inline var DEFAULT_BUFFER_SIZE = 4096;

	public function new(socket) {
		this.socket = socket;
		buffer = new Buffer(DEFAULT_BUFFER_SIZE);
		index = 0;
		nextMessageLength = -1;
		callbacks = new Map();
		socket.on(ReadableEvent.Data, onData);
	}

	function append(data:Buffer) {
		// append received data to the buffer, increasing it if needed
		if (buffer.length - index >= data.length) {
			data.copy(buffer, index, 0, data.length);
		} else {
			var newSize = (Math.ceil((index + data.length) / DEFAULT_BUFFER_SIZE) + 1) * DEFAULT_BUFFER_SIZE; // copied from the language-server protocol reader
			if (index == 0) {
				buffer = new Buffer(newSize);
				data.copy(buffer, 0, 0, data.length);
			} else {
				buffer = Buffer.concat([buffer.slice(0, index), data], newSize);
			}
		}
		index += data.length;
	}

	function onData(data:Buffer) {
		append(data);
		while (true) {
			if (nextMessageLength == -1) {
				if (index < 4)
					return; // not enough data
				nextMessageLength = buffer.readInt32LE(0);
				index -= 4;
				buffer.copy(buffer, 0, 4);
			}
			if (index < nextMessageLength)
				return;
			var bytes = buffer.toString("utf-8", 0, nextMessageLength);
			buffer.copy(buffer, 0, nextMessageLength);
			index -= nextMessageLength;
			nextMessageLength = -1;
			var json = haxe.Json.parse(bytes);
			onMessage(json);
		}
	}

	public dynamic function onEvent<P>(type:NotificationMethod<P>, data:P) {}

	function onMessage<T>(msg:Message) {
		// trace('GOT MESSAGE ${haxe.Json.stringify(msg)}');
		if (msg.id == null) {
			onEvent(new NotificationMethod(msg.method), msg.params);
		} else {
			var callback = callbacks[msg.id];
			if (callback != null) {
				callbacks.remove(msg.id);
				callback(msg.error, msg.result);
			}
		}
	}

	var nextRequestId = 1;

	public function sendCommand<P, R>(name:RequestMethod<P, R>, params:P, ?callback:RequestCallback<R>) {
		var requestId = nextRequestId++;
		var cmd = haxe.Json.stringify({
			id: requestId,
			method: name,
			params: params
		});
		// trace('Sending command: $cmd');
		var body = Buffer.from(cmd, "utf-8");
		var header = Buffer.alloc(4);
		if (callback != null)
			callbacks[requestId] = callback;

		header.writeInt32LE(body.length, 0);
		socket.write(header);
		socket.write(body);
	}
}
