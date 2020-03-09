This folder contains proxy classes for the Firefox
[actors](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#actors).
They implement the [`ActorProxy`](./interface.ts) interface and provide a Promise-based API for
sending requests to and an EventEmitter-based API for receiving events from these actors.
