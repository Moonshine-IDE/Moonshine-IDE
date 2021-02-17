import { Log } from '../../util/log';
import { EventEmitter } from 'events';
import { DebugConnection } from '../connection';
import { ActorProxy } from './interface';
import { IThreadActorProxy, ThreadActorProxy } from './thread';
import { ConsoleActorProxy } from './console';
import { SourceMappingThreadActorProxy } from '../sourceMaps/thread';
import { PendingRequest } from '../../util/pendingRequests';
import { PathMapper } from '../../util/pathMapper';

let log = Log.create('WorkerActorProxy');

/**
 * Proxy class for a WebWorker actor
 */
export class WorkerActorProxy extends EventEmitter implements ActorProxy {

	constructor(
		public readonly name: string,
		public readonly url: string,
		private readonly enableCRAWorkaround: boolean,
		private readonly pathMapper: PathMapper,
		private readonly connection: DebugConnection
	) {
		super();
		this.connection.register(this);
	}

	private pendingAttachRequest?: PendingRequest<string>;
	private attachPromise?: Promise<string>;
	private pendingConnectRequest?: PendingRequest<[IThreadActorProxy, ConsoleActorProxy]>;
	private connectPromise?: Promise<[IThreadActorProxy, ConsoleActorProxy]>;

	public attach(): Promise<string> {
		if (!this.attachPromise) {
			log.debug(`Attaching worker ${this.name}`);

			this.attachPromise = new Promise<string>((resolve, reject) => {
				this.pendingAttachRequest = { resolve, reject };
				this.connection.sendRequest({ to: this.name, type: 'attach' });
			});
			
		} else {
			log.warn('Attaching this worker has already been requested!');
		}
		
		return this.attachPromise;
	}

	public connect(): Promise<[IThreadActorProxy, ConsoleActorProxy]> {
		if (!this.connectPromise) {
			log.debug(`Attaching worker ${this.name}`);

			this.connectPromise = new Promise<[IThreadActorProxy, ConsoleActorProxy]>(
				(resolve, reject) => {
					this.pendingConnectRequest = { resolve, reject };
					this.connection.sendRequest({ 
						to: this.name, type: 'connect',
						options: { useSourceMaps: true }
					});
				}
			);
			
		} else {
			log.warn('Connecting this worker has already been requested!');
		}
		
		return this.connectPromise;
	}

	public dispose(): void {
		this.connection.unregister(this);
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['type'] === 'attached') {

			log.debug(`Worker ${this.name} attached`);

			let attachedResponse = <FirefoxDebugProtocol.WorkerAttachedResponse>response;
			if (this.pendingAttachRequest) {
				this.pendingAttachRequest.resolve(attachedResponse.url);
				this.pendingAttachRequest = undefined;
			} else {
				log.warn(`Worker ${this.name} attached without a corresponding request`);
			}

		} else if (response['type'] === 'connected') {

			log.debug(`Worker ${this.name} attached`);

			let connectedResponse = <FirefoxDebugProtocol.WorkerConnectedResponse>response;
			if (this.pendingConnectRequest) {

				let threadActor: IThreadActorProxy = this.connection.getOrCreate(
					connectedResponse.threadActor, 
					() => new ThreadActorProxy(connectedResponse.threadActor, this.enableCRAWorkaround, this.connection));

				threadActor = new SourceMappingThreadActorProxy(threadActor, this.pathMapper, this.connection);

				let consoleActor = this.connection.getOrCreate(
					connectedResponse.consoleActor,
					() => new ConsoleActorProxy(connectedResponse.consoleActor, this.connection));

				this.pendingConnectRequest.resolve([threadActor, consoleActor]);
				this.pendingConnectRequest = undefined;

			} else {
				log.warn(`Worker ${this.name} connected without a corresponding request`);
			}

		} else if (response['type'] === 'close') {

			log.debug(`Worker ${this.name} closed`);
			this.emit('close');

		} else {

			if (response['type'] === 'newSource') {
				log.debug(`Ignored newSource event from worker ${this.name}`);
			} else {
				log.warn("Unknown message from WorkerActor: " + JSON.stringify(response));
			}

		}
	}

	public onClose(cb: () => void) {
		this.on('close', cb);
	}
}