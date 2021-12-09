import { Log } from '../../util/log';
import { EventEmitter } from 'events';
import { DebugConnection } from '../connection';
import { PendingRequests, PendingRequest } from '../../util/pendingRequests';
import { ActorProxy } from './interface';
import { exceptionGripToString } from '../../util/misc';

let log = Log.create('ConsoleActorProxy');

/**
 * Proxy class for a console actor
 */
export class ConsoleActorProxy extends EventEmitter implements ActorProxy {

	private static listenFor = [ 'PageError', 'ConsoleAPI' ];

	private pendingStartListenersRequests = new PendingRequests<void>();
	private pendingStopListenersRequests = new PendingRequests<void>();
	private pendingResultIDRequests = new PendingRequests<number>();
	private pendingEvaluateRequests = new Map<number, PendingRequest<FirefoxDebugProtocol.Grip>>();
	private pendingAutoCompleteRequests = new PendingRequests<string[]>();

	constructor(
		public readonly name: string,
		private connection: DebugConnection
	) {
		super();
		this.connection.register(this);
	}

	public startListeners(): Promise<void> {
		log.debug('Starting console listeners');

		return new Promise<void>((resolve, reject) => {
			this.pendingStartListenersRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({
				to: this.name, type: 'startListeners',
				listeners: ConsoleActorProxy.listenFor
			});
		});
	}

	public stopListeners(): Promise<void> {
		log.debug('Stopping console listeners');

		return new Promise<void>((resolve, reject) => {
			this.pendingStopListenersRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({
				to: this.name, type: 'stopListeners',
				listeners: ConsoleActorProxy.listenFor
			});
		});
	}

	public getCachedMessages(): void {
		log.debug('Getting cached messages');

		this.connection.sendRequest({
			to: this.name, type: 'getCachedMessages',
			messageTypes: ConsoleActorProxy.listenFor
		});
	}

	/**
	 * Evaluate the given expression. This will create 2 PendingRequest objects because we expect
	 * 2 answers: the first answer gives us a resultID for the evaluation result. The second answer
	 * gives us the actual evaluation result.
	 */
	public evaluate(expr: string, frameActorName?: string): Promise<FirefoxDebugProtocol.Grip> {
		log.debug(`Evaluating '${expr}' on console ${this.name}`);

		return new Promise<FirefoxDebugProtocol.Grip>((resolveEvaluate, rejectEvaluate) => {

			// we don't use a promise for the pendingResultIDRequest because we need the
			// pendingEvaluateRequest to be enqueued *immediately* after receiving the resultID
			// message (and a promise doesn't call its callbacks immediately after being resolved,
			// but rather schedules them to be called later)
			this.pendingResultIDRequests.enqueue({
				resolve: (resultID) => {
					this.pendingEvaluateRequests.set(resultID, { 
						resolve: resolveEvaluate, reject: rejectEvaluate
					});
				},
				reject: () => {}
			});

			this.connection.sendRequest({
				to: this.name, type: 'evaluateJSAsync',
				text: expr, frameActor: frameActorName
			});
		})
	}

	public autoComplete(text: string, column: number, frameActor?: string) {
		log.debug(`Getting completions for ${text} at position ${column}`);

		return new Promise<string[]>((resolve, reject) => {
			this.pendingAutoCompleteRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({
				to: this.name, type: 'autocomplete', text, cursor: column, frameActor
			})
		})
	}

	public dispose(): void {
		this.connection.unregister(this);
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['startedListeners']) {

			log.debug('Listeners started');
			this.pendingStartListenersRequests.resolveOne(undefined);

		} else if (response['stoppedListeners']) {

			log.debug('Listeners stopped');
			this.pendingStartListenersRequests.resolveOne(undefined);

		} else if (response['messages']) {

			log.debug('Received cached messages');
			for (let message of response.messages) {
				if ((message as FirefoxDebugProtocol.CachedMessage).type === 'consoleAPICall') {
					this.emit('consoleAPI', message.message);
				} else if ((message as FirefoxDebugProtocol.CachedMessage).type === 'pageError') {
					this.emit('pageError', message.pageError);
				} else if ((message as FirefoxDebugProtocol.LegacyCachedMessage)._type === 'ConsoleAPI') {
					this.emit('consoleAPI', message);
				} else if ((message as FirefoxDebugProtocol.LegacyCachedMessage)._type === 'PageError') {
					this.emit('pageError', message);
				}
			}

		} else if (response['type'] === 'consoleAPICall') {

			log.debug(`Received ConsoleAPI message`);
			this.emit('consoleAPI', (<FirefoxDebugProtocol.ConsoleAPICallResponse>response).message);

		} else if (response['type'] === 'pageError') {

			log.debug(`Received PageError message`);
			this.emit('pageError', (<FirefoxDebugProtocol.PageErrorResponse>response).pageError);

		} else if (response['type'] === 'logMessage') {

			log.debug(`Received LogMessage message`);
			this.emit('logMessage', (<FirefoxDebugProtocol.LogMessageResponse>response).message);

		} else if (response['type'] === 'evaluationResult') {

			log.debug(`Received EvaluationResult message`);
			let resultResponse = <FirefoxDebugProtocol.EvaluationResultResponse>response;
			if (!this.pendingEvaluateRequests.has(resultResponse.resultID)) {
				log.error('Received evaluationResult with unknown resultID');
			} else {
				let evaluateRequest = this.pendingEvaluateRequests.get(resultResponse.resultID)!;
				if (resultResponse.exceptionMessage === undefined) {
					evaluateRequest.resolve(resultResponse.result);
				} else {
					evaluateRequest.reject(exceptionGripToString(resultResponse.exception));
				}
			}

		} else if (response['resultID']) {

			log.debug(`Received ResultID message`);
			this.pendingResultIDRequests.resolveOne(response['resultID']);

		} else if (response['matches'] !== undefined) {

			log.debug(`Received autoComplete response`);
			this.pendingAutoCompleteRequests.resolveOne(
				(<FirefoxDebugProtocol.AutoCompleteResponse>response).matches);

		} else {

			log.warn("Unknown message from ConsoleActor: " + JSON.stringify(response));

		}
	}

	public onConsoleAPICall(cb: (body: FirefoxDebugProtocol.ConsoleAPICallResponseBody) => void) {
		this.on('consoleAPI', cb);
	}

	public onPageErrorCall(cb: (body: FirefoxDebugProtocol.PageErrorResponseBody) => void) {
		this.on('pageError', cb);
	}

	public onLogMessageCall(cb: (message: string) => void) {
		this.on('logMessage', cb);
	}
}
