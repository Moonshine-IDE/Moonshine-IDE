## 1.1.0 (to be released)

* removed the need to specify `hxml` in `launch.json` (#4)

## 1.0.0 (February 2, 2020)

* reimplemented the step system using predictive temporary breakpoints
* improved display of types and values

## 0.9.1 (November 30, 2019)

* fixes for exception stack management in win64
* fixes for stepping in/out in x64
* fixed partial fetching for array/map/bytes

## 0.9.0 (November 22, 2019)

* improved exception stack detection
* added profileSamples configuration on launch (hl 1.11 profiler)

## 0.8.2 (November 11, 2019)

* compatible with VSCode 1.40 (Electron 6.2)
* added hotReload experimental configuration on launch

## 0.8.0 (October 10, 2019)

* added x64 function arguments support
* do not display variables once they are out of scope

## 0.7.1 (July 6, 2019)

* compatible with VSCode 1.36 (Electron 4.2.5)

## 0.7.0 (June 11, 2019)

* added an error message for trying to debug on macOS (#28)
* added optional `hl` and `env` fields to launch configs (#55)
* fixed pause button
* fixed some startup errors on Windows/Linux

## 0.6.0 (March 4, 2019)

* added optional `program` support (#3)
* fixed a crash with compile time cwd != runtime cwd
* fixed "Start Debugging" not doing anything without a `launch.json`
* updated `${workspaceRoot}` to `${workspaceFolder}`
* improved enum display in tree view
* added explicit error on ENOENT
* fixed static variables lookup
* fixed current package type lookup
* make sure to have correct port on launch (#37)
* prevent overflow error when doing pointer difference (#46)

## 0.5.2 (February 7, 2019)

* VSCode 1.31 compatibility (electron 3.1.2)

## 0.5.1 (December 3, 2018)

* More HashLink 1.9 (bytecode 5) support

## 0.5.0 (November 18, 2018)

* VSCode 1.29 compatibility (electron 2.0.12)
* HashLink bytecode 5 support
* stack overflow correctly reported on windows

## 0.4.4 (September 17, 2018)

* VSCode 1.27 compatibility (bugfix stepping)

## 0.4.3 (August 26, 2018)

* VSCode 1.26 compatibility (electron 2.0.5)
* added "break on all exceptions" support
* started set variable implementation (very little support for now)
* fixed HL 1.6- support

## 0.4.2 (July 11, 2018)

* added haxe.io.Bytes custom display
* fixed statics in classes within a package
* fixed error message when var unknown
* fixed with single captured var ptr

## 0.4.1 (July 11, 2018)

* fixed regression regarding locals resolution

## 0.4.0 (July 9, 2018)

* added attach/detach support
* fixed pause
* add member and static vars preview
* fixed static var eval()
* move breakpoint to next valid line when no opcode at this pos
* don't step in hl/haxe standard library anymore
* hl 1.7 support
* many other fixes

## 0.3.0 (June 12, 2018)

* added Linux support
* fixed initialize errors
* fixed newlines mix in debugger trace output
* don't escape strings in exception reports
* improved file resolution for breakpoints

## 0.2.0 (April 16, 2018)

* added HL 1.6 bytecode support
* started threads support

## 0.1.0 (April 9, 2018)

* added class/method in stack trace
* added hover eval (support member and static vars)
* allow access to member vars without this. prefix
* added native Map support
* fixed CALL skip bug when stepping
* group object fields by class scope with inheritance
* bugfix with field hashing in JS
* initial HL debugging
