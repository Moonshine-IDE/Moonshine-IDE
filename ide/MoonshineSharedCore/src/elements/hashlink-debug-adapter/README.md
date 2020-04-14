# HashLink Debugger
[![CI](https://img.shields.io/github/workflow/status/vshaxe/hashlink-debugger/CI.svg?logo=github)](https://github.com/vshaxe/hashlink-debugger/actions?query=workflow%3ACI) [![Version](https://vsmarketplacebadge.apphb.com/version-short/HaxeFoundation.haxe-hl.svg)](https://marketplace.visualstudio.com/items?itemName=HaxeFoundation.haxe-hl) [![Installs](https://vsmarketplacebadge.apphb.com/installs-short/HaxeFoundation.haxe-hl.svg)](https://marketplace.visualstudio.com/items?itemName=HaxeFoundation.haxe-hl)

This VSCode extension allows you to debug [HashLink](https://hashlink.haxe.org/) JIT applications.

*Only available on VSCode 64 bit*

## Building from Source

The following instructions are only relevant for building the extension from source and are **not required when installing it from the marketplace**.

### Compiling

You will need [Haxe 4](https://haxe.org/download/).

Additionally, you need to install these dependencies:

```
haxelib install vshaxe
haxelib install vscode
haxelib install vscode-debugadapter
haxelib install hscript
haxelib install format
```

Once all dependencies are ready, you should be able to compile with `haxe build.hxml`

#### Commandline version

Instead of the vscode plugin, you can also compile and run a commandline version, similar to `gdb`:

Debugger running in HashLink;
```
cd hashlink-debugger/debugger
haxe debugger.hxml
hl debug.hl /my/path/filetodebug.hl
```

You can then use gdb-like commands such as run/bt/break/etc. (see [sources](https://github.com/vshaxe/hashlink-debugger/blob/master/hld/Main.hx#L198))

The commandline debugger can also be compiled and run using nodejs, by doing:
```
cd hashlink-debugger/debugger
haxe node_debug.hxml
npm install
node debugger.js /my/path/filetodebug.hl
```


### Installing

Please note that VSCode does not allow users to have a specific directory for a single extension, so it's easier to clone this repository directly into the `extensions` directory of VSCode (`C:\Users\<you>\.vscode\extensions` on Windows).

Before running, you need to install a few NodeJS extensions. **DO NOT** npm install, as this will install the native extensions for your current NodeJS version and not for the Electron version of VSCode (if you did this already, simply remove the node_modules directory). Instead, run `make deps`, which will npm install & compile the extensions for the latest version of VSCode.

If the extension fails to run, maybe you are using a different version of VSCode than the one you compiled for.
Open VSCode, go to Help / Activate Development Tools, then in the dev console write `process.versions.electron` and replace it in the `Makefile`,  remove `node_modules` and recompile.

## OSX version

Both Windows and Linux are supported. We will soon work on OSX version using Mach tasks debugging API.
