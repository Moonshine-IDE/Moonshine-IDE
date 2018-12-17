# Groovy Language Server

## Build

Run the following command to build the project:

``` sh
gradlew build
```

The built *.jar* file with all dependencies included will be located at *build/libs/groovy-language-server-all.jar*.

## Test

Tests are known to be broken on Windows. To build the project without running tests, run the following command instead:

``` sh
gradlew build -x test
```