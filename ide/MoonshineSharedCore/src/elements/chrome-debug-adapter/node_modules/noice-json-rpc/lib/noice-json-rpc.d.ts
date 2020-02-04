/// <reference types="node" />
import { JsonRpc2 } from './json-rpc2';
import { EventEmitter } from 'events';
export { JsonRpc2 };
export interface LikeSocket {
    send(message: string): void;
    on(event: string, cb: Function): any;
    removeListener(event: string, cb: Function): any;
}
export interface LikeSocketServer {
    on(event: string, cb: Function): any;
    clients?: Iterable<LikeSocket>;
}
export interface LogOpts {
    /** All messages will be emmitted and can be handled by client.on('receive', (msg: string) => void) and client.on('send', (msg: string) => any)  */
    logEmit?: boolean;
    /** All messages will be logged to console */
    logConsole?: boolean;
}
export interface ClientOpts extends LogOpts {
}
export interface ServerOpts extends LogOpts {
}
export declare class MessageError extends Error implements JsonRpc2.Error {
    private _code;
    private _data?;
    constructor(error: JsonRpc2.Error);
    readonly code: JsonRpc2.ErrorCode;
    readonly data: any;
}
/**
 * Creates a RPC Client.
 * It is intentional that Client does not create a WebSocket object since we prefer composability
 * The Client can be used to communicate over processes, http or anything that can send and receive strings
 * It just needs to pass in an object that implements LikeSocket interface
 */
export declare class Client extends EventEmitter implements JsonRpc2.Client {
    private _socket;
    private _responsePromiseMap;
    private _nextMessageId;
    private _connected;
    private _emitLog;
    private _consoleLog;
    private _requestQueue;
    constructor(socket: LikeSocket, opts?: ClientOpts);
    processMessage(messageStr: string): boolean;
    /** Set logging for all received and sent messages */
    setLogging({logEmit, logConsole}?: LogOpts): void;
    private _send(message);
    private _sendQueuedRequests();
    private _logMessage(message, direction);
    call(method: string, params?: any): Promise<any>;
    notify(method: string, params?: any): void;
    /**
     * Builds an ES6 Proxy where api.domain.method(params) transates into client.send('{domain}.{method}', params) calls
     * api.domain.on{method} will add event handlers for {method} events
     * api.domain.emit{method} will send {method} notifications to the server
     * The api object leads itself to a very clean interface i.e `await api.Domain.func(params)` calls
     * This allows the consumer to abstract all the internal details of marshalling the message from function call to a string
     * Calling client.api('') will return an unprefixed client. e.g api.hello() is equivalient to client.send('hello')
     */
    api(prefix?: string): any;
}
/**
 * Creates a RPC Server.
 * It is intentional that Server does not create a WebSocketServer object since we prefer composability
 * The Server can be used to communicate over processes, http or anything that can send and receive strings
 * It just needs to pass in an object that implements LikeSocketServer interface
 */
export declare class Server extends EventEmitter implements JsonRpc2.Server {
    private _socketServer;
    private _exposedMethodsMap;
    private _emitLog;
    private _consoleLog;
    constructor(server: LikeSocketServer, opts?: ServerOpts);
    private processMessage(messageStr, socket);
    /** Set logging for all received and sent messages */
    setLogging({logEmit, logConsole}?: LogOpts): void;
    private _logMessage(messageStr, direction);
    private _send(socket, message);
    private _sendError(socket, request, errorCode, error?);
    private _errorFromCode(code, data?, method?);
    expose(method: string, handler: (params: any) => Promise<any>): void;
    notify(method: string, params?: any): void;
    /**
     * Builds an ES6 Proxy where api.domain.expose(module) exposes all the functions in the module over RPC
     * api.domain.emit{method} calls will send {method} notifications to the client
     * The api object leads itself to a very clean interface i.e `await api.Domain.func(params)` calls
     * This allows the consumer to abstract all the internal details of marshalling the message from function call to a string
     */
    api(prefix?: string): any;
}
