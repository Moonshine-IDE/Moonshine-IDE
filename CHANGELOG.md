# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine IDE [2.2.0]

### Summary

This release was focused on adding Git support in the Manage Repositories interface from 2.1.0.  You may now clone and track Git repositories in this interface.  To help new users get started, we have added a few example repositories to the interface by default.  This includes the Moonshine source and some examples for Apache Royale.

We also made some changes to make it faster to clone complicated projects.  Moonshine will now automatically detect subprojects within a repository, and prompt the user to decide which projects to open.  In addition, we added a feature to allow repositories to define links to other repositories with moonshine-dependencies.xml.   For example, Moonshine-IDE provides links to all of its external dependencies, so that you can clone all required projects without leaving Moonshine or reviewing a README file.  This file may be added to other repositories using the format defined [here](https://github.com/prominic/Moonshine-IDE/wiki/Link-Related-Projects-with-moonshine-dependencies.xml).

### Added
* Added support to define related repositories for an SVN or Git repository, using moonshine-dependencies.xml.  See the documentation [here](https://github.com/prominic/Moonshine-IDE/wiki/Link-Related-Projects-with-moonshine-dependencies.xml).
* If a cloned or checked out repository contains multiple subprojects (like https://github.com/prominic/Moonshine-IDE.git), Moonshine will allow the user to automatically open the subprojects (up to 3 levels deep).
* Added [Apache Royale](https://royale.apache.org/) Jewel project template.  This requires a nightly build (0.9.6)](http://apacheroyaleci.westus2.cloudapp.azure.com:8080/job/royale-asjs_jsonly/lastSuccessfulBuild/artifact/out/) of Apache Royale.

### Changed
* Added support for Git in the Manage Repositories interface.
* Provide non-sandbox version of Moonshine for Mac users.
* Visual Editor: Allow search **Code** tab using menu option **Edit** -> **Find**.

### Fixed
* Fixed issue where Browse All repository threw an error when the repository list was empty. 
* Templates: Fixed issue where modifying a template triggered an exception 

#### Known Issue
* Template modifications will not be applied to new projects.
* The Jewel template for Apache Royale requires the latest nightly build (0.9.6)](http://apacheroyaleci.westus2.cloudapp.azure.com:8080/job/royale-asjs_jsonly/lastSuccessfulBuild/artifact/out/) which is not currently available with Moonshine SDK Installer



## Moonshine IDE [2.1.0]

### Added
* Added repository browser for SVN to allow users to browse the files inside of a repository before checking out a directory.
* Visual Editor PrimeFaces: Add **Preview** button for opened file.
* Java Maven Project: Added **Build & Run** option in menu **Project**.
* Added syntax highlighting for IDE project files.
* Improved handling of environment variables for build (and other) actions from Moonshine
* Automatically select an appropriate SDK for a new project based on the project type.
* About screen shows the versions of all configured SDKs.  This may take a few seconds to populate.

### Changed
* Updated [as3mxml](https://as3mxml.com/) engine to version 0.18.0.
* Visual Editor: Updated Payara server to [5.191](https://github.com/payara/Payara/releases/tag/payara-server-5.191) for PrimeFaces preview 
* Menu Project: Improved logic for displaying items in menu. The displayed items depend on the type of the currently selected project. 
* Home Tab: Excluded **Tour De Flex** files from the **RECENT** list.
* Import Project:  Added greater flexibility for selecting the main application file when importing a project.
* Problems View has been moved to bottom of the interface with the Console and Debug views.
* The Getting Started page will display if any of the SDKs are not installed.  This behavior can be disabled with the "Do not show" checkbox - the tab can still be opened from Help > Getting Started.

### Fixed
* Tour De Flex: Fixed issue where files were opened in wrong editor
* Java Project: Fixed issue that caused New Project menua to be very slow
* Java Project: Fixed issue when Java project do not deletes fully
* Fixed issue where updating a project dependency path threw an error when the earlier path was invalid.
* Access Manager: Fixed issue where Moonshine threw an error when a Java of project was opened
* Visual Editor: Fixed issue preventing the selected element in the visual editor from highlighting in the Code tab
* Find: Fixed issue where searching was disabled for Java projects.
* Git:  Fixed issue where Git project triggered error on Moonshine startup


## Moonshine IDE [2.0.0]

### Added
* Added **Getting Started** page to assist new users with setting up the external SDK and tool requirements for different Moonshine features.

### Changed
* Java Project: Improvements for building with Maven

### Fixed
* Subversion: Fixed issue where subversion menu was not updated after granting permission.
* Feathers: Fixed issue where build project failed with newest Adobe AIR.
* Java Project: Fixed issue where java project template was not populated when we create new class/interface.
* Language Server:  Fixed dependencies so that language server can start without a default Flex SDK
* Language Server:  Restart language server when Java Home path is updated in Settings.
* Git Integration:  Improved behavior when Git status information is slow to load.
* Project Sidebar:  Fixed case where Project Sidebar did not load on Moonshine startup

## Moonshine IDE [1.16.0]

### Added
* Defined a [Privacy Policy](http://moonshine-ide.com/privacy-policy/) for Moonshine and moonshine-ide.com.  The page is linked in the **Help** menu.
* Visual Editor: Added **Organizer** to allow users to view the structure of the mockup and change the order or nesting of the components.
* Visual Editor PrimeFaces: Added components [calendar](https://www.primefaces.org/showcase/ui/input/calendar.xhtml), [textEditor](https://www.primefaces.org/showcase/ui/input/textEditor.xhtml), [selectOneRadio](https://www.primefaces.org/showcase/ui/input/oneRadio.xhtml), [selectOneMenu](https://www.primefaces.org/showcase/ui/input/oneMenu.xhtml) and [selectOneListbox](https://www.primefaces.org/showcase/ui/input/listbox.xhtml).
* Visual Editor PrimeFaces: Added CDATA information to property panel if provided through component.
* Visual Editor PrimeFaces: Added instant preview for project files in the browser.
* File association support for known file types.
* Copying of files and folders from inside or outside of Moonshine, to the project sidebar.
* New File: Added code completion for Superclass and Interfaces.
* Java: Initial support for Java language project types, including code intelligence features.
* Code Generation: In ActionScript and MXML, generate a getter and setter, a local variable, a member variable, or a method. When a quick fix is available at the current position in the editor, a light bulb icon will appear.
* Go to Definition: Added feature to go to definitions that are defined in SWC files. This will open a temporary, read-only file that displays the public API.
* Workspace Symbols: Classes and interfaces defined in SWC files now appear in search results.
* Go to Type Definition: New menu command to go to the definition of a variable or property's type.
* Project Run Settings:  Added new field in Project > Settings > Run to allow launching a browser project with a custom URL.  This allows the user to open a server URL instead of a file path.
* Visual Editor PrimeFaces: Added Undo/Redo on Copy/Paste.
* Added Apache Maven support.
* Open projects in Moonshine by double clicking on the project files (.as3proj and .veditorproj).
* Open/Import Moonshine projects from ZIP archives.
* Project Tree:  Allow multiple files to be selected at once to support bulk copy or delete options

### Changed
* Updated [as3mxml](https://as3mxml.com/) engine to version 0.17.2.
* Open file/folder dialog will retain the last opened location.

### Fixed
* Visual Editor: Fixed issue where the Property panel did not display a scrollbar.
* Visual Editor: Fixed issue where deleting a file when "Hidden files/folder" was ON triggered an exception.
* Visual Editor PrimeFaces: Fixed issue where saving a file without main Div was failing.
* Visual Editor PrimeFaces: Fixed issue where selecting a PanelGrid cell did not display its content properly in Property Editor.
* Visual Editor PrimeFaces: Fixed issue where Copy/Paste was failing in Grid.
* Visual Editor PrimeFaces: Fixed issue where TabView label did not update after reopening the saved file.
* Visual Editor PrimeFaces: Fixed issue where Calendar component wasn't updated due to changes in property panel.
* Apache Royale: Fixed issue where Moonshine could not build [MX examples](https://github.com/apache/royale-asjs/tree/develop/examples/mxroyale).
* Apache Royale: Fixed issue where user could not create MXML and AS files.
* Search: Fixed issue with the Backward option in Find/Replace.
* Language server: Fixed issue where Java instance continued running after application exit.
* Code Editor: Fixed issue where to used variables in CDATA section through code intelligence were added closing parentheses, used in MXML.
* Home Screen: Fixed issue when closing and re-opening of Home screen/tab do not opens items from recent opened lists (projects, files).
* Problems: Fixed issue where problems were not cleared from the Problems view after closing a project.
* Code Editor: Fixed issue where package name was incorrect after file creation.
* Java Projects: Fixed issue where opening a Java project threw an error.
* Java Projects: Fixed issue with importing and deleting Java Projects
* Native Extension Usage: Fixed issue where compiling project with multiple Native Extension files used only one in the process
* Flash Browser Project: Fixed issue where Flash browser project had no option to choose and run by a browser URL


## Moonshine IDE [1.15.0]

### Added
* Visual Editor:  Added the name of the component as a header on the property panel.
* Visual Editor:  Highlight code for selected element when switching to the Code tab
* Visual Editor:  Duplicate controls with CTRL-U (Windows) or CMD-U (macOS)
* Visual Editor:  Added PanelGrid component.

### Changed
* Updated [as3mxml](https://as3mxml.com/) engine to version 0.12.1-SNAPSHOT.
* Visual Editor:  Ignore unknown tags in visual editor XML.
* Visual Editor:  Allowed text files to be created in visual editor projects
* Visual Editor:  Enabled scrollbars in mockup area.
* Visual Editor PrimeFaces:  Improvement to generated code for Grid component.
* Visual Editor PrimeFaces:  Added additional container to TabView which allows positioning children in each tab.
* Visual Editor PrimeFaces:  Added dynamic heights for some components.
* Subversion:  Added option to force SVN to trust certificate errors.

### Fixed
* Fixed issue where projects did not automatically open on restart if language server was not set.
* Fixed issue where projects with existing source code did not list sub folders under the main source folder.
* Git:  Fixed issue where IDE prompted user to install XCode during command line usage.
* Visual Editor:  Fixed issue where reordering order was not possible.  Further improvements to component reordering are pending.
* Visual Editor:  Fixed issue where Undo/Redo did not work properly when there were multiple open Visual Editor tabs.
* Visual Editor:  Disabled **Edit > Find** (and the corresponding shortcuts) for the Visual Editor tab.
* Visual Editor:  Fixed issue where Include component did not properly display the list of files.
* Visual Editor:  Fixed issue where the tab selected in the mockup area was not properly selected in the Properties panel


## Moonshine IDE [1.14.0]

### Added
* Basic Git Support **Clone**, **Commit**, **Push/Pull**, **View/Revert** modifications, **Create/Switch** branches
* Option to mark files or folders as hidden in the project tree.  Use the "Show hidden files/folders" setting in the General settings to determine whether or not these files should be displayed (NOTE:  the changes for this setting will not be applied until the project is closed and reopened, or Moonshine is restarted).
* Visual Editor:  Added duplicate (CTRL-U or CMD-U) and copy/paste (CTRL-C/CMD-C and CTR-V/CMD-V) actions.  This is currently only available by shortcut.

### Changed
* Visual Editor:  Improvement to PrimeFaces Grids.
* Visual Editor:  Added "Command Button" option for Button control.
* Visual Editor:  Added reverse command for Tab in property panel using SHIFT + Tab shortcut.

### Fixed
* Fixed error triggered with "Set as Default Application" action in file context menu.
* Fixed #1009 startup error after Revoking All Access from Access Manager interface.
* Fixed errors on project deletion.
* Fixed issue where drop down list **Parent Directory** show only first directory in the list instead the most recent one.
* Fixed issue *Failed to get compile settings for +configname=flex* during library build.
* Visual Editor: Fixed issue where PrimeFaces InputNumber does not accept numbers greater than 999999999999999.
* Visual Editor: Fixed issue where PrimeFaces Include component causes runtime error in exported project.
* Visual Editor: Fixed issue where repositioning elements was not possible.  The reordering functionality is still very limited (see #255).
* Visual Editor: Fixed issue where editor reports error for files with the same name in different directories.

## Moonshine IDE [1.13.0]

### Added
* Added **Recent Projects** and **Recent Files** menus to the **File** menu.
* Visual Editor: Added undo/redo support
* Visual Editor: Expand/Collapse the components and properties panels
* Visual Editor: Added new properties to PrimeFaces autoComplete component which allows field to be filled by data after export.

### Changed
* **Home** tab is now closeable. 
* Debug View has been moved to the console area.
* Delete Project/File: Improvement in scenario when user tries to remove project which was already removed
* Allowed '-' filenames except for .as and .mxml
* Removed all references to FlexJS.
* Restricted more special characters from Project names.

### Fixed
* Fixed issue where cursor flashes both in Console and Editor at the same time.
* Editor: Fixed issue where jump to the next line produces unwanted characters.
* Menu: Fixed issue where some items were disabled inappropriately.
* Home Tab: Fixed issue where **Recent** projects were invisible when some of the projects had long names.
* Visual Editor: Fixed issue where PrimeFaces Grid component threw range error.
* Visual Editor: Fixed issue where **Settings** window did not close after clicking on **Save**.
* Visual Editor: Fixed issue where Tab index wasn't working properly in Property Editor.

## Moonshine IDE [1.12.0]

### Added
* New type of basic Visual Editor project which allows you to build [PrimeFaces](https://www.primefaces.org/) application mockups and export them as web applications.
* Editor: **Go To Line** feature.  The shortcut is CTRL+L for Windows and CMD+L for macOS.
* Project Tree: File **Duplicate** option in context menu.

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.11.1](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.11.1).
* Improved project deletion prompt.

### Fixed
* Fixed issue where newly created project template could not be renamed.
* New File: Fixed issue where in new file popup errors were duplicated. 
* New Project: Fixed issue where new project creation failed silently under some conditions on macOS.
* Settings: Library paths will be written to library-path instead of external-library-path

## Moonshine IDE [1.11.0]

### Added
* Integrated [Away Builder](http://awaytools.com/awaybuilder/) editor.

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.10.0](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.10.0).
* Royale: Changed default project name during project creation from `NewRoyaleBrowserProject` to `NewJavaScriptBrowserProject`.
* Setup `requestedDisplayResolution` to `high` to avoid issues in Windows for high DPI screens.
* Global Search:  Updated shortcuts to CTRL-SHIFT-F (Windows) and CMD-SHIFT-F (macOS)
* Global Search:  Added editor highlighting for matches

### Fixed
* Fixed issue where cursor flashed for editor and console at the same time.
* Language server: Fixed issue where +configname was not pass properly to language server for a library build.
* Fixed issue with opening binary files from the project tree
* Settings: Fixed issue where ANE settings were lost after IDE restart.
* Code Completion: Fixed issue where some style attributes does not show up in the list.
* Apache Flex Installer: Fixed issue where downloading OSMF failed.
* Local Search: Fixed issue where order of search results was incorrect.

### Known Issues
* Away Builder Editor tab can not be closed.  This is necessary for now until we find a way to reinitialize the tab
* Renaming a newly created project template is not working


## Moonshine IDE [1.10.0]

### Added
* Global Search: Display matched lines in the search results.
* Global Search: Highlight the matched string and line when opening a search result
* Added Edit > Organize Imports to organize import statements (Windows: CTRL+SHIFT+O, Mac: CMD+SHIFT+O)

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.9.1](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.9.1).
* New Project:  Added further clarification about location of project created from existing source code.
* Global Search:  Select the target project from a drop-down list.
* Changed name of confirmation button in new file popup from **Change** to **Create*.

### Fixed
* Code completion:  Now ignores the case of the entered text.
* Library Project: Fixed issue where adding new MXML file was disabled.
* Library Project: Fixed issue where compilation failed for Flex library projects after adding an MXML file.
* Library Project: Fixed issue where user could not create library projects from existing sources.
* Project Settings: Fixed issue where **Define it now** did not work in **Custom SDK** section.
* Project Tree: Fixed issue where source icon disappeared once root folder was refreshed.
* Project Tree: Fixed issue where IDE threw IOError on child files after renaming parent folder
* Home Tab: Fixed issue where deleted project was not removed from "Recent" opened project section.
* Settings: Fixed issue where **Reset to Default** did not remove one SDK from the list.
* Fixed issue where user could not change platform type after importing project from FlashDevelop.


## Moonshine IDE [1.9.0]

### Added
* Full support for Apache Royale.
* Support for AS3 library project creation.
* Find Resources: Added filtering options based on files extention.
* Code Completion List: Added signature method/properties and returned type information.
* Code Editor: Added brackets for functions choosen from completion list.
* Visual Editor: Added resize ability to property editor.

### Changed
* Updated [NexGenActionscript](https://nextgenactionscript.com/) engine to version [0.9.0](https://github.com/BowlerHatLLC/vscode-nextgenas/releases/tag/v0.9.0).
* Console: Colorize console output. Success, Warning and Error messages are now colored.
* Console: Improvement to the notification about cleaned project files.
* Visual Editor: Synchronize selection between property editor and list type of components Drop Down List, List.
* Project Creation: Prevent from creating project in existing project directory.
* Creation of files has been restricted to source folder only.
* Project Tree: Added new icon indicated source folder.

### Fixed
* Visual Editor: Fixed issue where pressing Tab in property editor was not work properly.
* Visual Editor: Fixed issue where the same editor opened multiple times.
* Console: Fixed issue where cursor flashes in console without focus.
* Code Editor: Fixed auto-completion for functions within XML attributes
* Fixed issue where a Flex application failed to launch with "Build & Run" when there were compiler warnings.
* Fixed issue where building Royale application to SWF wasn't working without setup SDK in the settings of the project.
* Fixed issue where tree selection and scroll bar position were reset after project build or deleting a file or folder.
* Fixed issue where FlexJS template was used when creating an MXML file in a Royale project
* Fixed issue where code completion did not work on a line with URL namespaces.
* Fixed issue where a null pointer exception triggered for Royale code marked as COMPILE::JS.
* Settings: Fixed issue with unresponsive scrollbar.
* Fixed issue where where the application file opened twice after deleting and recreating a project.
* Fixed issue where compilation failed for a Apache Royale express-only application


## Moonshine IDE [1.8.0]

### Added
* Reopen previously opened projects on startup. This behavior can be disabled from the General tab in the application settings.
* Added "Confirm Exit" popup to prompt user before exiting. This feature is disabled by default, but can be enabled in the General tab in the application settings.
* Problems view: Added option to copy the contents of a cell to the system clipboard.
* Projects tree: Added option "Select open file" in the header of projects tree.  This will show the file from the current tab in the project tree
* Projects tree: Added option "Copy path" to context menu in project tree.
* Projects tree: Added option "Show in Explorer/Finder" to context menu in project tree.
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
* Sidebar position no longer resets after build.

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
