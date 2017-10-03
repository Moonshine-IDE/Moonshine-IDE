# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

## Moonshine IDE [1.6.0] (Release pending)

### Added
* Useful Links Panel:  This panel contains links that may be useful for your development work.  More will be added as we find them.
* Options to customize the display for the AIR simulator for mobile projects.  See the Run tab in the project settings
* Window:  The window size and maximized status will be preserved when restarting Moonshine
* Panels:  The panel size will be preserved when restarting Moonshine
* HTML-template:  Web (Flash) projects now accompanied with set of wrapper HTML files, to run the Flash in browser(s)
* Auto-update:  Application auto-update feature added in Windows and non-App-Store version of OSX, when Moonshine will have new release

### Changed
* Console:  Updated the source code links
* API Docs panel:  merged with Useful Links

### Fixed
* ANT Build: 
** Fixed issue where ANT build was failing if path to build.xml contains spaces
** Fixed ANT script for FlexJS project template
* Project build: Fixed issue where FlexJS project build was failing if target player version has minor number (ex. `<target-player>11.7</target-player>`)
* Project build: Fixed issue when producing blank SWF with FlexJS SDK version less than 0.8
* Tooltips:  Fixed some cases where the tooltips didn't disappear properly.
