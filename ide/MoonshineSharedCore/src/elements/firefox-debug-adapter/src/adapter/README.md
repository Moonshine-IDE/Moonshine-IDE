This folder contains the sources for the Firefox
[debug adapter](https://code.visualstudio.com/api/extension-guides/debugger-extension#debugging-architecture-of-vs-code).

The entry point is the [`FirefoxDebugAdapter`](./firefoxDebugAdapter.ts) class, which receives the
requests from VS Code and delegates most of the work to the [`FirefoxDebugSession`](./firefoxDebugSession.ts) class.

The [`firefox`](./firefox) folder contains the code for launching and talking to Firefox.

The [`coordinator`](./coordinator) folder contains classes that manage the states of
["threads"](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#interacting-with-thread-like-actors)
in Firefox.

The [`adapter`](./adapter) folder contains classes that translate between the debugging protocols of Firefox and VS Code.
