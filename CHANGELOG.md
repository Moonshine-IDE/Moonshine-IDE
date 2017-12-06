# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine IDE [1.7.0]

### Added 
* Code Editor: Auto close quotes for XML attributes.
* Code Completion List: Added icons, tooltips and documentation popup to have more information in completion list.
* Code Completion List: Open tooltip details and documentation popup (if available) of selected item by shortcuts (Windows: Ctrl + Q, Mac: Shift + F1).
* Added support for creating Apache Royale projects.
* Added support for creating [Away3D](http://away3d.com/) projects.
* Added hamburger menu to hold tabs which are not fitting into the window.

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.8.0](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.8.0).
* Project Tree: Double click to Expand/Collapse branches.
* Updated Setting > Templating to allow users to create new file and project templates that will appear in File > New.

### Fixed
* Find Resources: Button "Open" is now default, which allows user to confirm choice with "Enter" 
* Project directory defaults to directory used for the previous new project
* Project Creation: Fixed issue where project name was highlighted, but didn't have focus.
* Fixed issue where first import in the MXML file was inserted at the beginning of file.
* Debugging: Fixed null pointer exception which occurred while debugging MXML code.
* Fixed issue "The supplied index is out of bounds".
* Fixed issue where custom SDK path was not showing in macOS after a restart.
* Opened editors related to particular project now closes properly upon project close/delete.

## Moonshine IDE [1.6.1]

### Added 
* Settings:  Added option to change Java Development Kit path. See the "Default SDK" tab in the IDE settings.
* Settings:  Added "Reset all Settings (Hard)" button to reset all settings. See the "General" tab in IDE settings. 
* Project Settings:  Added support for projects with Native Extensions.
* Added "Feedback" section where user can share their experience with Moonshine on Twitter or Facebook, or report issues on GitHub.
* Added confirmation dialog before deleting files in the Projects sidebar
* Added partial support for Apache Royale.  User is able to open, build project and write code using Nightly build of Apache Royale.

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.7.0](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.7.0).
* The "Additional compiler options" field now has precedence over selected options in settings.
* Settings tabs are now sorted alphabetically. 

### Fixed
* Project settings: Fixed an issue where selecting -optimize=true did not work. 
* Project settings: Fixed an issue where "Additional compiler options" were disabled for projects other than Adobe Air.
* Project settings: Fixed an issue where "Ant Home" setting was reset after IDE restart.
* Fixed an issue where alerts for project deletion appeared twice.
* Menu: Fixed "File" -> "Moonshine App Store Helper" in Mac OS menu
* Fixed default launch URL for Flex web browser projects.

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
