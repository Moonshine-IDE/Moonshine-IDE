# MoonshineGUICore

This project contains views created with [Feathers UI](https://feathersui.com/) and written in [Haxe](https://haxe.org/). We are currently in the process of migrating from Apache Flex to Feathers UI.

Since the _MoonshineGUICore_ project is written is Haxe, building it works a bit differently than the rest of Moonshine IDE, which is written in ActionScript and MXML.

## Prerequisites

- [Download Haxe](https://haxe.org/download/)
- [Install Feathers UI](https://feathersui.com/learn/haxe-openfl/installation/)

### Editors and IDEs

The _MoonshineGUICore_ project folder may be imported into Moonshine IDE or Visual Studio Code. It may be possible to create a project in other IDEs, but it will require manual configuration.

## Build

The _MoonshineGUICore_ project is currently compiled as a _.swc_ library file, so that the views may be used in ActionScript and MXML. The compiled library is used when building the main Moonshine IDE desktop project targeting Adobe AIR.

In a terminal, build _MoonshineGUICore_ with the following command:

```sh
openfl build flash -debug
```

In an editor or IDE, make sure that the Flash (Debug) OpenFL target is selected before building.

## Development

Generally, the package organization is the same in _MoonshineGUICore_ as it is in _MoonshineSharedCore_. The only difference is that the root package name has been replaced with `moonshine` (previously, it was `actionScripts`).

When adding a new view, it should be referenced in _src/moonshine/HaxeClasses.hx_ to be sure that it gets compiled into the _.swc_ file.

Try to avoid committing the binary _.swc_ file too frequently. It's often best to wait until you need others to test your changes.

### Getters and Setters

All properties exposed as getters and setters need the `@:flash.property` annotation.

```hx
private var _myProperty:String = "default value";

@:flash.property
public var myProperty(get, set):String;

private function get_myProperty():String {
	return _myProperty;
}

private function set_myProperty(value:String):String {
	_myProperty = value;
}
```

The `@:flash.property` annotation will not be required in the future, when everything in Moonshine IDE is converted to Haxe. However, while we continue to compile these Haxe classes to a _.swc_ library and reference them from ActionScript and MXML code, it will be required.

### Loosely-coupled views

Converting views to Haxe is an opportunity for a bit of light refactoring to make them less tightly-coupled to the rest of the Moonshine. In particular, avoid accessing global singletons like `IDEModel.getModel()` or `GlobalEventDispatcher.getInstance()` inside views. These should be accessed from the view's associated plugin class only (generally still written in ActionScript, but they all will be converted to Haxe eventually). Any necessary data should be passed from plugins to views through setters. Views can notify plugins of changes using events.

See _src/moonshine/plugins/findreplace/view/GoToLineView.hx_ for a relatively simple example of a view that has a setter and dispatches an event. In this case, it has a `maxLineNumber` setter and dispatches `Event.CLOSE`.

### Externs

Various common utility classes and value objects are used throughout Moonshine. These classes have not yet been ported to Haxe, but they can be accessed by Haxe code if they are exposed as Haxe "externs" in the _externs_ folder. If an extern class is missing, feel free to add it. Some existing extern classes may be missing properties or methods, and they may be added, if needed. Warning: As explained above, try to avoid exposing global singletons like `IDEModel` and `GlobalEventDispatcher` as extern classes.

Here's a simple example of how to create an extern class:

```hx
package actionScripts.valueObjects;

extern class MyExternClass {
	public var someVariable:String;

	@:flash.property
	public var someGetter(default, never):Bool;

	@:flash.property
	public var someGetterAndSetter(default, default):Int;

	public function someMethod(arg:Float):Void;
}
```

### ActionScript integration

The `actionScripts.ui.FeathersUIWrapper` class is used to add Feathers UI views as children of Apache Flex views.

```as3
var feathersView:MyFeathersView = new MyFeathersView();
var flexView:FeathersUIWrapper = new FeathersUIWrapper(feathersView);
otherFlexView.addChild(flexView);
```

It is not possible to add Apache Flex views as children of Feathers UI views, and we do not intend to make this possible in the future. As a rule, you should start converting to Feathers UI at the deepest level of the display list and work your way up.
