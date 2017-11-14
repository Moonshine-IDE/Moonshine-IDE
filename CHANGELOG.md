# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine IDE [1.6.1]

### Added 
* Settings: Options to change Java Development Kit path. See the "Default SDK" tab in the IDE settings.
* Settings: Options "Reset all Settings (Hard)" to reset all settings. See the "General" tab in IDE settings. 
* Project Settings: Add support for projects with Native Extension.
* Add "Feedback" section where user can share experience with Moonshine on Twitter, Facebook and raise issue on GitHub.
* Add confirmation dialog to file/directory delete in project.
* Add partial support for Apache Royale. IDE is able to open, build project and write code using Nightly build of Apache Royale.

### Changed
* Update [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.7.0](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.7.0).
* Option "Additional compiler options" now have precedence agains selected options in settings.
* Settings: Sorting tabs in settings alphabetically. 

### Fixed
* Project settings: Fixed issue where selecting -optimize=true does not work. 
* Project settings: Fixed issue where "Additional compiler options" were disabled for other projects than Adobe Air.
* Fixed issue where alert for project delete appear twice.
* ANT: Fixed issue where option "Ant Home" was reset after IDE restart.
* Menu: On Mac OSX menu "File" -> "Moonshine App Store Helper" does not work
* Flex web browser project was created with wrong url for launch

## Moonshine IDE [1.6.0] 

### Added
* Useful Links Panel:  This panel contains links that may be useful for your development work.  More will be added as we find them.
* Options to customize the display for the AIR simulator for mobile projects.  See the Run tab in the project settings
* Window:  The window size and maximized status will be preserved when restarting Moonshine
* Panels:  The panel size will be preserved when restarting Moonshine
* Auto-updater:  Moonshine will automatically prompt you to update to new versions.  Disabled for the App Store version.


### Changed
* Debugging:  Using new engine adapted from [NexGenActionscript](https://nextgenactionscript.com/).  Improvements to highlighting and variables.  The debugger currently supports the Apache Flex® SDK and the Feathers SDK, but not Apache FlexJS®.
* Console:  Updated the source code links
* API Docs panel:  merged with Useful Links
* HTML-template:  Added wrapper HTML files for Web (Flash) project templates, to let them open properly in the browser.
* New Project Dialog:  Added a field to select the SDK when creating a project.

### Fixed
* ANT Build: 
** Fixed issue where ANT build was failing if path to build.xml contains spaces
** Fixed ANT script for FlexJS project template
* Project build: Fixed issue where FlexJS project build was failing if target player version has minor number (ex. `<target-player>11.7</target-player>`)
* Project build: Fixed issue where Moonshine generated blank SWFs for FlexJS builds using the 0.7.0 SDK or lower.
* Tooltips:  Fixed some cases where the tooltips didn't disappear properly.

### Notable Known issues

#### https://github.com/prominic/Moonshine-IDE/issues/36
While testing for this release, we noticed that most browsers were blocking the user from opening SWFs from their local filesystem.  The browsers will show a message like "To view this page ensure that Adobe Flash Player version 16.0.0 or greater is installed." and a "Get ADOBE FLASH PLAYER" button.

For most browsers, if you click the button, the browser will prompt you about whether you would like to allow the SWF to run.  After you allow this, you can run the SWF normally.  However, Firefox will direct you to a download page instead, so you may want to test in other browsers for now..  

Alternatively, you can bypass the above errors by deploying the generated SWF to a local or remote server.
