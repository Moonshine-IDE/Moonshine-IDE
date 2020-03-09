/**
 * An ActorProxy is a client-side reference to an actor on the server side of the 
 * Mozilla Debugging Protocol as defined in
 * https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md
 */
export interface ActorProxy {

	/** the name that is used for the actor in Firefox debug protocol messages */
	readonly name: string;

	/** called by the [DebugConnection](../connection.ts) class to deliver this actor's messages */
	receiveResponse(response: FirefoxDebugProtocol.Response): void;
}
