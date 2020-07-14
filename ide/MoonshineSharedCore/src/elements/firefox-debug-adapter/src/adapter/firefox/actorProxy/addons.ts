import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { ActorProxy } from './interface';
import { PendingRequests } from '../../util/pendingRequests';

let log = Log.create('AddonsActorProxy');

/**
 * Proxy class for an addons actor
 * ([spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/addon/addons.js))
 */
export class AddonsActorProxy implements ActorProxy {

	private pendingInstallRequests = new PendingRequests<FirefoxDebugProtocol.InstallAddonResponse>();

	constructor(
		public readonly name: string,
		private connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public installAddon(addonPath: string): Promise<FirefoxDebugProtocol.InstallAddonResponse> {

		log.debug(`Installing addon from ${addonPath}`);

		return new Promise<FirefoxDebugProtocol.InstallAddonResponse>((resolve, reject) => {
			this.pendingInstallRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ 
				to: this.name,
				type: 'installTemporaryAddon',
				addonPath
			});
		});
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['addon']) {

			let installAddonResponse = <FirefoxDebugProtocol.InstallAddonResponse>response;
			this.pendingInstallRequests.resolveOne(installAddonResponse);

		} else if (response['error']) {

			log.warn("Error from AddonsActor: " + JSON.stringify(response));
			this.pendingInstallRequests.rejectOne(response['message'] || response['error']);

		} else {

			log.warn("Unknown message from AddonsActor: " + JSON.stringify(response));

		}
	}
}