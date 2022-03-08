## Synopsis

Moonshine IDE is a free IDE built with Adobe AIR. You can create ActionScript 3, [Apache Flex®](https://flex.apache.org/), [Apache Royale®](http://royale.apache.org/) and [Feathers](https://feathersui.com/) projects from Moonshine-IDE. It also provides cloud support.

## Motivation

We want to provide a free IDE to our community for ActionScript projects. An IDE which is cross platform and provides Apache Flex®, Apache Royale®, Feathers and cloud support.

## Local Build

### 1. Install Apache Ant

To build Moonshine IDE you need to install [Apache Ant](https://ant.apache.org/manual/install.html). You can also install Apache Ant using npm, chocolatey, etc.

### 2. Download SDKs

To build Moonshine IDE you need to download: 
- [Apache Flex® SDK](https://flex.apache.org),
- [Adobe AIR and Flash Player](https://helpx.adobe.com/flash-player.html).

If you've used Moonshine IDE before and already downloaded these SDKs with Moonshine SDK Installer you can use existing SDKs. By default they're installed in:
- `C:\MoonshineSDKs\Flex_SDK\Flex_xxx_AIR_xxx` on Windows
- `/Users/$username/Downloads/MoonshineSDKs` on Mac

### 3. Clone Moonshine SDK Installer

To build Moonshine IDE you also need Moonshine SDK Installer source code. You can clone Moonshine SDK Installer from: `https://github.com/prominic/Moonshine-SDK-Installer.git`.

You should place SDK Installer repository on the same level as Moonshine IDE. So if you have Moonshine IDE in `C:\Repos\Moonshine-IDE` you should have SDK Installer in `C:\Repos\Moonshine-SDK-Installer`.

### 4. Additional Required Projects

These projects are also required, but do not require separate compilation:
- Visual Editor ([documentation](https://github.com/Moonshine-IDE/Moonshine-IDE/wiki/Visual-Editor-Architecture))
    - [VisualEditorConverterLib](https://github.com/Moonshine-IDE/VisualEditorConverterLib)
    - [MockupVisualEditor](https://github.com/Moonshine-IDE/MockupVisualEditor)
- Text Editor:
    - [moonshine-feathersui-text-editor](https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor)
    - Language server integration:  [moonshine-openfl-language-client](https://github.com/Moonshine-IDE/moonshine-openfl-language-client) 
- Debugger:  [moonshine-openfl-debug-adapter-client](https://github.com/Moonshine-IDE/moonshine-openfl-debug-adapter-client)


### 5. Change configuration files for local build

In `Moonshine-IDE\ide\MoonshineDESKTOPevolved\build\ApplicationProperties.xml` change:
- Build version to something newer than already installed eg.

	```
	<buildVersion><![CDATA[2.7.0]]></buildVersion>
	```

- If you have FLEX_HOME set up as environment variable you can skip this step. If not, set one of the following parameters:

	On Windows 32-bit:
	```
	<winSDKPath><![CDATA[C:\MoonshineSDKs\Flex_SDK\Flex_xxx_AIR_xxx]]></winSDKPath>
	```
	
	On Windows 64-bit:
	```
	<winSDKPath64><![CDATA[C:\MoonshineSDKs\Flex_SDK\Flex_xxx_AIR_xxx]]></winSDKPath64>
	```
	
	On Mac and Linux:
	```
	<unixSDKPath><![CDATA[path/to/Flex_xxx_AIR_xxx]]></unixSDKPath>
	```

In `Moonshine-IDE\ide\MoonshineDESKTOPevolved\src\MoonshineDESKTOP-app.xml`
- By default Moonshine IDE builds with AIR 28.0. If you've installed newer version of AIR SDK on your environment (eg. 32.0) change this parameter accordingly:

	```
	<application xmlns="http://ns.adobe.com/air/application/32.0">
	```

### 6a. Build Desktop Version

If you need to recompile language server, build and deploy codecompletion.jar. If not, you can skip this step.

    cd language-server-wrappers/moonshine-as3mxml
    ant deploy


To build the application itself, use these commands:

    cd ide/MoonshineDESKTOPevolved/build
    ant 

Find the generated artifacts in `ide/MoonshineDESKTOPevolved/build/DEPLOY`

### 6b. Build Web Version

To compile the SWF for the web version of Moonshine-IDE, run:

    cd ide/MoonshineWEBevolved/build
    ant 


Find the generated artifacts in `ide/MoonshineWEBevolved/build/DEPLOY`

NOTE:  this part of the project is out of date.  The server-side logic needs to be updated before the source can be released.

## License

Moonshine-IDE is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/prominic/Moonshine-IDE/blob/master/LICENSE.MD) file for details

