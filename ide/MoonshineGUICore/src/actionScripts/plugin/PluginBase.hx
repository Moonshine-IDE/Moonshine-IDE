/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

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

	@:flash.property
	public var activated(get, never):Bool;

	private function get_activated():Bool
		return _activated;

	private var _activatedByDefault:Bool = false;

	@:flash.property
	public var activatedByDefault(get, never):Bool;

	private function get_activatedByDefault():Bool
		return _activatedByDefault;

	private var _author:String;

	@:flash.property
	public var author(get, never):String;

	private function get_author():String
		return _author;

	private var _description:String;

	@:flash.property
	public var description(get, never):String;

	private function get_description():String
		return _description;

	private var _name:String;

	@:flash.property
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