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

### 4. Change configuration files for local build

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

### 5a. Build Desktop Version

If you need to recompile language server, build and deploy codecompletion.jar. If not, you can skip this step.

    cd language-server-wrappers/moonshine-as3mxml
    ant deploy


To build the application itself, use these commands:

    cd ide/MoonshineDESKTOPevolved/build
    ant 

Find the generated artifacts in `ide/MoonshineDESKTOPevolved/build/DEPLOY`

### 5b. Build Web Version

To compile the SWF for the web version of Moonshine-IDE, run:

    cd ide/MoonshineWEBevolved/build
    ant 


Find the generated artifacts in `ide/MoonshineWEBevolved/build/DEPLOY`

NOTE:  this part of the project is out of date.  The server-side logic needs to be updated before the source can be released.

## License

Moonshine-IDE is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/prominic/Moonshine-IDE/blob/master/LICENSE.MD) file for details

## Domino & Royale Geberated code introduce

### 1. issue reference
Royale:
	https://github.com/Moonshine-IDE/Moonshine-IDE/issues/675
	
Domino:
	https://github.com/Moonshine-IDE/Moonshine-IDE/issues/646

### 2. branch 
Royale:https://github.com/Moonshine-IDE/Moonshine-IDE/tree/features/issue_675_royale_generate_domino_visual_editor

Domino:https://github.com/Moonshine-IDE/Moonshine-IDE/tree/features/issue_646_ve_notes_domino_support_fresh

### 3. main entery point and how to trigger
Domino :
According to the design structure of moonshine ide
When user work with Visual Editors and clciks the "save" action or click the "code' tab from the Visual Editor,it will trigger the Domino convert.
	
So, please check following code:
https://github.com/Moonshine-IDE/Moonshine-IDE/blob/c4548fd104d734aa8d672fba4764a7c00a024e78/ide/MoonshineDESKTOPevolved/src/actionScripts/plugins/ui/editor/VisualEditorViewer.as#L423

getMxmlCode() method will identify projects and files, and perform domino conversions based on project and file types.


Royale:  
According to the requirements, the Royale project will be generated from the opened Domino Visual project, therefore, the user will click "Project->Generate Apache Royale Project" in the menu to generate a new Royale project.
	
So, please check following code:
https://github.com/Moonshine-IDE/Moonshine-IDE/blob/4363a2a14cfb8623d07937c0d2d12ad3fa7b7ccf/ide/MoonshineDESKTOPevolved/src/actionScripts/plugins/as3project/CreateProject.as#L989


This line code will convert the current open Domino Visual Editor project to Royale project.



