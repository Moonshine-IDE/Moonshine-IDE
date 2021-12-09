import { Log } from '../../util/log';
import { PendingRequest } from '../../util/pendingRequests';
import { PathMapper } from '../../util/pathMapper';
import { ActorProxy } from './interface';
import { TabActorProxy } from './tab';
import { ConsoleActorProxy } from './console';
import { DebugConnection } from '../connection';

let log = Log.create('TabDescriptorActorProxy');

/**
 * Proxy class for a TabDescriptor actor
 */
export class TabDescriptorActorProxy implements ActorProxy {

	private pendingGetTargetRequest?:PendingRequest<[TabActorProxy, ConsoleActorProxy]>;
	private getTargetPromise?: Promise<[TabActorProxy, ConsoleActorProxy]>;

	constructor(
		public readonly name: string,
		private readonly enableCRAWorkaround: boolean,
		private readonly pathMapper: PathMapper,
		private readonly connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public getTarget(): Promise<[TabActorProxy, ConsoleActorProxy]> {

		if (!this.getTargetPromise) {

			log.debug('Connecting to tab');

			this.getTargetPromise = new Promise<[TabActorProxy, ConsoleActorProxy]>((resolve, reject) => {
				this.pendingGetTargetRequest = { resolve, reject };
				this.connection.sendRequest({ to: this.name, type: 'getTarget' });
			});
		}

		return this.getTargetPromise;
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['frame']) {

			log.debug('Received getTarget response');

			if (this.pendingGetTargetRequest) {

				const getTargetResponse = <FirefoxDebugProtocol.TabDescriptorTargetResponse>response;

				this.pendingGetTargetRequest.resolve([
					new TabActorProxy(
						getTargetResponse.frame.actor, getTargetResponse.frame.title, getTargetResponse.frame.url,
						this.enableCRAWorkaround, this.pathMapper, this.connection),
					new ConsoleActorProxy(getTargetResponse.frame.consoleActor, this.connection)
				]);

			} else {
				log.warn(`Got target for ${this.name} without a corresponding request`);
			}

		} else if (response['error']) {

			let msg = response['message'];
			log.warn(`Error message from TabDescriptorActor: ${msg}`);

		} else {

			log.warn("Unknown message from TabDescriptorActor: " + JSON.stringify(response));

		}
	}
}
