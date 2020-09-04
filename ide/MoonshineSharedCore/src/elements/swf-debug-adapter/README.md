# SWF Debugger for Visual Studio Code

Enables debugging applications in the [Adobe AIR](https://www.adobe.com/products/air.html) and [Adobe Flash Player](https://www.adobe.com/products/flashplayer.html) runtimes. Supports source files written in ActionScript, MXML, or Haxe.

Extension created and maintained by [Josh Tynjala](https://patreon.com/josht). By [becoming a patron](https://www.patreon.com/bePatron?c=203199), you can directly support the ongoing development of this project.

- [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [ActionScript & MXML](#actionscript-and-mxml)
  - [OpenFL](#openfl)
  - [Haxe](#haxe)
- [Additional Examples](#additional-examples)
- [List of launch configuration attributes](#launch-configuration-attributes)
- [Support this project!](#support-this-project)

## Requirements

- Visual Studio Code 1.37
- Java 1.8 Runtime
- Adobe AIR or Adobe Flash Player

### Adobe AIR

To debug [Adobe AIR](https://www.adobe.com/products/air.html) applications, download the **Adobe AIR SDK** for Windows or macOS, which is available from HARMAN's website:

- [Download Adobe AIR SDK from HARMAN](https://airsdk.harman.com/download)

For Adobe AIR version 32.0 or older, download it from Adobe's website instead:

- [Archived Adobe AIR SDK versions](https://helpx.adobe.com/air/kb/archived-air-sdk-version.html)

### Adobe Flash Player

To debug _.swf_ files in [Adobe Flash Player](https://www.adobe.com/products/flashplayer.html), download the **Flash Player projector content debugger** for Windows, macOS, or Linux, which is available from Adobe's website.

- [Adobe Flash Player Support Center: Debug Downloads](https://www.adobe.com/support/flashplayer/debug_downloads.html)

> Be sure to make the Flash Player the operating system's default program for the _.swf_ file extension. If it's not the default program, it's possible manually specify the executable path using the `runtimeExecutable` attribute in _launch.json_ instead.

## Getting Started

Depending on which language/framework builds the _.swf_ file, the steps to configure the SWF debug extension may vary.

- [ActionScript and MXML projects](#actionscript-and-mxml)
- [OpenFL projects](#openfl)
- [Haxe projects](#haxe)

### ActionScript and MXML

This extension offers tight integration with the [ActionScript & MXML langauge extension](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-nextgenas). Many attributes in the workspace's _launch.json_ file can be omitted because they will be populated automatically based on the project's [_asconfig.json_](https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json) file.

ActionScript & MXML projects built using any of the following SDKs or tools may be debugged using the SWF debug extension:

- Adobe AIR SDK & Compiler
- Adobe Animate
- Apache Flex SDK
- Adobe Flex SDK
- Apache Royale
- Feathers SDK

To get started, create a new [launch configuration](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations). All launch configurations for the current worksace are stored in its _.vscode/launch.json_ file.

The following example _launch.json_ contains a `swf` launch configuration with the minimum set of attributes required to launch a debug session for an ActionScript & MXML project:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF"
    }
  ]
}
```

Using the contents of the project's [_asconfig.json_](https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/asconfig.json) file, the SWF debug extension automatically detects which runtime should be used (either Adobe AIR or Flash Player). Additionally, it will detect the location of the compiled _.swf_ file, and (if it exists) the location of the Adobe AIR application descriptor file. The extension can also determine if an Adobe AIR project targets desktop or mobile.

#### Start a debug session

To start debugging, open the **Debug** menu in Visual Studio Code, and select **Start Debugging** (or use the **F5** keyboard shortcut).

#### Build before debugging (AS3 & MXML)

To build an ActionScript & MXML project before starting a debug session, add the `preLaunchTask` attribute. In most cases, use the compile task specified in the following example:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "preLaunchTask": "ActionScript: compile debug - asconfig.json"
    }
  ]
}
```

### OpenFL

When using [OpenFL](https://openfl.org/) to target Adobe AIR or Flash Player, certain additional SWF launch configuration attributes need to be set manually.

Most importantly, the `program` attribute must be set to either the path of an Adobe AIR application descriptor or the path of a _.swf_ file.

Find the correct paths inside the [_project.xml_ file](https://lime.software/docs/project-files/xml-format/) that configures OpenFL. In particular, this information is available on the `<app>` element:

```xml
<app main="com.example.MyProject" file="MyProject" path="build"/>
```

The `path` attribute is the main output folder where binaries are created. The `file` attribute is used to name the compiled _.swf_ file.

Building the project above for Adobe Flash Player creates _build/flash/bin/MyProject.swf_. Specify this path using the `program` attribute, as shown below:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "program": "${workspaceFolder}/build/flash/bin/MyProject.swf"
    }
  ]
}
```

When building the same project for Adobe AIR, the _.swf_ file is created at _build/air/bin/MyProject.swf_ instead. OpenFL also creates the Adobe AIR application descriptor at _build/air/application.xml_.

Notice that _application.xml_ and _MyProject.swf_ are not located in the same folder. However, inside _application.xml_, it references _MyProject.swf_ file instead of _bin/MyProject.swf_:

```xml
<content>MyProject.swf</content>
```

Use the `rootDirectory` attribute to specify that the app's content is not located in the same folder that contains the application descriptor.

Set the `profile` attribute to either `desktop` or `mobileDevice`, depending on which platform should be simulated.

Finally, the SWF debugger needs the location of the **adl** executable from the Adobe AIR SDK. Pass the absolute path to the `runtimeExecutable` attribute.

The following example _launch.json_ file combines all of these values to configure Adobe AIR debugging for an OpenFL project:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "profile": "desktop",
      "program": "${workspaceRoot}/build/air/application.xml",
      "rootDirectory": "${workspaceRoot}/build/air/bin",
      "runtimeExecutable": "/absolute/path/to/AIR_SDK/bin/adl"
    }
  ]
}
```

On macOS, use _adl_ as the excutable name. On Windows, use _adl.exe_.

> When setting up Lime and OpenFL, you may have already [set up the path to the Adobe AIR SDK](https://lime.software/docs/advanced-setup/air/), which is stored in _~/.lime/config.xml_. It's a good idea to use the same SDK for debugging.

#### Start a debug session

To start debugging, open the **Debug** menu in Visual Studio Code, and select **Start Debugging** (or use the **F5** keyboard shortcut).

#### Build before debugging (OpenFL)

To build an OpenFL project before starting a debug session, add the `preLaunchTask` attribute.

When targeting Adobe Flash Player, run the `lime: build flash -debug` task:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "program": "${workspaceFolder}/build/flash/bin/MyProject.swf",
      "preLaunchTask": "lime: build flash -debug"
    }
  ]
}
```

When targeting Adobe AIR, run the `lime: build air -debug` task:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "profile": "desktop",
      "program": "${workspaceRoot}/build/air/application.xml",
      "rootDirectory": "${workspaceRoot}/build/air/bin",
      "runtimeExecutable": "/absolute/path/to/AIR_SDK/bin/adl",
      "preLaunchTask": "lime: build air -debug"
    }
  ]
}
```

### Haxe

When using [Haxe](https://haxe.org/) to target Adobe AIR or Flash Player, certain compiler options must be used to enable debugging, and additional SWF launch configuration attributes need to be set manually.

To compile a _.swf_ file with Haxe that may be used with the SWF debug extension, add `-debug` and `-D fdb` to the project's [_.hxml_ file](https://haxe.org/manual/compiler-usage-hxml.html), as shown in the example below:

```hxml
-cp src
-main com.example.MyProject
-swf bin/MyProject.swf
-swf-version 30
-swf-header 960:640:60:ffffff
-debug
-D fdb
```

To debug in Adobe Flash Player, set the `program` attribute in _launch.json_ to the path specified by the `-swf` Haxe compiler option:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "program": "${workspaceFolder}/bin/MyProject.swf"
    }
  ]
}
```

To debug in Adobe AIR, set the `program` attribute in _launch.json_ to the path of an Adobe AIR application descriptor.

Set the `profile` attribute to either `desktop` or `mobileDevice`, depending on which platform should be simulated.

Finally, the SWF debugger needs the location of the **adl** executable from the Adobe AIR SDK. Pass the absolute path to the `runtimeExecutable` attribute.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "profile": "desktop",
      "program": "${workspaceRoot}/bin/MyProject-app.xml",
      "runtimeExecutable": "/absolute/path/to/AIR_SDK/bin/adl"
    }
  ]
}
```

On macOS, use _adl_ as the excutable name. On Windows, use _adl.exe_.

## Additional Examples

For Adobe AIR mobile projects, a number of additional attributes are available to customize which type of device to simulate. For example, the following launch configuration simulates an iPhone with "Retina" display:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "screensize": "iPhoneRetina",
      "screenDPI": 326,
      "versionPlatform": "IOS"
    }
  ]
}
```

Similarly, the following launch configuration might be used to simulate an Android phone.

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "swf",
      "request": "launch",
      "name": "Launch SWF",
      "screensize": "768x1280:768x1232",
      "screenDPI": 318,
      "versionPlatform": "AND"
    }
  ]
}
```

For a larger list of common mobile devices, see [launch.json configuration settings for simulating common mobile devices in Adobe AIR](https://github.com/BowlerHatLLC/vscode-as3mxml/wiki/launch.json-configuration-settings-for-simulating-common-mobile-devices-in-Adobe-AIR).

## Launch configuration attributes

The following lists of attributes may be customized in _launch.json_ for the configurations of type `swf`. They are divided by request type — either `launch` or `attach`.

### Launch request

If the value of the `request` attribute is set to `launch`, the following attributes may be customized:

- `args`

  Custom command line arguments to pass to an Adobe AIR application. The are accessible at runtime using the `arguments` property of `flash.events.InvokeEvent`.

- `exdir`

  The directory where the application's _unpackaged_ native extensions (ANEs) are located. Unpackaged native extensions are unzipped for debugging. The ActionScript & MXML extension unpackages native extensions automatically. Unpackaging should be done manually for Haxe projects.

  _Populated automatically for ActionScript & MXML projects_

- `profile`

  The Adobe AIR application profile to simulate. May be set to `desktop`, `extendedDesktop`, `mobileDevice`, or `extendedMobileDevice`.

  _Populated automatically for ActionScript & MXML projects_

- `program`

  Path to an Adobe AIR application descriptor or a _.swf_ file. To launch a _.swf_ file embedded in HTML, set to the path of an _.html_ file or to an http/https URL.

  _Populated automatically for ActionScript & MXML projects_

- `rootDirectory`

  Specifies the root directory of the Adobe AIR application. If not specified, the directory containing the application descriptor file is used.

- `runtimeArgs`

  Optional arguments to pass to the runtime executable.

* `runtimeExecutable`

  Path to the Adobe AIR debug launcher, the Flash Player projector content debugger, or a web browser.

* `screenDPI`

  The screen density (sometimes called DPI or PPI) of the mobile device to simulate. Customizes the value returned by `flash.system.Capabilities.screenDPI`. Typically used in combination with `screensize`.

* `screensize`

  The normal and full-screen dimensions of the simulated mobile device. Typically used in combination with `screenDPI`.

* `versionPlatform`

  The platform string to simulate in the AIR Debug Launcher. Customizes the value returned by `flash.system.Capabilities.version`. May be set to `IOS`, `AND`, `WIN`, or `MAC`.

### Attach request

If the value of the `request` attribute is set to `attach`, the following attributes may be customized:

- `applicationID`

  If the `platform` attribute is set, specifies the Adobe AIR application ID used to uninstall and launch on a mobile device connected with USB.

  _Populated automatically for ActionScript & MXML projects_

- `bundle`

  If the `platform` attribute is set, specifies the path to an _.apk_ or _.ipa_ file to install on a mobile device connected with USB.

  _Populated automatically for ActionScript & MXML projects_

- `connect`

  By default, the SWF debugger will listen for connections from mobile devices over wi-fi. If the `connect` attribute is `true`, the debugger will try to connect to the runtime over USB instead.

- `port`

  If the `connect` attribute is `true`, the SWF debugger will connect to the mobile device on the specified port.

- `platform`

  The debugger will connect to a mobile device running the specified platform. May be combined with `applicationID` and `bundle`.

## Support this project

The [SWF debugger extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=bowlerhatllc.vscode-swf-debug) is developed by [Josh Tynjala](http://patreon.com/josht) — thanks to the generous support of developers and small businesses in the community. Folks just like you! By [becoming a patron](https://www.patreon.com/bePatron?c=203199), you can join them in supporting the ongoing development of this project.

[Support Josh Tynjala on Patreon](http://patreon.com/josht)

Special thanks to the following sponsors for their generous support:

- [Moonshine IDE](http://moonshine-ide.com/)
- [Dedoose](https://www.dedoose.com/)
