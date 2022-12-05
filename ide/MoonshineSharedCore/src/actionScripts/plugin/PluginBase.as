////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin 
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.console.view.ConsoleModeEvent;
	import mx.effects.effectClasses.ZoomInstance;
	
	public class PluginBase extends ConsoleOutputter implements IPlugin 
	{
		protected namespace console;
		
		override public function get name():String			{ throw new Error("You need to give a unique name.") }
		public function get author():String			{ return "N/A"; }
		public function get description():String	{ return "A plugin base that plugins can extend to gain easier access to some functionality."; }
		
		/**
		 * ensures if the plugin will be activated by default when the plugin 
		 * is loaded for the first time (without settings xml file written)
		 * */
		public function get activatedByDefault():Boolean { return true; }
		
		console static var commands:Dictionary = new Dictionary(true);
		console static var mode:String = "";

		protected var dispatcher:EventDispatcher = GlobalEventDispatcher.getInstance();
		protected var model:IDEModel = IDEModel.getInstance();
		
		protected var _activated:Boolean = false;
		public function get activated():Boolean 
		{
			return _activated;
		}
		
		public function activate():void
		{
			_activated = true;
		}
		public function deactivate():void
		{
			_activated = false;
		}
		public function resetSettings():void
		{
			
		}
		
		public function onSettingsClose():void
		{
			
		}
		
		public function PluginBase() {}
		
		// Console command functions
		protected function registerCommand(commandName:String, commandObj:Object):void
		{
			console::commands[commandName] = commandObj;
		}
		
		protected function unregisterCommand(commandName:String):void
		{
			delete console::commands[commandName];
		}
		
		protected function enterConsoleMode(newMode:String):void
		{
			console::mode = newMode;
			dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, newMode));
		}
		
		protected function exitConsoleMode():void
		{
			console::mode = "";
			dispatcher.dispatchEvent(new ConsoleModeEvent(ConsoleModeEvent.CHANGE, ""));
		}
		
		// TODO: Interface fixes
		public function get_name():String { return ""; }
		public function get_author():String { return ""; }
		public function get_description():String { return ""; }
		public function get_activated():Boolean { return false; }
		public function get_activatedByDefault():Boolean { return false; }
		
	}
}