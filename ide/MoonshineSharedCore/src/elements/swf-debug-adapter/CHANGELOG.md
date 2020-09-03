# SWF Debugger for Visual Studio Code Changelog

## v1.2.2

### Fixed Issues

- General: Fix `NotConnectedException` on macOS due to bug in wrong SWF ID returned by runtime.
- General: Fix issue where the SWF unload was not handled correctly if it happened due to an exception before SWF load.

## v1.2.1

### Fixed Issues

- Breakpoints: Fixed issue where adding breakpoints to a SWF with frame scripts added in Adobe Animate could result in an InvalidPathException.

## v1.2.0

### New Features

- Workers: Pause, resume, step into, step over, and step out for workers.
- Stack: When worker stops on a breakpoint or exception, display the worker's stack trace.
- Variables: When a worker stops on a breakpoint or exception, list the variables in the current scope.

### Fixed Issues

- Breakpoints: Fixed issue where breakpoints added in document class constructor were ignored.
- General: Fixed issue where an error response to a request that fails incorrectly displayed a token instead of the real text.

## v1.1.2

### Fixed Issues

- Breakpoints: Fixed issue where a "no response" exception was thrown sometimes when setting breakpoints before the SWF finished loading.

## v1.1.1

### Fixed Issues

- Launch: Fixed issue where `mainClass` in _asconfig.json_ file was not correctly resolved.
- Launch: Fixed issue where no failure message was reported on exit when running without debug.

### Other Changes

- Launch: When _asconfig.json_ includes different Adobe AIR application descriptors for "ios" and "android", but the `versionPlatform` is not specified in _launch.json_, tries to use "ios" first and then "android" instead of failing.
- Launch: When _asconfig.json_ includes multiple Adobe AIR application descriptors for desktop platforms ("windows" and "mac"), uses the one that matches the current platform.
- Miscellaneous: Improved some exception handling related to runtime exitting.

## v1.1.0

### New Features

- Evaluate: Added support for assigning values from debug console.
- Threads: Updates list of workers when one is started or stopped.
- Variables: Added support for modifying string, number, and boolean values in the variables view when paused at a breakpoint.

### Fixed Issues

- Evaluate: Fixed exception when expression submitted through console when paused. Now displays a more appropriate error message.
- Step In/Out/Over: Improved exception handling when activated too quickly and runtime is not paused.
- Variables: Fixed "Invalid variable attributes" message in variables list.
- Workers: Fixed infinite loop when a worker is paused on exception or suspended for any other reason.

## v1.0.2

### Fixed Issues

- Linux: Fixed broken detection of _flashplayerdebugger_ executable location.
- Adobe AIR: Fixed issue where a custom `runtimeExecutable` in _launch.json_ would be ignored in some cases.
- Adobe AIR: Fixed issue where debugger might try to reference default paths to Adobe AIR executables, even if the SDK did not contain them.
- Adobe AIR: Fixed issue where detecting iOS devices failed if device handle were three digits instead of two.
- General: If a command like step in/out/over times out, prints a simpler message that no longer contains a stack trace to avoid looking like a crash.

## v1.0.1

### Fixed Issues

- Watch: Fixed issue where adding any watch expression failed with an error that made the debugger unresponsive.

## v1.0.0

### New Features

- Haxe: In addition to ActionScript and MXML projects, the extension now supports Haxe projects that target Adobe AIR or Flash Player. You can now add breakpoints in _.hx_ files.
- General: No longer requires a workspace containing an _asconfig.json_ file to debug SWFs. Missing fields in _launch.json_ will still be automatically populated, if _asconfig.json_ exists. However, if the file doesn't exist, all fields can be set manually, and helpful error messages will indicate if a field is missing or invalid.
- Attach: When specifying `platform` to install an Adobe AIR app on a mobile device, you may also specify its `applicationID` to uninstall any old versions, and the path to an _.apk_ or _.ipa_ `bundle` to install. These two new fields are automatically populated from _asconfig.json_, but may be specified manually for Haxe projects.

### Fixed Issues

- Attach: Fixed issue where port forwarding was not correctly cleaned up when finished debugging an Adobe AIR app on an Android device.

### Other Changes

- Initial release as a separate extension from [vscode-as3mxml](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-nextgenas).
