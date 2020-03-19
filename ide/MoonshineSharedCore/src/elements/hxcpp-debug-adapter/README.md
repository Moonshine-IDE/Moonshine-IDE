# HXCPP Debugger

[![Build Status](https://travis-ci.org/vshaxe/hxcpp-debugger.svg?branch=master)](https://travis-ci.org/vshaxe/hxcpp-debugger) [![Version](https://vsmarketplacebadge.apphb.com/version-short/vshaxe.hxcpp-debugger.svg)](https://marketplace.visualstudio.com/items?itemName=vshaxe.hxcpp-debugger) [![Installs](https://vsmarketplacebadge.apphb.com/installs-short/vshaxe.hxcpp-debugger.svg)](https://marketplace.visualstudio.com/items?itemName=vshaxe.hxcpp-debugger)

This VSCode extension allows you to debug [HXCPP](https://haxe.org/manual/target-cpp-getting-started.html) applications.

## Usage

To debug a HXCPP application, it needs to be compiled with the `hxcpp-debug-server` library and in debug mode. First, run the "HXCPP: Setup" command from the command palette (<kbd>F1</kbd>) to install the library.

Then the library needs to be included in your project:

* `build.hxml`:

	```
	-lib hxcpp-debug-server
	```

* Lime/OpenFL `project.xml`:

	```
	<haxelib name="hxcpp-debug-server" />
	```

Finally, you need a launch configuration:


```json
{ 
    "version": "0.2.0",
    "configurations": [
        {
            "name": "HXCPP",
            "type": "hxcpp",
            "request": "launch",
            "program": "${workspaceFolder}/bin/application.exe"
        }
    ]
}
```

Replace `/bin/application.exe` with the path to your executable file.

## Installing from source

1. Navigate to the extensions folder (`C:\Users\<username>\.vscode\extensions` on Windows, `~/.vscode/extensions` otherwise)
2. Clone this repo: `git clone https://github.com/vshaxe/hxcpp-debugger`
3. Change current directory to the cloned one: `cd hxcpp-debugger`.
4. Install dependencies:

    ```hxml
    npm install
    haxelib install vscode
    haxelib install vscode-debugadapter
    ```

5. Do `haxe build.hxml`

## Usage with lix
https://github.com/tbrosman/vshaxe-hxcpp-debugger-and-lix
