## Synopsis

Moonshine is a free IDE built with Adobe AIR. You can create ActionScript 3, Apache Flex®, Apache FlexJS® and AIR projects from Moonshine. It also provides cloud support.
## Motivation

We want to provide a free IDE to our community for ActionScript projects. An IDE which is cross platform and provides Apache Flex®, Apache FlexJS®, and cloud support.

## Installation

### Prerequisites

We build Moonshine-IDE with Apache Flex SDK 4.15.0, using AIR and Flash 23.0.

### Desktop Version

First, build and deploy codecompletion.jar

    cd vscode-nextgenas_MoonshineModifications/
    ant deploy


To build the application itself, use these commands:

    cd ide/MoonshineDESKTOPevolved/build
    ant 

Find the generated artifacts in ide/MoonshineDESKTOPevolved/build/DEPLOY

### Web Version

To compile the SWF for the web version of Moonshine, run:

    cd ide/MoonshineWEBevolved/build
    ant 


Find the generated artifacts in ide/MoonshineWEBevolved/build/DEPLOY

NOTE:  this part of the project is out of date.  The server-side logic needs to be updated before the source can be released.

## License

Moonshine is licensed under the Apache License 2.0 - see the [LICENSE.md](LICENSE.md) file for details

