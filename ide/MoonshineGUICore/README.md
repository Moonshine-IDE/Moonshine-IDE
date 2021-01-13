# MoonshineGUICore

This project contains views created with [Feathers UI](https://feathersui.com/) and written in [Haxe](https://haxe.org/). We are currently in the process of migrating from Apache Flex to Feathers UI.

Since the _MoonshineGUICore_ project is written is Haxe, building it works a bit differently than the rest of Moonshine IDE, which is written in ActionScript and MXML.

## Prerequisites

- [Download Haxe](https://haxe.org/download/)
- [Install Feathers UI](https://feathersui.com/learn/haxe-openfl/installation/)

### Editors and IDEs

The _MoonshineGUICore_ project folder may be imported into Moonshine IDE or Visual Studio Code. It may be possible to create a project in other IDEs, but it will require manual configuration.

## Build

The _MoonshineGUICore_ project is currently compiled as a _.swc_ library file, so that the views may be used in ActionScript and MXML. The compiled library is used when building the main Moonshine IDE desktop project targeting Adobe AIR.

In a terminal, build _MoonshineGUICore_ with the following command:

```sh
openfl build flash -debug
```

In an editor or IDE, make sure that the Flash (Debug) OpenFL target is selected before building.

After building the library, you may need to reload the _MoonshineDESKTOPevolved_ application project in your editor/IDE to ensure that it recognizes any changed added/changed classes that you may have included in the compiled _MoonshineGUICore.swc_ file.

## Development

See [Convert Apache Flex views in Moonshine IDE to Feathers UI](https://github.com/prominic/Moonshine-IDE/wiki/Convert-Apache-Flex-views-in-Moonshine-IDE-to-Feathers-UI) for more details.
