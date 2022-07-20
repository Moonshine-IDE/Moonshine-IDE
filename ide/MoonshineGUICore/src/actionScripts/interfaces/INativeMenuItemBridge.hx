package actionScripts.interfaces;

import actionScripts.valueObjects.KeyboardShortcut;
import openfl.events.Event;

interface INativeMenuItemBridge {
	public var keyEquivalent(get, set):String;
	public var keyEquivalentModifiers(get, set):Array<Int>;
	public var data(get, set):Dynamic;
	public var listener(never, set):(Event)->Void;
	public var shortcut(never, set):KeyboardShortcut;
	public var getNativeMenuItem(get, never):Dynamic;

	function createMenu(label:String = "", isSeparator:Bool = false, listener:(Event)->Void = null, enableTypes:Array<Dynamic> = null):Void;
}