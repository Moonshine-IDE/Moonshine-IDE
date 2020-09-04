import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { PendingRequest } from '../../util/pendingRequests';
import { ActorProxy } from './interface';

let log = Log.create('DeviceActorProxy');

/**
 * Proxy class for the device actor
 */
export class DeviceActorProxy implements ActorProxy {

	private pendingDescriptionRequest?: PendingRequest<FirefoxDebugProtocol.DeviceDescription>;
	private descriptionPromise?: Promise<FirefoxDebugProtocol.DeviceDescription>;

	constructor(
		public readonly name: string,
		private connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public getDescription(): Promise<FirefoxDebugProtocol.DeviceDescription> {
		if (!this.descriptionPromise) {

			log.debug('Getting device description');

			this.descriptionPromise =new Promise<FirefoxDebugProtocol.DeviceDescription>((resolve, reject) => {
				this.pendingDescriptionRequest = { resolve, reject };
				this.connection.sendRequest({ to: this.name, type: 'getDescription' });
			});
		}

		return this.descriptionPromise;
	}

	public dispose(): void {
		this.connection.unregister(this);
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['value']) {

			log.debug('Device description received');

			if (this.pendingDescriptionRequest) {

				this.pendingDescriptionRequest.resolve(response['value']);
				this.pendingDescriptionRequest = undefined;

			} else {
				log.warn('Received getDescription response without a corresponding request');
			}

		} else {

			log.warn("Unknown message from DeviceActor: " + JSON.stringify(response));

		}
	}
}
