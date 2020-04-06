## Synopsis

Moonshine IDE is a free IDE built with Adobe AIR. You can create ActionScript 3, [Apache Flex®](https://flex.apache.org/), [Apache Royale®](http://royale.apache.org/) and [Feathers](https://feathersui.com/) projects from Moonshine-IDE. It also provides cloud support.
## Motivation

We want to provide a free IDE to our community for ActionScript projects. An IDE which is cross platform and provides Apache Flex®, Apache Royale®, Feathers and cloud support.

## Local Build

### External Prerequisites

To build Moonshine IDE you need: 
- [Apache Flex® SDK](https://flex.apache.org),
- [Adobe AIR and Flash Player](https://helpx.adobe.com/flash-player.html).

If you've used Moonshine IDE before and already downloaded Flex with Moonshine SDK Installer you can use existing SDKs. By default they're installed in `C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0`.

### Internal Prerequisites

To build Moonshine IDE you also need Moonshine SDK Installer source code. You can clone Moonshine SDK Installer from: `https://github.com/prominic/Moonshine-SDK-Installer.git`.

You should place SDK Installer repository on the same level as Moonshine IDE. So if you have Moonshine IDE in `C:\Repos\Moonshine-IDE` you should have SDK Installer in `C:\Repos\Moonshine-SDK-Installer`

### Change configuration files for local build

In `Moonshine-IDE\ide\MoonshineDESKTOPevolved\build\ApplicationProperties.xml` change:
- build version to something newer than already installed eg.
`<buildVersion><![CDATA[2.7.0]]></buildVersion>`

- SDK path for Flex and AIR eg.
`<winSDKPath><![CDATA[C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0]]></winSDKPath>`
`<winSDKPath64><![CDATA[C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0]]></winSDKPath64>`

In `Moonshine-IDE\ide\MoonshineDESKTOPevolved\src\MoonshineDESKTOP-app.xml`
- set AIR version for the one you have installed locally eg.
`<application xmlns="http://ns.adobe.com/air/application/32.0">`

### Build Desktop Version

If you need to recompile language server, build and deploy codecompletion.jar. If not you can skip this step.

    cd language-server-wrappers/moonshine-as3mxml
    ant deploy


To build the application itself, use these commands:

    cd ide/MoonshineDESKTOPevolved/build
    ant 

Find the generated artifacts in `ide/MoonshineDESKTOPevolved/build/DEPLOY`

### Build Web Version

To compile the SWF for the web version of Moonshine-IDE, run:

    cd ide/MoonshineWEBevolved/build
    ant 


Find the generated artifacts in `ide/MoonshineWEBevolved/build/DEPLOY`

NOTE:  this part of the project is out of date.  The server-side logic needs to be updated before the source can be released.

## License

Moonshine-IDE is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/prominic/Moonshine-IDE/blob/master/LICENSE.MD) file for details

