# Details and Status of ActionScript to Haxe Conversion

Changelog of Haxe conversion.

Externs are not listed, and can be found [in this directory](https://github.com/Moonshine-IDE/Moonshine-IDE/tree/features/haxeconversion/ide/MoonshineGUICore/externs).

#### 7/15/2022

##### MoonshineGUICore

|Package|Files|Comments|Affected Parts|% of conversion|
|---|---|---|---|:---:|
|actionScripts.controllers|*|Classes derived from ICommand interface||40%|
|actionScripts.events|*|Simple Event classes, mostly simple conversions||100%|
|actionScripts.impls|*|Implementations of actionScripts.interfaces package||10%|
|actionScripts.interfaces|*|Intefaces||30%|
|actionScripts.locator|*|Models, Workers, Controllers||30%|
|actionScripts.plugin|*|IPlugin interface|||
|actionScripts.plugin.build|*|Constants, Definitions||100%|
|actionScripts.plugin.build.vo|*|Constants, Definitions||100%|
|actionScripts.plugin.console|*|Event classes have been converted||50%|
|actionScripts.plugin.console.view|*|Event classes have been converted||20%|
|actionScripts.plugin.core.compiler|*|Event classes||100%|
|actionScripts.plugin.core.sourcecontrol|*|Intefaces||100%|
|actionScripts.plugin.java.javaproject.vo|*|Simple constants and definitions||30%|
|actionScripts.plugins.ant.events|*|Events||100%|
|actionScripts.plugins.exterbakEditors.vo|*|Value objects||100%|
|actionScripts.ui.tabview|*|Events||10%|
|actionScripts.utils|*|Some static functions and constants||10%|
|actionScripts.valueObjects|*|This part is mostly done, some larger, more complex files remain (eg. ProjectVO, ConstantsCoreVO)||80%|
|actionScripts.vo|*|||100%|
|moonshine.components|MoonshineTabNavigator.hx|Custom TabNavigator component|About Screen|100%|
|moonshine.components|ProgressIndicator.hx|Custom circular progress indicator. Can be used anywhere in the app|About Screen while loading data|100%|
|moonshine.data.preferences|MoonshinePreferences.hx|Package to handle Flash's SharedObject logic (currently write-only, saves whatever is being read from Flash SharedObject)|App preferences, opened projects etc.|100%|
|moonshine.data.preferences|*|Typedefs||100%|
|moonshine.plugin.view.about|AboutScreen.hx|Feathers-based About Screen|About Screen|100%|
|moonshine.theme|MoonshineColor.hx|Color definitions for FeathersUI components|||
|moonshine.theme|MoonshineTheme.hx|Style definitions for FeathersUI components|||
|moonshine.theme|MoonshineTypography.hx|TextFormats, font styles and relevant functions for FeathersUI components|||
|moonshine.utils.data|ArrayCollectionUtil.hx|Methods to convert between MX Collections and FeathersUI Collections|||

##### MoonshineDESKTOPEvolved

|Package|Files|Comments|Affected Parts|% of conversion|
|---|---|---|---|:---:|
|actionScripts.ui.feathersWrapper.help|AboutScreenWrapper .as|Custom FeathersUIWrapper to wrap AboutScreen in a Flex component||100%|
|actionScripts.impls|IAboutBridgeImp .as|Modified to display the new AboutScreen|||