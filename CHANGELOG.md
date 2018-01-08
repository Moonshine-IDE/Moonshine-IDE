# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine IDE [1.8.0]

### Added
* Reopen previously opened projects. This behavior can be disabled from the General tab in the application settings.
* Added "Confirm Exit" popup to prompt user before exiting. This feature is disabled by default, but can be enabled in the General tab in the application settings.
* Problems view: Added option to copy contents of columns "Problem" and "Location" to system clipboard.
* Projects tree: Added option "Select open file" in the header of projects tree.  This will show the file from the current tab in the project tree
* Projects tree: Added option "Copy path" to context menu in project tree.
* Projects tree: Added option "Show in Explorer" to context menu in project tree.
* Added global string search/replace. Available in menu:  Project -> Search.

### Changed
* Code Completion List: Show items in the list which contain the entered characters at any position.
* Visual Editor: Newly created project contains representation of main application window. User can change the basic application window properties.
* Show Tab close button ("x") on hover over unfocused tab.

### Fixed
* Fixed issue where newly created Flex Mobile project was not properly recognized.
* Console: Fixed issue where prompt background color makes command unreadable.
* Fixed issue where "Clean Project" causes hang of IDE.
* Fixed issue where "Clean Project" clears project selection.
* Fixed issue with "Build & Run" command when user has a system language other than English.

## Moonshine IDE [1.7.1]

### Added
* Added action to close all tabs from both the File menu and the tab context menu
* Tabs and project tree status are saved and restored when reopening a project.  This behavior can be disabled from the General tab in the application settings.
* Quickly switch between different application files by right-clicking and selecting "Set as Default Application"


### Changed


### Fixed
* Fixed bug where "Open Apache Flex/JS Project.." action did not work for an existing project
* Fixed bug where configured resources were not being properly copied when building a project
* Visual Editor: Fixed bug where new Visual Editor files were opening in the text editor
* Visual Editor: Fixed bug where additional Visual Editor files did not show up immediately in the exported project
* Visual Editor: Fixed bug where values width/height did not change in editing panel during component resize

## Moonshine IDE [1.7.0]

### Added 
* Basic Visual Editor which allows you to build Flex applications mockups and export them as Flex desktop projects
* Added support for creating Apache Royale projects.
* Added support for creating [Away3D](http://away3d.com/) projects.
* Code Editor: Auto close quotes for XML attributes.
* Code Completion List: Added icons, tooltips and documentation popup to have more information in completion list.
* Code Completion List: Open tooltip details and documentation popup (if available) of selected item by shortcuts (Windows: Ctrl + Q, Mac: Shift + F1).
* Added hamburger menu to hold tabs which do not fit into the window.

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
* When a project is closed or deleted, close all related editor tabs.

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
