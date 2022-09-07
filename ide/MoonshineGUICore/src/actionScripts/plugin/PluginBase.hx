package actionScripts.plugin;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.plugin.console.ConsoleOutputter;
import actionScripts.plugin.console.view.ConsoleModeEvent;
import openfl.events.EventDispatcher;
import openfl.utils.Dictionary;

class PluginBase extends ConsoleOutputter implements IPlugin {
	static var commands:Dictionary<String, Dynamic> = new Dictionary<String, Dynamic>();
	static var mode:String = "";

	private var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();

	private var _activated:Bool = false;

	public var activated(get, never):Bool;

	private function get_activated():Bool
		return _activated;

	private var _activatedByDefault:Bool = false;

	public var activatedByDefault(get, never):Bool;

	private function get_activatedByDefault():Bool
		return _activatedByDefault;

	private var _author:String;

	public var author(get, never):String;

	private function get_author():String
		return _author;

	private var _description:String;

	public var description(get, never):String;

	private function get_description():String
		return _description;

	private var _name:String;

	public var name(get, never):String;

	private function get_name():String
		return _name;

	public function new() {
		super();
	}

	public function activate():Void {
		_activated = true;
	}

	public function deactivate():Void {
		_activated = false;
	}

	public function resetSettings():Void {}

	public function onSettingsClose():Void {}

	// Console command functions
	private function registerCommand(commandName:String, commandObj:Dynamic):Void {
		commands[commandName] = commandObj;
	}

	private function unregisterCommand(commandName:String):Void {
		commands.remove(commandName);
	}

	private function enterConsoleMode(newMode:String):Void {
		mode = newMode;
		dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, newMode));
	}

	private function exitConsoleMode():Void {
		mode = "";
		dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, ""));
	}
}