import { Log } from '../util/log';
import { EventEmitter } from 'events';

let log = Log.create('DebugProtocolTransport');

/**
 * Implements the Remote Debugging Protocol Stream Transport as defined in
 * https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#stream-transport
 * Currently bulk data packets are unsupported and error handling is nonexistent
 */
export class DebugProtocolTransport extends EventEmitter {

	private static initialBufferLength = 11; // must be large enough to receive a complete header
	private buffer: Buffer;
	private bufferedLength: number;
	private receivingHeader: boolean;

	constructor(
		private socket: SocketLike
	) {
		super();

		this.buffer = Buffer.alloc(DebugProtocolTransport.initialBufferLength);
		this.bufferedLength = 0;
		this.receivingHeader = true;

		this.socket.on('data', (chunk: Buffer) => {

			let processedLength = 0;
			while (processedLength < chunk.length) {
				// copy the maximum number of bytes possible into this.buffer
				let copyLength = Math.min(chunk.length - processedLength, this.buffer.length - this.bufferedLength);
				chunk.copy(this.buffer, this.bufferedLength, processedLength, processedLength + copyLength);
				processedLength += copyLength;
				this.bufferedLength += copyLength;

				if (this.receivingHeader) {
					// did we receive a complete header yet?
					for (var i = 0; i < this.bufferedLength; i++) {
						if (this.buffer[i] === 58) {
							// header is complete: parse it
							let bodyLength = +this.buffer.toString('ascii', 0, i);
							if (bodyLength > 1000000) {
								log.debug(`Going to receive message with ${bodyLength} bytes in body (initial chunk contained ${chunk.length} bytes)`);
							}
							// create a buffer for the message body
							let bodyBuffer = Buffer.alloc(bodyLength);
							// copy the start of the body from this.buffer
							this.buffer.copy(bodyBuffer, 0, i + 1);
							// replace this.buffer with bodyBuffer
							this.buffer = bodyBuffer;
							this.bufferedLength = this.bufferedLength - (i + 1);
							this.receivingHeader = false;
							break;
						}
					}
				} else {
					// did we receive the complete body yet?
					if (this.bufferedLength === this.buffer.length) {
						if (this.bufferedLength > 1000000) {
							log.info(`Received ${this.bufferedLength} bytes`);
						}
						// body is complete: parse and emit it
						let msgString = this.buffer.toString('utf8');
						this.emit('message', JSON.parse(msgString));
						// get ready to receive the next header
						this.buffer = Buffer.alloc(DebugProtocolTransport.initialBufferLength);
						this.bufferedLength = 0;
						this.receivingHeader = true;
					}
				}
			}
		});
	}

	public sendMessage(msg: any): void {
		let msgBuf = Buffer.from(JSON.stringify(msg), 'utf8');
		this.socket.write(msgBuf.length + ':', 'ascii');
		this.socket.write(msgBuf);
	}
	
	public disconnect(): Promise<void> {
		return new Promise<void>((resolve, reject) => {
			this.socket.on('close', () => resolve());
			this.socket.end();
		});
	}
}

export interface SocketLike {
	on(event: string, listener: Function): EventEmitter;
	write(buffer: Buffer): boolean;
	write(str: string, encoding: string): boolean;
	end(): void;
}
