import { Log } from '../../util/log';
import { DebugConnection } from '../connection';
import { PendingRequests, PendingRequest } from '../../util/pendingRequests';
import { ActorProxy } from './interface';
import { MappedLocation, Range } from '../../location';

let log = Log.create('SourceActorProxy');

export interface ISourceActorProxy {
	name: string;
	source: FirefoxDebugProtocol.Source;
	url: string | null;
	getBreakableLines(): Promise<number[]>;
	getBreakableLocations(line: number): Promise<MappedLocation[]>;
	fetchSource(): Promise<FirefoxDebugProtocol.Grip>;
	setBlackbox(blackbox: boolean): Promise<void>;
	dispose(): void;
}

/**
 * Proxy class for a source actor
 * ([docs](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#loading-script-sources),
 * [spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/source.js))
 */
export class SourceActorProxy implements ActorProxy, ISourceActorProxy {

	private pendingGetBreakableLinesRequest?: PendingRequest<number[]>;
	private getBreakableLinesPromise?: Promise<number[]>;
	private pendingGetBreakpointPositionsRequests = new PendingRequests<FirefoxDebugProtocol.BreakpointPositions>();
	private pendingFetchSourceRequests = new PendingRequests<FirefoxDebugProtocol.Grip>();
	private pendingBlackboxRequests = new PendingRequests<void>();
	
	constructor(
		public readonly source: FirefoxDebugProtocol.Source,
		private connection: DebugConnection
	) {
		this.connection.register(this);
	}

	public get name() {
		return this.source.actor;
	}

	public get url() {
		return this.source.url;
	}

	public getBreakableLines(): Promise<number[]> {

		if (!this.getBreakableLinesPromise) {

			log.debug(`Fetching breakableLines of ${this.url}`);

			this.getBreakableLinesPromise = new Promise<number[]>((resolve, reject) => {
				this.pendingGetBreakableLinesRequest = { resolve, reject };
				this.connection.sendRequest({ to: this.name, type: 'getBreakableLines' });
			});
		}

		return this.getBreakableLinesPromise;
	}

	public async getBreakableLocations(line: number): Promise<MappedLocation[]> {

		log.debug(`Fetching breakpointPositions of ${this.url}`);

		const positions = await this.getBreakpointPositionsForRange({
			start: { line, column: 0 },
			end: { line, column: Number.MAX_SAFE_INTEGER }
		});

		if (positions[line]) {
			return (positions[line].map(column => ({ line, column })));
		} else {
			return [];
		}
	}

	public getBreakpointPositionsForRange(range: Range): Promise<FirefoxDebugProtocol.BreakpointPositions> {

		log.debug(`Fetching breakpoint positions of ${this.url} for range: ${JSON.stringify(range)}`);

		return new Promise<FirefoxDebugProtocol.BreakpointPositions>((resolve, reject) => {
			this.pendingGetBreakpointPositionsRequests.enqueue({ resolve, reject });

			const request: any = { to: this.name, type: 'getBreakpointPositionsCompressed' };
			if (range) {
				request.query = {
					start: { line: range.start.line, column: range.start.column },
					end: { line: range.end.line, column: range.end.column },
				};
			}

			this.connection.sendRequest(request);
		});
	}

	public fetchSource(): Promise<FirefoxDebugProtocol.Grip> {

		log.debug(`Fetching source of ${this.url}`);

		return new Promise<FirefoxDebugProtocol.Grip>((resolve, reject) => {
			this.pendingFetchSourceRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'source' });
		});
	}

	public setBlackbox(blackbox: boolean): Promise<void> {

		log.debug(`Setting blackboxing of ${this.url} to ${blackbox}`);

		this.source.isBlackBoxed = blackbox;

		return new Promise<void>((resolve, reject) => {
			let type = blackbox ? 'blackbox' : 'unblackbox';
			this.pendingBlackboxRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type });
		});
	}

	public dispose(): void {
		this.connection.unregister(this);
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['lines'] !== undefined) {

			log.debug('Received getBreakableLines response');

			let breakableLinesResponse = <FirefoxDebugProtocol.GetBreakableLinesResponse>response;
			if (this.pendingGetBreakableLinesRequest) {
				this.pendingGetBreakableLinesRequest.resolve(breakableLinesResponse.lines);
				this.pendingGetBreakableLinesRequest = undefined;
			} else {
				log.warn(`Got BreakableLines for ${this.url} without a corresponding request`);
			}

		} else if (response['positions'] !== undefined) {

			log.debug('Received getBreakpointPositions response');

			let breakpointPositionsResponse = <FirefoxDebugProtocol.GetBreakpointPositionsCompressedResponse>response;
			this.pendingGetBreakpointPositionsRequests.resolveOne(breakpointPositionsResponse.positions);

		} else if (response['source'] !== undefined) {

			log.debug('Received fetchSource response');
			let grip = <FirefoxDebugProtocol.Grip>response['source'];
			this.pendingFetchSourceRequests.resolveOne(grip);

		} else if (response['error'] === 'noSuchActor') {

			log.error(`No such actor ${JSON.stringify(this.name)}`);
			this.pendingFetchSourceRequests.rejectAll('No such actor');

		} else {

			let propertyCount = Object.keys(response).length;
			if ((propertyCount === 1) || ((propertyCount === 2) && (response['pausedInSource'] !== undefined))) {

				log.debug('Received (un)blackbox response');
				this.pendingBlackboxRequests.resolveOne(undefined);

			} else {

				log.warn("Unknown message from SourceActor: " + JSON.stringify(response));

			}
		}
	}
}
