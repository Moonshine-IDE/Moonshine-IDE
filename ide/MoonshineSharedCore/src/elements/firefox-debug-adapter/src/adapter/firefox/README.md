This folder contains the code for launching and talking to Firefox.

The [`launchFirefox()`](./launch.ts) function launches Firefox and establishes the TCP connection for
the debugger protocol. The connection's socket is passed to the [`DebugConnection`](./connection.ts)
class which implements the 
[Firefox Remote Debugging Protocol](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md)
using the [`DebugProtocolTransport`](./transport.ts) class for the
[transport layer](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#stream-transport)
of the protocol.
It passes the responses and events it receives to [proxy classes](./actorProxy) for the Firefox
[actors](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#actors).
The [`sourceMaps`](./sourceMaps) folder contains the debug adapter's source-map support.
