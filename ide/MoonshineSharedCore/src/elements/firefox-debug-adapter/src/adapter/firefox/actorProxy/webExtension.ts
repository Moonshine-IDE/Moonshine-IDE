import { Log } from '../../util/log';
import { EventEmitter } from 'events';
import { PendingRequests } from '../../util/pendingRequests';
import { PathMapper } from '../../util/pathMapper';
import { ActorProxy } from './interface';
import { TabActorProxy } from './tab';
import { ConsoleActorProxy } from './console';
import { DebugConnection } from '../connection';

let log = Log.create('WebExtensionActorProxy');

/**
 * Proxy class for a WebExtension actor
 * ([spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/addon/webextension.js))
 */
export class WebExtensionActorProxy extends EventEmitter implements ActorProxy {

	private pendingConnectRequests = new PendingRequests<[TabActorProxy, ConsoleActorProxy]>();

	constructor(
		private readonly webExtensionInfo: FirefoxDebugProtocol.Addon,
		private readonly pathMapper: PathMapper,
		private readonly connection: DebugConnection
	) {
		super();
		this.connection.register(this);
	}

	public get name() {
		return this.webExtensionInfo.actor;
	}

	public connect(): Promise<[TabActorProxy, ConsoleActorProxy]> {

		log.debug('Connecting using connect request');

		return new Promise<[TabActorProxy, ConsoleActorProxy]>((resolve, reject) => {
			this.pendingConnectRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'connect' });
		})
	}

	public getTarget(): Promise<[TabActorProxy, ConsoleActorProxy]> {

		log.debug('Connecting using getTarget request');

		return new Promise<[TabActorProxy, ConsoleActorProxy]>((resolve, reject) => {
			this.pendingConnectRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'getTarget' });
		})
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['form']) {

			let connectResponse = <FirefoxDebugProtocol.ProcessResponse>response;
			log.debug('Received connect response');
			this.pendingConnectRequests.resolveOne([
				new TabActorProxy(
					connectResponse.form.actor, this.webExtensionInfo.name, connectResponse.form.url,
					this.pathMapper, this.connection),
				new ConsoleActorProxy(connectResponse.form.consoleActor, this.connection)
			]);

		} else if (response['error']) {

			let msg = response['message'];
			log.warn(`Error message from WebExtensionActor: ${msg}`);

			if (msg && msg.startsWith('Extension not found')) {
				setTimeout(() => {
					this.connection.sendRequest({ to: this.name, type: 'connect' });
				}, 100);
			}
			
		} else {

			log.warn("Unknown message from WebExtensionActor: " + JSON.stringify(response));

		}
	}
}
