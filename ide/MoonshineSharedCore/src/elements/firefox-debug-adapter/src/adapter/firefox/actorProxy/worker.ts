import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { IThreadActorProxy, ThreadActorProxy } from './thread';
import { ConsoleActorProxy } from './console';
import { SourceMappingThreadActorProxy } from '../sourceMaps/thread';
import { PathMapper } from '../../util/pathMapper';
import { BaseActorProxy } from './base';

let log = Log.create('WorkerActorProxy');

export class WorkerActorProxy extends BaseActorProxy {

	private attachPromise?: Promise<string>;
	private connectPromise?: Promise<[IThreadActorProxy, ConsoleActorProxy]>;

	constructor(
		name: string,
		public readonly url: string,
		private readonly enableCRAWorkaround: boolean,
		private readonly pathMapper: PathMapper,
		connection: DebugConnection
	) {
		super(name, ['attached', 'connected'], connection);
	}

	public attach(): Promise<string> {
		if (!this.attachPromise) {
			log.debug(`Attaching worker ${this.name}`);

			this.attachPromise = this.sendRequest<any, FirefoxDebugProtocol.WorkerAttachedResponse>(
				{ type: 'attach' }
			).then(response => response.url);
			
		} else {
			log.warn('Attaching this worker has already been requested!');
		}
		
		return this.attachPromise;
	}

	public connect(): Promise<[IThreadActorProxy, ConsoleActorProxy]> {
		if (!this.connectPromise) {
			log.debug(`Attaching worker ${this.name}`);
			this.connectPromise = this._connect();
		} else {
			log.warn('Connecting this worker has already been requested!');
		}
		
		return this.connectPromise;
	}

	private async _connect(): Promise<[IThreadActorProxy, ConsoleActorProxy]> {

		const requestTypes = await this.getRequestTypes();
		const type = requestTypes.includes('getTarget') ? 'getTarget' : 'connect';
		const response: FirefoxDebugProtocol.WorkerConnectedResponse = await this.sendRequest(
			{ type, options: { useSourceMaps: true } }
		);

		let threadActor: IThreadActorProxy = this.connection.getOrCreate(
			response.threadActor, 
			() => new ThreadActorProxy(response.threadActor, this.enableCRAWorkaround, this.connection));

		threadActor = new SourceMappingThreadActorProxy(threadActor, this.pathMapper, this.connection);

		let consoleActor = this.connection.getOrCreate(
			response.consoleActor,
			() => new ConsoleActorProxy(response.consoleActor, this.connection));

		return [threadActor, consoleActor];
	}

	handleEvent(event: FirefoxDebugProtocol.Event): void {
		if (event.type === 'close') {
			log.debug(`Worker ${this.name} closed`);
			this.emit('close');
		} else if (event.type === 'newSource') {
			log.debug(`Ignored newSource event from worker ${this.name}`);
		} else {
			log.warn("Unknown message from WorkerActor: " + JSON.stringify(event));
		}
	}

	public onClose(cb: () => void) {
		this.on('close', cb);
	}
}
