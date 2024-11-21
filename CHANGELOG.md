# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) 

## Moonshine IDE [3.4.0]

### Summary

We've introduced convenient links to access our new discussion platform on Topicbox, as well as a direct link to our latest project, Moonshine.dev, where you can explore our work and stay updated on new developments.

### Added
* Moonshine.dev Link and Promotion ([#1254](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1254))
* Topicbox Integration ([#1237](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1237))
* [Domino Visual Editor] Interface Similar to "Objects" from Domino Designer ([#1009](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1009))
* LotusScript Compilation and Validation ([#1234](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1234))

## Moonshine IDE [3.3.4]

### Summary

Key features for the 3.3.4 release:
* JDK 17 support.  JDK 17 is now the default JDK for Moonshine, except for Domino projects
* Improvements to workspaces.  
    * Switch workspaces from the project sidebar.  
    * Manage workspaces from Settings > Workspaces.
    * Automatically create new workspaces when opening a repository or multiple projects
* Added View editor in Domino Visual Editor. Includes support for Shared Columns.
* Open Terminal to selected directory in Project sidebar
* Updated license to [Server Side Public License](https://www.mongodb.com/licensing/server-side-public-license)

### Added

* Control to switch workspaces form the project sidebar. ([#1131](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1131))
* Manage workspaces from Settings > Workspaces ([#1132](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1132))
* When opening multiple projects at once, give an option to select the workspace where the projects will be opened ([#1136](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1136))
* Domino Visual Editor: View Support ([#1016](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1016))
* Domino Visual Editor: View Column Properties ([#1017](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1017))
* Open folders in Terminal from the right-click menu ([#1038](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1038))
* macOS: Support for M1/ARM64 architecture ([#1162](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1162))
* Import documents into your database from a JSON file ([#1171](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1171))
* Use Home and End to move to the beginning and end of the line, and CTRL+Home and CTRL+End to jump to the beginning or end of the file ([#1225](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1225))
* Expand/restore editor tab with double-Click ([#1224](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1224))
* Warning for duplicate names for Forms and Views ([#1220](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1220))
* Option to convert a column in a view to a shared column: ([#1219](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1219))
* Automatically detect new Vagrant instances created in Super.Human.Installer ([#1217](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1217))
* Domino Visual Editor; Shared Column Support ([#1216](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1216))
* Domino Visual Editor; Design Properties for Forms and Views ([#1214](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1214))
* Tibbo Basic Support ([#1211](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1211))
* Domino Visual Editor: Export converted Royale project to external application ([#1148](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1148))
* Open Genesis Directory Project in Workspace ([#1137](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1137))
* Domino to Royale: Toggle Edit Mode in generated Royale forms ([#1110](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1110))

### Changed

* Update Moonshine license to [Server Side Public License](https://www.mongodb.com/licensing/server-side-public-license) ([#577](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/577))
* JDK 17+ support ([#1124](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1124))
* Java Haxe Updates to support JDK 17 ([#1168](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1168))
* Maven Updates to support JDK 17 ([#1167](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1167))
* Gradle Updates to support JDK 17+ ([#1166](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1166))
* Language Server: Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.19.0.
* Language Server: Updated [Haxe](https://github.com/vshaxe/haxe-language-server) engine to v2.28.0.
* Language Server: Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v1.29.0.
* Updated default paths for external editors ([#1154](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1154))
* Changes to make Form Builder projects more portable ([#1142](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1142)) 
* Improved prompt that triggers when build file is modified ([#1026](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1026))
* Add DominoVagrant/demo To default Repository List ([#1104](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1104))
* Refactor `AS3ProjectPlugin canCreateProject()` to make it easier to support new languages ([#1164](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1164))
* Added .hxproj to the file association list ([#1172](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1172))
* Can now edit URL in Deploy to Vagrant Server popup (Royale) ([#1242](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1242))
* Improvements for width of workspace dropdown in project sidebar ([#1239](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1239))
* Added path context for Recent Files ([#1231](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1231))
* Replace console text-view with moonshine-feathersui-text-editor ([#1229](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1229))
* Fixed clipboard paste for default value property ([#1226](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1226))
* Domino Visual Editor: Allow nested view names ([#1213](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1213))
* Updated Moonshine-Domino-CRUD Template to 0.7.0, which includes improvements to make agents easier to maintain ([#1193](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1193))
* Form Builder: Populate default Form and View name ([#1158](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1158))
* Form Builder: Make projects more portable ([#1142](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1142))
* Internal: Support for Haxe libraries that need to be compiled from source ([#1113](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1113))
* Started converting some interfaces to Haxe ([#1102](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1102))
* Convert "About" view to Haxe ([#1024](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1024))
* Domino Visual Editor: Copy/Paste support ([#1032](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1032))

### Fixed

* Fixed "Java language server exited unexpectedly" Error on macOS Monterey ([#1120](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1120))
* Proper resizing for buttons in generated Royale interface ([#1128](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1128))
* Report an error if no main application file exists when compiling a Royale project ([#1151](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1151))
* Fixed resizing issues for the About page ([#1153](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1153))
* About page now shows "Grant permission" for Git if permission was not granted on macOS ([#1155](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1155))
* Debug breakpoint not displaying properly ([#1170](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1170))
* Strip spaces and special characters in form names when generating Java and Royale code ([#1071](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1071))
* Fixed errors when using Vagrant instance from Windows:  ([#1249](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1249))
* Java Gradle project does not open on startup - JavaImporter$parse() error ([#1123](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1123))
* Fixed handling of forward and backward slashes in view names for generated Java agents ([#1134](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1134))
* Projects not reopened properly after switching workspace ([#1135](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1135))
* Fixed ReferenceError when scrolling Getting Started page ([#1112](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1112))
* Fixed Error #2007 on application startup ([#1152](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1152))
* Errors when switching focus for Text Editors ([#1248](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1248))
* Generated Apache Royale CRUD project used 127.0.0.1 for base URL ([#1243](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1243))
* "Reset to Default" did not clear Recently Opened list ([#1232](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1232))
* Duplicate entries in "Recent Projects" and "Home page" ([#1230](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1230))
* Domino Visual Editor:  Default value not populated for some field types ([#1223](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1223))
* Accordion/focusInHandler() Error In Form and View editor ([#1222](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1222))
* Selection discrepancy for column delete ([#1221](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1221))
* $TITLE not updated properly after Form rename ([#1218](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1218))
* Code completion stopped working for Haxe project after switching between tabs ([#1212](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1212))
* Fixed macOS shortcuts for switching tabs ([#1207](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1207))
* Fixed parsing logic for Flash Player version ([#1205](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1205))
* Domino Visual Editor: Remove obsolete Div component ([#1198](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1198))
* Domino Visual Editor: Sidebar alignment issue for Page editor ([#1194](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1194))
* Domino Visual Editor:  Invalid default value for $WindowTitle ([#1189](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1189))
* Support Vagrant instance URLs used by Super.Human.Installer servers ([#1186](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1186))
* Fixed .xml_conversion_required logic ([#1181](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1181))
* Get rid of "ln" (link) warnings in Console ([#1157](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1157))
* Domino to Royale:  Updated Royale containers to take into account direction provided by intermediate XML ([#1133](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1133))
* Domino to Royale: Fixed Royale Column values which were displayed as "[Object]" ([#1122](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1122))
* Domino to Royale: Switching between views when one is in edit mode does not reset them ([#1119](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1119))
* Project > Recent Actions did not open Project or File ([#1115](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1115))
* Reduced delay for Vagrant instance dropdown ([#1111](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1111))
* Fixed TypeError in application menus ([#1109](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1109))
* Select/Deselect All broken in multi-project prompt ([#1108](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1108))
* Domino to Royale: Miscellanous fixes after practical test ([#1106](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1106))
* Domino to Royale: Default name for generated project. ([#1101](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1101))
* Debugging Openfl/Feathers application with "mac" target throws error ([#1094](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1094))
* Moonshine-IDE not properly saving SVN credentials ([#1043](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1043))
* File associations broken on Windows ([#800](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/800))


## Moonshine IDE [3.3.3]

### Summary

* Quickly import projects from https://genesis.directory/ with `Project > Import Genesis Directory Catalog Project`
* Generate Java Domino agents and import scripts for Form Builder and Domino Visual Editor projects
* Generate Apache Royale applications for Form Builder and Domino Visual Editor projects.  These will call the generated agents to access the Domino database
* Added actions to interact with Vagrant VM with REST to perform Domino actions (deploy database, deploy agents, etc.)
* Additional features in Domino Visual Editor, including additional field properties and subforms.


### Added

* Import Genesis Directory Catalog Project ([#1089](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1089))
* Generate Java Agents for Domino Visual Editor ([#1072](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1072)) and Form Builder ([#978](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/978))
* Generated Royale Application Using Java Agents For Domino Visual Editor ([#1074](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1074), [#675](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/675)) and Form Builder ([#1040](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1040))
* Deploy Royale Application to Vagrant Instance ([#1080](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1080))
* Deploy Database to Vagrant Domino Server ([#1077](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1077))
* Option to Build NSFODP Projects in Vagrant VM ([#1007](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1007))
* Convert a Domino Database to Domino Visual Editor with `Others > Convert Domino Database` ([#979](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/979)) (Required Vagrant VM is not yet released)
* Importing Generated Java Agents to Domino Database on Vagrant ([#1062](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1062))
* Generate Minimal View for Domino Visual Editor Agents ([#1073](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1073))
* Domino Visual Editor: Paragraph Alignment Options ([#1055](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1055))
* Domino Visual Editor:  Initial Subform Support ([#1015](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1015))
* Domino Visual Editor: Support More Hide Options ([#1001](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1001))
* Added a Button to Open Directory by Path ([#914](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/914))
* Add a Generic Project Template ([#700](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/700))

### Changed

* Language Server: Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.13.0.
* Language Server: Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v1.15.0.
* Language Server: Updated [Haxe](https://github.com/vshaxe/haxe-language-server) engine to v2.25.0.
* Streamline Process To Distinguis Between App-Store And Non-App-Store Builds ([#1081](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1081))
* Improved Formatting for Error Messages in ([#1045](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1045))
* Sort Manage Repository > Browse Entries ([#1044](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1044))
* Updates for DominoParagraph in Domino Visual Editor ([#1041](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1041))
* Accordian Menu for Field Properties ([#1031](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1031))
* Domino Visual Editor: Add Additional Field Properties ([#1008](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1008))
* Short-Term Improvements for Monitoring Language Server Instances ([#994](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/994))
* Additional External Editors to "Open With" Menu ([#993](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/993))

### Fixed

* Haxe/Openfl Project Failed to Re-Build Following A Compilation Error ([#1093](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1093))
* Implemented `Project > Clean` for Domino Visual Editor and Domino On Disk Project ([#1090](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1090))
* Parse Error When Opening Domino On Disk Project ([#1084](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1084))
* Getting Started Download Link Opens Broken Page ([#1076](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1076))
* Royale Compilation Breaks When Output Path Has Space ([#1075](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1075))
* Problem with crosspromotion.swc for Harman AIR build ([#1068](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1068))
* Rename Bug for Domino Visual Editor ([#1067](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1067))
* Getting Java version is failing with path which contains '(' or ')' ([#1066](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1066))
* Domino Visual Editor: Help and Hint Properties Broken ([#1056](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1056))
* Variables Entries in Debug are Unselectable  ([#1054](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1054))
* Ant Build Did Not Fail on Apple Signing Command Errors ([#1052](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1052))
* Sidebar Navigator UI Corruption ([#1046](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1046))
* Fix Grails Version Format ([#1037](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1037))
* Ant Errors for Flex Desktop Template ([#1034](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1034))
* Inconsistent Newline Behavior in Converted Domino Database ([#1033](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1033))
* Opening AS3 class in editor throws exception - Error #3218 ([#1087](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1087))
* Occasional File Sorting Problem in Sidebar After File System Watcher Events ([#1029](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1029))
* Duplicate Extensions in Recent Files ([#1027](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1027))
* Domino Visual Editor: Error on Intermediate XML Conversion ([#1023](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1023))
* Domino Visual Editor: Cannot Select Components in Reopened Form ([#1022](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1022))
* New Workspace Does Not Show Up in Workspace List ([#1021](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1021))
* Sidebar Display Time Has Slowed During Moonshine Start ([#1002](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1002))
* Could Not Save Subversion Credentials ([#928](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/928))
* Windows: Compilation Fails for Royale Project when Apache Royale SDK Path Contains Whitespace ([#741](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/741))
* Error #3218 While Writing Data to NativeProcess.standardInput. ([#492](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/492))


## Moonshine IDE [3.3.2]

### Summary

This release is mainly focused on adding more support for Domino applications. 

Key Updates:
* Added simple Java Domino project template
* Generate a basic Royale application with Domino On Disk Project.  More updates are planned for this.
* Create pages in Domino Visual Editor
* Miscellanous bug fixes and improvements

### Added

* Domino simple Java Domino project template ([#903](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/903))
* Domino On Disk Project: Generate a basic Royale application ([#704](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/704))
* Visual Editor: Page Mockup Editor ([#905](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/905))
* NSD Kill for Domino Projects ([#989](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/989))
* Add a "Copy to Clipboard" Button On About Dialog ([#981](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/981))

### Changed

* Language Server: Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.11.1.
* Language Server: Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v1.9.0.
* Debug Adapter: Updated [SWF](https://as3mxml.com) engine to v1.5.0.
* Updated timestamp server for installer ([#1000](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1000))
* Editor:  Opening a File Throws TypeError ([#997](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/997))
* Open "Known" Binary Files Without Prompt ([#996](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/996))
* Enabled CSS, XML and File in New File Options for all projects ([#995](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/995))
* Enabled Java and Groovy in New File Options for NSFODP projects ([#995](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/995))
* Added more information to About page ([#991](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/991))
* Added Warning for NSFODP "Compiling ODP" Hang ([#987](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/987))
* Update nsfodp-maven-plugin to 3.8.1 to handle updated macOS application structure ([#985](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/985))
* On Disk Project:  Added instructions for macOS Security ([#980](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/980))
* Added more suported character for Haxe library paths ([#975](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/975))
* Visual Editor:  Enabled Find/Replace ([#972](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/972))
* Visual Editor:  Automate conversion of intermediate XML files ([#968](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/968))
* Visual Editor:  Fixed default location for new Forms or Pages ([#926](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/926))

### Fixed

* Error #3500 on Moonshine close for macOS Monterey ([#998](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/998))
* Error when creating DXL files in Domino On Disk Project ([#982](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/982))



## Moonshine IDE [3.3.1]

### Summary

The main updates for Moonshine-IDE 3.3.1 are:
* Basic Vagrant support.  Right-click on the Vagrant file to run different Vagrant commands from Moonshine
* Updated debugging interface
* Fixed bugs with GitHub integration, especially for macOS.

### Added
* Vagrant Support ([#770](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/770))
* Directory Assistance Repository for Public GitHub Examples ([#958](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/958))
* MacPorts Reference Entry on Getting Started page.  This is not installed by Moonshine SDK Installer yet ([#921](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/921))


### Changed
* Improved debugger based on Haxe ([#961](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/961))
* Updated [Groovy language server](https://github.com/GroovyLanguageServer/groovy-language-server) engine to latest.
* Define environment for Haxe and Neko from Moonshine ([#967](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/967))


### Fixed
* Groovy Language Server - Fixed bug where core Java classes were not detected for completion ([groovy-language-server#63](https://github.com/GroovyLanguageServer/groovy-language-server/issues/63))
* Git Integration on macOS ([#965](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/965))
* Git integration on Windows ([#969](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/969))
* Null pointer exception in TreeView ([#964](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/964))
* TreeViewItemRenderer Error with feathersui 1.0.0-beta.8 ([#959](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/959))
* File Ordering Incorrect After FileWatcher Update ([#955](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/955))


## Moonshine IDE [3.3.0]

### Summary

The main features of Moonshine 3.3.0 are:
* Project sidebar will be updated automatically to match filesystem changes
* If there is a Moonshine update, Moonshine will not open projects and start language servers unless the user cancels the update prompt.  This resolved performance issues and some cases with hanging Java language servers.
* Fixes for new Code Editor
* Updates to language servers and debug adapters
* Miscellanous bug fixes and improvments.

### Added

* Project trees will now be updated automatically when the filesystem is updated.  ([#948](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/948))
* Added External Editor support for [Atom](https://atom.io/), [CodeRunner](https://coderunnerapp.com/), and [Komodo Edit](https://www.activestate.com/products/komodo-edit/).  ([#919](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/919))
* About: Added OS name and version information. ([#944](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/944))
* Added "Close Others" context-menu action in tabs ([#610](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/610))

### Changed

* Will not open projects and start language servers while prompting the user for an update ([#923](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/923))
* Update notification window size updated. ([#909](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/909))
* Version information on About page is now selectable for easy copying ([#954](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/954))
* Problems tab will open on startup by default. ([#946](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/946))
* Updated initial text on console. ([#912](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/912))
* Rename **Domino** tab to **Domino and Notes Client** in application settings. ([#915](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/915))
* Finished updating Moonshine to use system default font. ([#873](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/873))
* Language Server: Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.10.0.
* Language Server: Updated [Haxe](https://github.com/vshaxe/haxe-language-server) engine to latest version.
* Language Server: Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v1.6.0.
* Language Server: [Support](https://github.com/GroovyLanguageServer/groovy-language-server/issues/47) for Groovy 4.0
* Debug Adapter: Updated [SWF](https://as3mxml.com) engine to v1.4.0.
* Debug Adapter: Updated [Chrome](https://github.com/microsoft/vscode-chrome-debug) engine to v4.13.0.
* Debug Adapter: Updated [Firefox](https://github.com/firefox-devtools/vscode-firefox-debug) engine to v2.9.5.

### Fixed

* Code Editor: Fixed issue where code completion did not filter properly for text already typed. ([#6](https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor/issues/6))
* Code Editor: Fixed issue where cursor jumps to import section when new import is added. ([#5](https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor/issues/5))
* Code Editor: Fixed exception when Clean Up Import is used by shortcut `Command/Control + Shift + I`. ([#4](https://github.com/Moonshine-IDE/moonshine-feathersui-text-editor/issues/4))
* Populated default Parent Directory for Git Clone and SVN Checkout prompts. ([#920](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/920))
* Fixed issue where Moonshine closes when user cancels an update. ([#951](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/951))
* Fixed issue where code editor goes blank after closing other tabs. ([#942](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/942))
* Fixed issue where sidebar showed strikethrough for some project names. ([#943](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/943))
* : Fixed issue where running Ant script triggers prompt to setup Flex Home path. ([#938](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/938))
* Fixed issue where tab did not show as edited after find/replace or typing. ([#939](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/939))
* Fixed issue where prompt about file changes in `build.gradle` or `pom.xml` file locked Moonshine. ([#936](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/936))
* Gradle: Fixed dependencies to allow work with Gradle 7. ([#935](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/937))
* Fixed issue where Ant build did not work with Java 8. ([#933](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/933))
* Fixed issue where sidebar section like **Tour De Flex** or **Useful Links** can be opened more than once.  Trying to open a section again will close the section ([#922](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/922))
* Fixed bug where `Git > Grant Permission` opened Manage Repositories window instead of permission prompt ([#749](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/749))
* Path in New File dialog will now use '/' separators instead of '.' ([#945](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/945))
* Fixed bug where Ant script terminated early and cut off output. ([#932](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/932))
* Fixed default path for Emacs External editor. ([#917](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/917))

## Moonshine IDE [3.2.0]

### Summary

Moonshine 3.2.0 includes:
* An improved text editor based on Haxe
* Many minor updates and bug fixeds

There were also some updates for installers and updates:
- Moonshine-IDE can be installed with [Chocolatey](https://community.chocolatey.org/packages/moonshine-ide).
- Nightly builds were renamed to MoonshineDevelopment, and will now automatically update on restart if new builds are available.

### Added

* [Chocolatey package](https://community.chocolatey.org/packages/moonshine-ide) is now available ([#747](https://github.com/prominic/Moonshine-IDE/issues/747))

### Changed

* Improved text editor based on Haxe ([#904](https://github.com/prominic/Moonshine-IDE/issues/904))
* Moonshine-IDE repository moved to Moonshine-IDE organization.  Updated default repository paths in Manage Repositories ([#865](https://github.com/prominic/Moonshine-IDE/issues/865))
* Separated auto-update configuration for Non-Sandbox, App Store, and Windows builds ([#836](https://github.com/prominic/Moonshine-IDE/issues/836))
- Setup auto-updates for nightly builds ([#899](https://github.com/prominic/Moonshine-IDE/issues/899))
* Supported creation of untracked files in Git Status window ([#889](https://github.com/prominic/Moonshine-IDE/issues/889))
* Updated Getting Started behavior for Subversion/SVN ([#849](https://github.com/prominic/Moonshine-IDE/issues/849))
* Continued development on Domino Visual Editor ([#812](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/812))
* Removed NoteInfo from NSFODP Templates ([#853](https://github.com/prominic/Moonshine-IDE/issues/853))
* Removed dependency on global settings.xml for Domino Visual Editor ([#835](https://github.com/prominic/Moonshine-IDE/issues/835))
* Migrated Getting Started page to haxe ([#782](https://github.com/prominic/Moonshine-IDE/issues/782), [#863](https://github.com/prominic/Moonshine-IDE/issues/863))
- Produce a single merged SWC for Moonshine Haxe libraries ([#875](https://github.com/prominic/Moonshine-IDE/issues/875))
- Reorganized Templates interface to separate files and projects ([#852](https://github.com/prominic/Moonshine-IDE/issues/852))
- Rename `File > Moonshine Helper Application` to `File > Launch Moonshine SDK Installer` ([#859](https://github.com/prominic/Moonshine-IDE/issues/859))
- Added credits for NSF ODP Tooling in `Settings > Domino` ([#857](https://github.com/prominic/Moonshine-IDE/issues/857))
- Build Moonshine with Harman AIR 33.1.1.633 to avoid keybinding issues ([#907](https://github.com/prominic/Moonshine-IDE/issues/907))

### Fixed
* User-selected JDK was reset on Moonshine restart ([#866](https://github.com/Moonshine-IDE/Moonshine-IDE/issues/866))
* Default Flex SDK reset to default after Moonshine restart ([#884](https://github.com/prominic/Moonshine-IDE/issues/884))
* Git clone failed in App Store build ([#892](https://github.com/prominic/Moonshine-IDE/issues/892))
* Error #1009 on About page ([#861](https://github.com/prominic/Moonshine-IDE/issues/861))
* Invalid Royale project initialization ([#778](https://github.com/prominic/Moonshine-IDE/issues/778))
* Problems with file extension selection in Project Search ([#891](https://github.com/prominic/Moonshine-IDE/issues/891))
* Ctrl + Shift + Tab threw error with 0 or 1 open tabs ([#888](https://github.com/prominic/Moonshine-IDE/issues/888))
* Could not open Java project from .javaproj file if name did not match directory ([#883](https://github.com/prominic/Moonshine-IDE/issues/883))
* Domino Visual Editor project failed if JDK 11 is missing ([#871](https://github.com/prominic/Moonshine-IDE/issues/871))
* Application namespace was not updated automaticaly for Flex Desktop projects ([#869](https://github.com/prominic/Moonshine-IDE/issues/869))
* Open/save problems for multiple open Visual Editor projects ([#833](https://github.com/prominic/Moonshine-IDE/issues/833))
* Problems for Browse All button in Manage Repositories([#867](https://github.com/prominic/Moonshine-IDE/issues/867))
* Default generated form fails in On Disk Project ([#872](https://github.com/prominic/Moonshine-IDE/issues/872))
* Getting Started failed to open automatically ([#844](https://github.com/prominic/Moonshine-IDE/issues/844))
* Unexpected projects opening on Moonshine restart ([#864](https://github.com/prominic/Moonshine-IDE/issues/864))
* getStartupInfo Error on Flex Desktop Build & Run ([#841](https://github.com/prominic/Moonshine-IDE/issues/841))
* File chooser failed for Flex project Settings page ([#839](https://github.com/prominic/Moonshine-IDE/issues/839))
* Switched File API calls to go through Bookmark extension for App Store support ([#860](https://github.com/prominic/Moonshine-IDE/issues/860))
* Duplicated "Template Type" during ActionScript project import ([#902](https://github.com/prominic/Moonshine-IDE/issues/902))
* Imports failed for Java Maven projects ([#900](https://github.com/prominic/Moonshine-IDE/issues/900))


## Moonshine IDE [3.1.1]

### Summary

Moonshine 3.1.1 is a quick-fix release for an error with Apache Maven builds.

### Added

### Changed

### Fixed

* Fixed error with build for Java Maven projects ([#834](https://github.com/prominic/Moonshine-IDE/issues/837))
* Fixed error with build for Domino Visual Editor projects ([#834](https://github.com/prominic/Moonshine-IDE/issues/834))


## Moonshine IDE [3.1.0]

### Summary

Moonshine 3.1.0 includes:
* Quickly switch between sets of projects using the improved workspace support
* Better performance for opening large projects.
* Create HCL Domino forms from a Visual Editor mockup, or generate a form by defining a list of fields.
* Default JDK updated to OpenJDK v11.0.10.  OpenJDK 8 is still supported.

### Added
* Domino Visual Editor:  Use a Visual Editor mockup to create HCL Domino forms.   This is based on the [ODP Compiler](https://frostillic.us/blog/posts/2019/7/8/f9643d0349dfd211852584310054b892)  ([#646](https://github.com/prominic/Moonshine-IDE/issues/646))
* Domino On Disk Project:  Generate HCL Domino forms by defining a list of fields.   This is based on the [ODP Compiler](https://frostillic.us/blog/posts/2019/7/8/f9643d0349dfd211852584310054b892)  ([#670](https://github.com/prominic/Moonshine-IDE/issues/670))
* Domino On Disk Project:  Automatically generate an update site to support On Disk Project.  Only available for macOS.  ([#689](https://github.com/prominic/Moonshine-IDE/issues/689))
* Java JDK: Updated default OpenJDK to v11.0.10 to support the latest language server. ([#755](https://github.com/prominic/Moonshine-IDE/issues/755))
* Java JDK: Added additional OpenJDK 8 SDK for projects that still require JDK 8 (including HCL Domino projects). ([#755](https://github.com/prominic/Moonshine-IDE/issues/755))

### Changed

* Workspace: Create and manage project workspaces from the File > Workspace menu. ([#416](https://github.com/prominic/Moonshine-IDE/issues/416))
* Improved performance when launching large projects ([#756](https://github.com/prominic/Moonshine-IDE/issues/756))
* New Folder:  Create multiple folders at once by separating the folders with '/' ([#468](https://github.com/prominic/Moonshine-IDE/issues/468))
* Find Symbol: General improvements to filter and search functionality. ([#724](https://github.com/prominic/Moonshine-IDE/issues/724))
* Git and SVN: Improved validation for the Clone Repository target path ([#750](https://github.com/prominic/Moonshine-IDE/issues/750))
* Git: Added validation for new branch name ([#751](https://github.com/prominic/Moonshine-IDE/issues/751))
* Git: List local and remote branches separately. ([#754](https://github.com/prominic/Moonshine-IDE/issues/754))
* Haxe Migration: Updated **Find Resources** window to allow navigation with the arrow keys. ([#771](https://github.com/prominic/Moonshine-IDE/issues/771))
* Moonshine source code: Switched from Adobe AIR to Harman AIR. ([#773](https://github.com/prominic/Moonshine-IDE/issues/773))
* Haxe Migration: Converted **Load Workspace** view to Haxe. ([#775](https://github.com/prominic/Moonshine-IDE/issues/775))
* Haxe Migration: Converted **Search** view to Haxe. ([#798](https://github.com/prominic/Moonshine-IDE/issues/798))
* Haxe Migration: Converted **New Workspace** view to Haxe. ([#779](https://github.com/prominic/Moonshine-IDE/issues/779))
* Language Server:  Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.6.0.
* Language Server:  Updated [Haxe](https://github.com/vshaxe/haxe-language-server) engine to latest version.
* Language Server:  Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v0.69.0.
* Debugging:  Updated [Chrome debug](https://github.com/microsoft/vscode-chrome-debug) engine to v4.12.12.
* Debugging:  Updated [Firefox debug](https://github.com/firefox-devtools/vscode-firefox-debug) engine to v2.9.1.
* You may customize the SDK label when adding a Flex or Royale SDK. ([#767](https://github.com/prominic/Moonshine-IDE/issues/767))

### Fixed
* Windows: Fixed file association Windows Moonshine ([#800](https://github.com/prominic/Moonshine-IDE/issues/800))
* Git: Branches will not be pushed to remote by default ([#754](https://github.com/prominic/Moonshine-IDE/issues/754))
* Git: Fixed issue with authentication prompt on macOS. ([#617](https://github.com/prominic/Moonshine-IDE/issues/617))
* Language server:  Fixed issue where Java project used wrong language server for superclass and interface completion. ([#742](https://github.com/prominic/Moonshine-IDE/issues/742))
* Git: Fixed broken Pull action. ([#758](https://github.com/prominic/Moonshine-IDE/issues/758))
* Haxe: Fixed issue where code completion was closing immediately. ([#772](https://github.com/prominic/Moonshine-IDE/issues/772))
* Haxe: Fixed issue where code completion did not insert the correct text. ([#776](https://github.com/prominic/Moonshine-IDE/issues/776))
* Fixed "Local environment setup failed" error ([#785](https://github.com/prominic/Moonshine-IDE/issues/785))
* Fixed issue where previously opened projects did not open after a Moonshine restart. ([#786](https://github.com/prominic/Moonshine-IDE/issues/786))
* Java Gradle: Fixed bug which prevented users from creating new Java classes. ([#805](https://github.com/prominic/Moonshine-IDE/issues/805))
* Java: Fixed display of source directory icon. ([#814](https://github.com/prominic/Moonshine-IDE/issues/814))
* Getting Started: Fixed issue where SDKs installed by Moonshine SDK Installer were not automatically detected on Windows. ([#817](https://github.com/prominic/Moonshine-IDE/issues/817))
* About page: Fixed issue where Grails version displayed error. ([#818](https://github.com/prominic/Moonshine-IDE/issues/818))
* macOS: Display build number in About page. ([#824](https://github.com/prominic/Moonshine-IDE/issues/824))
* macOS: Fixed issue where About page showed "App Store" for Non-Sandbox build ([#816](https://github.com/prominic/Moonshine-IDE/issues/816))

## Moonshine IDE [3.0.0]

### Summary

Moonshine 3.0.0 includes:
* Support for Actionscript Mobile projects and Flex Modules
* Debugging improvements for mobile and Haxe projects
* Miscellaneous bug fixes and quality-of-life improvements.

### Added
* Configure and build modules for Flex projects.
* Open files with external editors (ex. Notepad++, VIM etc.).
* Navigate between tabs using keyboard-shortcuts (CTRL+Tab, CTRL+Shift+Tab).
* Detect and configure NodeJS
* Detect and configure IBM/HCL Notes.
* Debug mobile projects using USB or Wi-Fi.
* Debug Haxe projects
* Create ActionScript Mobile Projects.
* Choose between Chrome and Firefox when debugging Apache Royale and OpenFL projects targeting HTML/JS.
* Debug OpenFL projects targeting native Windows, macOS, and Linux with the HXCPP debugger.
* Debug OpenFL projects targeting HashLink (Windows).

### Changed
* Windows: Switched from the native AIR installer to NSIS to reduce installation times
* Windows: Changed Moonshine to a 64-bit application.  You will be prompted to uninstall your old copy of Moonshine, but your settings will be saved.
* Updated application to use new icon new icon
* Updated [ActionScript & MXML](https://as3mxml.com) engine to v1.2.2.
* Updated [Haxe](https://github.com/vshaxe/haxe-language-server) engine to latest version.
* Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v0.59.0.
* Updated [SWF debug](https://as3mxml.com) engine to v1.2.2.
* Updated [Chrome debug](https://github.com/microsoft/vscode-chrome-debug) engine to v4.12.10.
* Updated [Firefox debug](https://github.com/firefox-devtools/vscode-firefox-debug) engine to v2.9.0.

### Fixed
* Fixed macOS shortcuts for **Build & Run**
* Fixed issue where project build failed if source files were placed in the root folder.
* Fixed issue where project files and folders were not sorted alphabetically. 
* MacOS: Fixed issue where menu options were not sorted alphabetically.
* Fixed issue where projects could not be reopened from the File > Recent Projects menu if the Home tab was closed
* MacOS: Fixed issue where closing an editor using the shortcut **CMD+W** triggered an exception.
* MacOS: Fixed issue where Moonshine could not clone a private Git repository
* Fixed issue where button **Step Over** did not work during Debugging.
* Fixed issue where code completion stopped working when tab was moved into the hamburger menu.
* Fixed duplicate mappings for **CTRL+F** shortcut.  Find references has been updated to CMD+Shift+F
* Fixed issue where right-click the file tree in the New File prompt triggered exceptions
* Fixed error when committing a sub-project under a Git repository.
* Fixed Error #3218 in the language-server output.
* Fixed issue when opened editors did not update their content when the file was updated externally (for example, by an svn update or git pull).
* Fixed issue where mobile Mobile stage dimensions did not update when changing the device model
* Fixed file modification warning for new Java files



## Moonshine IDE [2.6.0]

### Summary

Moonshine 2.6.0 has a couple new features for Apache Royale.  
- Generate a report for a Flex project to see what is needed to convert it to Apache Royale
- Quickly download the latest nightly build for Apache Royale
- Debug Apache Royale applications in Moonshine using the Chrome debug adapter.   

Some other changes:
- Additional support for Haxe
- Updates for some of the language servers
- Various bug fixes.

### Added
* Apache Royale browser projects support debugging when launched in Chrome.
* Generate a report to aid migration from Flex to Royale with Project > Apache Royale API Report.  See the [Apache Royale API](https://github.com/apache/royale-asjs/wiki/Generating-an-API-Report) page for more details.
* Added support for additional Haxe project types.
* Added new Haxe Feathers UI project type.
* Getting Started:  Download the current nightly build of Apache Royale with Moonshine SDK Installer

### Changed
* Updated [Groovy language server](https://github.com/prominic/groovy-langugage-server) engine to latest.
* Updated [ActionScript and MXML](https://as3mxml.com/) engine to v0.25.0.
* Updated [SWF debug adapter](https://as3mxml.com/) engine to v1.0.2.
* Updated [Chrome debug adapter](https://github.com/microsoft/vscode-chrome-debug) engine to v4.12.5.

### Fixed
* Royale: Fixed issue where resources were not copied to bin/js-release folder.
* Java: Fixed issue where changes to _pom.xml_ or _build.gradle_ were not properly reflected in code intelligence.
* Java: Fixed issue where the Windows Java path was not recognized by the Maven build.
* Project Sidebar: Fixed issue where project files/folders was not sorted alphabetically.
* Ant: Fixed issue where new Ant process request dismisses any running process output
* Ant: Fixed issue where notification not showing during Ant build start and end
* Ant: Fixed issue on Windows where running a Ant script triggers a 'The syntax of the command is incorrect' error.


## Moonshine IDE [2.5.0]

### Summary

Moonshine 2.5.0 adds some small features which improve development workflow, including the Outline View and Go To Implementation for interfaces. 

Additionally, Moonshine SDK Installer will now download Apache Royale 0.9.6 (JS-only version) and apply a patch fix for the broken royale-config.xml. More information can be found in the [this discussion](http://apache-royale-development.20373.n8.nabble.com/Broken-royale-config-in-JS-only-build-of-released-Apache-Royale-SDK-0-9-6-td12515.html) on the Royale development mailing list.

### Added
* Added USB device debugging on mobile for Adobe AIR.
* Added Go To Implementation for interfaces (but not interface methods, yet).
* Added Ctrl+Click on Flex SDK items parent classes.
* Added Outline View to show symbols in the current class
* Signature Help: Add buttons to see other overloaded signatures.
* Added basic OpenFL/Haxe project support.

### Changed
* Default Apache Royale SDK for Moonshine SDK Installer is now 0.9.6.  See notes above.
* Updated [ActionScript and MXML](https://as3mxml.com/) engine to v0.23.2.
* Updated [Java eclipse.jdt.ls](https://github.com/eclipse/eclipse.jdt.ls) engine to v0.43.0.

### Fixed
* No longer need to set Subversion binary in order to use Git in Windows.
* Fixed Error #3218 - Error while writing data to NativeProcess.standardInput.
* Fixed issue where Java method does not complete properly.
* Fixed issue where **Custom URL to Launch** for application launch was not used in **Build and Run as JavaScript**
* Fixed behavior with the Parent Directory field in the Checkout form.

## Moonshine IDE [2.4.0]

### Summary

Moonshine 2.4.0 adds some improvements for Grails, including project imports and menu actions to run Grails or Gradle commands.

Moonshine also now supports configuration of an Adobe AIR SDK in addition to the Flex, Feathers, and Royale SDKs.

### Added
* Added interface to run Grails and Gradle commands on Grails projects
* Added support for configuring the Adobe AIR SDK.
* Grails:  Automatically configure the standard classpath folders
* Grails:  Import Grails projects
* Java Gradle: Add basic settings interface. 

### Changed
* Remember last opened path for file chooser.
* Changed shortcut for Open File to CTRL+Shift+O (Windows), CMD+Shift+O (macOS).
* Changed shortcut for Open Project to CTRL+O (Windows), CMD+O (macOS).
* Changed shortcut for **Organize Imports** to CTRL+SHIFT+I (Windows), CMD+SHIFT+I (macOS).

### Fixed
* Fixed bug which broke compilation for Flex projects
* Fixed issue where the last character was ommitted from a text selection.
* Fixed issue where the macOS non-App Store build did not immediately configure the SDKs installed by Moonshine SDK Installer
* Fixed issue which prevented CTRL/CMD + click from working on method reference. 
* Miscellanous bugfixes and improvements to project dependencies interface
* Updated selection error for adding breakpoints to make it less likely to click it by accident.
* Removed obsolete "Exc exists" text from plugin descriptions
* Fixed issue where the language server reported an error when the project file for a Grails project did not match the project directory name
* Fixed error on Go To Definition and Go To Type Definition


## Moonshine IDE [2.3.0]

### Summary

Moonshine 2.3.0 now has support for Java Maven and Gradle projects.   You can import external Java projects, and Moonshine will use the existing pom.xml or build.gradle to build the project and determine the dependencies.

In addition, we added initial support for Grails projects. Currently you can create and run new projects, and the projects have limited language server support.  We will add more functionality in the next release.

### Added
* Import Java Gradle and Maven projects
* Moonshine will load the Java project dependencies from pom.xml or build.gradle.  The classpath is determined by the build scripts only.  For Gradle projects, you can force the dependencies to update to the classpath with Project > Refresh Gradle Classpath.
* Create Grails projects
* Moonshine SDK Installer will now install the Gradle and Grails SDKs

### Changed
* The **Reference** window from View > Find References has been moved to the console area.
* The default repository entries from the previous release can now be restored with Help > Restore Default Dependencies
* New > File will now create a file with an arbitrary extension in any project type.
* Added validation for manually setting SDK paths
* File choosers will now automatically open to the last used path when possible.

### Fixed
* Code Editor: Fixed issue where selecting text in a Java project caused exceptions on focus change
* Fixed issue where some project templates were missing in the Home tab.
* Fixed issue where modifications to the project templates were ignored when creating new projects.
* Fixed issue where Getting Started entries did not update their status when set manually by the user.
* Fixed issue where opening the same project more than once created multiple language server instances


## Moonshine IDE [2.2.0]

### Summary

This release was focused on adding Git support in the Manage Repositories interface from 2.1.0.  You may now clone and track Git repositories in this interface.  To help new users get started, we have added a few example repositories to the interface by default.  This includes the Moonshine source and some examples for Apache Royale.

We also made some changes to make it faster to clone complicated projects.  Moonshine will now automatically detect subprojects within a repository, and prompt the user to decide which projects to open.  In addition, we added a feature to allow repositories to define links to other repositories with moonshine-dependencies.xml.   For example, Moonshine-IDE provides links to all of its external dependencies, so that you can clone all required projects without leaving Moonshine or reviewing a README file.  This file may be added to other repositories using the format defined [here](https://github.com/prominic/Moonshine-IDE/wiki/Link-Related-Projects-with-moonshine-dependencies.xml).

### Added
* Added support to define related repositories for an SVN or Git repository, using moonshine-dependencies.xml.  See the documentation [here](https://github.com/prominic/Moonshine-IDE/wiki/Link-Related-Projects-with-moonshine-dependencies.xml).
* If a cloned or checked out repository contains multiple subprojects (like https://github.com/prominic/Moonshine-IDE.git), Moonshine will allow the user to automatically open the subprojects (up to 3 levels deep).
* Added [Apache Royale](https://royale.apache.org/) Jewel project template.  This requires a [nightly build (0.9.6)](http://apacheroyaleci.westus2.cloudapp.azure.com:8080/job/royale-asjs_jsonly/lastSuccessfulBuild/artifact/out/) of Apache Royale.

### Changed
* Added support for Git in the Manage Repositories interface.
* Provide non-sandbox version of Moonshine for Mac users.
* Visual Editor: Allow search **Code** tab using menu option **Edit** -> **Find**.

### Fixed
* Fixed issue where Browse All repository threw an error when the repository list was empty. 
* Templates: Fixed issue where modifying a template triggered an exception 

#### Known Issue
* Template modifications will not be applied to new projects.
* The Jewel template for Apache Royale requires the latest [nightly build (0.9.6)](http://apacheroyaleci.westus2.cloudapp.azure.com:8080/job/royale-asjs_jsonly/lastSuccessfulBuild/artifact/out/) which is not currently available with Moonshine SDK Installer



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
