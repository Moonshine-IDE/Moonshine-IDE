import { Log } from '../util/log';
import { Socket } from 'net';
import { DebugProtocolTransport } from './transport';
import { ActorProxy } from './actorProxy/interface';
import { RootActorProxy } from './actorProxy/root';
import { PathMapper } from '../util/pathMapper';

let log = Log.create('DebugConnection');

/**
 * Connects to a target supporting the Firefox Debugging Protocol and sends and receives messages
 */
export class DebugConnection {

	private transport: DebugProtocolTransport;
	private actors: Map<string, ActorProxy>;
	public readonly rootActor: RootActorProxy;

	constructor(
		enableCRAWorkaround: boolean,
		pathMapper: PathMapper,
		socket: Socket
	) {

		this.actors = new Map<string, ActorProxy>();
		this.rootActor = new RootActorProxy(enableCRAWorkaround, pathMapper, this);
		this.transport = new DebugProtocolTransport(socket);

		this.transport.on('message', (response: FirefoxDebugProtocol.Response) => {
			if (this.actors.has(response.from)) {
				if (log.isDebugEnabled()) {
					log.debug(`Received response/event ${JSON.stringify(response)}`);
				}
				this.actors.get(response.from)!.receiveResponse(response);
			} else {
				log.error('Unknown actor: ' + JSON.stringify(response));
			}
		});
	}

	public sendRequest<T extends FirefoxDebugProtocol.Request>(request: T) {
		if (log.isDebugEnabled()) {
			log.debug(`Sending request ${JSON.stringify(request)}`);
		}
		this.transport.sendMessage(request);
	}

	public register(actor: ActorProxy): void {
		this.actors.set(actor.name, actor);
	}

	public unregister(actor: ActorProxy): void {
		this.actors.delete(actor.name);
	}

	public has(actorName: string): boolean {
		return this.actors.has(actorName);
	}

	public getOrCreate<T extends ActorProxy>(actorName: string, createActor: () => T): T {
		if (this.actors.has(actorName)) {
			return <T>this.actors.get(actorName);
		} else {
			return createActor();
		}
	}
	
	public disconnect(): Promise<void> {
		return this.transport.disconnect();
	}
}
