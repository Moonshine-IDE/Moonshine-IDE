# Debug Adapter for Firefox

This package implements the [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/) for Firefox.
It is part of the [VS Code Debugger for Firefox](https://marketplace.visualstudio.com/items?itemName=firefox-devtools.vscode-firefox-debug) but can be used by other IDEs as well to integrate with Firefox's debugger.

## Custom requests and events

In addition to the standard Debug Adapter Protocol, the debug adapter implements some custom requests and events:

### Requests

The following custom requests can be sent to the debug adapter:

* `toggleSkippingFile` : toggle whether a particular file (identified by its URL) is skipped (aka blackboxed) during debugging
* `reloadAddon` : reload the WebExtension that is being debugged
* `setPopupAutohide` : set the popup auto-hide flag (config key `ui.popup.disable_autohide`, WebExtension debugging only)
* `togglePopupAutohide` : toggle the popup auto-hide flag

### Events

The debug adapter sends these custom events:

* `popupAutohide` : contains the initial state of the popup auto-hide flag (WebExtension debugging only)
* `threadStarted` : sent when a thread-like actor (for a Tab, Worker or WebExtension) is started
* `threadExited` : sent when a thread-like actor exited
* `newSource` : sent when Firefox loaded a new source file
* `removeSources` : sent when a thread-like actor discards its previously loaded sources, i.e. when a Tab is navigated to a new URL
* `unknownSource` : sent when the user tries to set a breakpoint in a file that could not be mapped to a URL loaded by Firefox

The event body types are defined [here](../src/common/customEvents.ts).
The source events may be replaced by the [LoadedSourceEvent](https://microsoft.github.io/debug-adapter-protocol/specification#Events_LoadedSource) in the future.
