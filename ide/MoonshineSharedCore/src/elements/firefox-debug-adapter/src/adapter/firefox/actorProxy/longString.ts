import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { PendingRequests } from '../../util/pendingRequests';
import { ActorProxy } from './interface';

let log = Log.create('LongStringGripActorProxy');

/**
 * Proxy class for a long string grip actor
 * ([docs](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#long-strings),
 * [spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/string.js))
 */
export class LongStringGripActorProxy implements ActorProxy {

	private pendingSubstringRequests = new PendingRequests<string>();

	constructor(
		private grip: FirefoxDebugProtocol.LongStringGrip,
		private connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public get name() {
		return this.grip.actor;
	}

	public extendLifetime() {
		this.connection.sendRequest({ to: this.name, type: 'threadGrip' });
	}

	public fetchContent(): Promise<string> {

		log.debug(`Fetching content from long string ${this.name}`);

		return new Promise<string>((resolve, reject) => {
			this.pendingSubstringRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'substring', start: 0, end: this.grip.length });
		});
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['substring'] !== undefined) {

			log.debug(`Content fetched from ${this.name}`);
			this.pendingSubstringRequests.resolveOne(response['substring']);

		} else if (response['error'] === 'noSuchActor') {

			log.warn(`No such actor ${this.grip.actor} - you will not be able to inspect this value; this is probably due to Firefox bug #1249962`);
			this.pendingSubstringRequests.rejectAll('No such actor');

		} else if (Object.keys(response).length === 1) {

			log.debug('Received response to threadGrip or release request');

		} else {

			log.warn("Unknown message from LongStringActor: " + JSON.stringify(response));

		}
	}
}
