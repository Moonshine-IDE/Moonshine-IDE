# Groovy language server for Moonshine IDE

This project is a wrapper around [prominic/groovy-language-server](https://github.com/prominic/groovy-language-server) for [Moonshine IDE](https://moonshine-ide.com). It provides a custom `ICompilationUnitFactory` for the *.gvyproj* file format used to configure Groovy projects in Moonshine IDE.

## Build

To build *moonshine-groovy.jar*, run the following command:


```
./gradlew build
```

To replace the current *moonshine-groovy.jar* version of Moonshine IDE with your local build, run the following command:

```
./gradlew deploy
```