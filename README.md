## Synopsis

Moonshine-IDE is a free IDE built with Adobe AIR. You can create ActionScript 3, [Apache Flex®](https://flex.apache.org/), Apache FlexJS®, [Apache Royale®](http://royale.apache.org/) and [Feathers](https://feathersui.com/) projects from Moonshine-IDE. It also provides cloud support.
## Motivation

We want to provide a free IDE to our community for ActionScript projects. An IDE which is cross platform and provides Apache Flex®, Apache FlexJS®, Apache Royale® and cloud support.

## Installation

### Prerequisites

We build Moonshine-IDE with [Apache Flex® SDK 4.16.1](https://flex.apache.org/installer.html), using [Adobe AIR and Flash Player 28.0](https://helpx.adobe.com/flash-player/release-note/fp_28_air_28_release_notes.html).

### Desktop Version

First, build and deploy codecompletion.jar

    cd vscode-nextgenas_MoonshineModifications/
    ant deploy


To build the application itself, use these commands:

    cd ide/MoonshineDESKTOPevolved/build
    ant 

Find the generated artifacts in ide/MoonshineDESKTOPevolved/build/DEPLOY

### Web Version

To compile the SWF for the web version of Moonshine-IDE, run:

    cd ide/MoonshineWEBevolved/build
    ant 


Find the generated artifacts in ide/MoonshineWEBevolved/build/DEPLOY

NOTE:  this part of the project is out of date.  The server-side logic needs to be updated before the source can be released.

## License

Moonshine-IDE is licensed under the Apache License 2.0 - see the [LICENSE.md](https://github.com/prominic/Moonshine-IDE/blob/master/LICENSE.MD) file for details

