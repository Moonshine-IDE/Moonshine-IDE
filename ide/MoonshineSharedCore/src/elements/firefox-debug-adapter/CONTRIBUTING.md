# Hacking the VS Code Debug Adapter for Firefox

## Prerequisites
First of all, you should familiarize yourself with the
[debugging architecture of VS Code](https://code.visualstudio.com/api/extension-guides/debugger-extension#debugging-architecture-of-vs-code)
and the [Firefox Remote Debugging Protocol](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md).

## Setup
* fork and clone this repository and open it in VS Code
* run `npm install`
* run `npm run watch` or start the `watch` task in VS Code
* optional but recommended: run `npm run typecheck-watch` or start the `typecheck-watch` task in VS Code

Most source folders contain a `README` file giving an overview of the contained code.
Start with the [top-level README](./src).

## Debugging
This repository contains several launch configurations for debugging different parts of the code:
* to debug the debug adapter itself (i.e. the code under `src/adapter/`), use the `debug server`
  configuration to start it as a stand-alone server in the node debugger. Then open a web application
  in a second VS Code window and add a launch configuration of type `firefox` to it. Add
  `"debugServer": 4711` to this launch configuration, so that VS Code will use the debug adapter
  that you just launched in the other VS Code window. Set a breakpoint in the `startSession()` of 
  [`FirefoxDebugAdapter`](./src/adapter/firefoxDebugAdapter.ts) and start debugging the web application.
* to debug the extension code (under `src/extension/`), use the `extension host` configuration.
  It will open a second VS Code window with the extension in it running in the node debugger.
* the compound configuration `server & extension` will launch both of the configurations above
* the `web test` and `webextension test` configurations can be used if you need to manually
  reproduce the mocha tests. You'll need to start the `debug server` configuration first.
