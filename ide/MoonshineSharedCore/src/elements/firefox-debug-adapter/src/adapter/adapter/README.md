This folder contains classes that translate between the
[Firefox Remote Debugging Protocol](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md)
and VS Code's [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/).
Furthermore, there are classes for managing [breakpoints](./breakpointsManager.ts),
[skipping](./skipFilesManager.ts) (or blackboxing) files in the debugger and
[addon debugging](./addonManager.ts).
