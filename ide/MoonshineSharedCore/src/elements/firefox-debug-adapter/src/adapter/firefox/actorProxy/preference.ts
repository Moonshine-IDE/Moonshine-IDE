import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { ActorProxy } from './interface';
import { PendingRequests } from '../../util/pendingRequests';

let log = Log.create('PreferenceActorProxy');

/**
 * Proxy class for a preference actor
 * ([spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/preference.js))
 */
export class PreferenceActorProxy implements ActorProxy {

	private pendingGetPrefRequests = new PendingRequests<string>();
	private pendingSetPrefRequests = new PendingRequests<void>();

	constructor(
		public readonly name: string,
		private connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public async getBoolPref(pref: string): Promise<boolean> {

		let prefString = await this.getPref(pref, 'Bool');
		return (prefString === 'true');

	}

	public getCharPref(pref: string): Promise<string> {

		return this.getPref(pref, 'Char');

	}

	public async getIntPref(pref: string): Promise<number> {

		let prefString = await this.getPref(pref, 'Bool');
		return parseInt(prefString, 10);

	}

	public setBoolPref(pref: string, val: boolean): Promise<void> {

		return this.setPref(pref, val, 'Bool');

	}

	public setCharPref(pref: string, val: string): Promise<void> {

		return this.setPref(pref, val, 'Char');

	}

	public setIntPref(pref: string, val: number): Promise<void> {

		return this.setPref(pref, val, 'Int');

	}

	private getPref(
		pref: string,
		type: 'Bool' | 'Char' | 'Int'
	): Promise<string> {

		log.debug(`Getting preference value for ${pref}`);

		return new Promise<string>((resolve, reject) => {
			this.pendingGetPrefRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ 
				to: this.name,
				type: `get${type}Pref`,
				value: pref
			});
		});
	}

	private setPref(
		pref: string,
		val: boolean | string | number,
		type: 'Bool' | 'Char' | 'Int'
	): Promise<void> {

		log.debug(`Setting preference value for ${pref} to ${val}`);

		return new Promise<void>((resolve, reject) => {
			this.pendingSetPrefRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ 
				to: this.name,
				type: `set${type}Pref`,
				name: pref,
				value: val
			});
		});
	}

	receiveResponse(response: any): void {

		if (response['value'] !== undefined) {

			this.pendingGetPrefRequests.resolveOne(response['value'].toString());

		} else if (Object.keys(response).length === 1) {

			this.pendingSetPrefRequests.resolveOne(undefined);

		} else if (response['error']) {

			log.warn("Error from PreferenceActor: " + JSON.stringify(response));
			this.pendingGetPrefRequests.rejectOne(response['message'] || response['error']);

		} else {

			log.warn("Unknown message from PreferenceActor: " + JSON.stringify(response));

		}
	}
}