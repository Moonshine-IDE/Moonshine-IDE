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
package actionScripts.plugin.console
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import mx.events.FlexEvent;
    import mx.resources.ResourceManager;
    
    import actionScripts.plugin.IPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.console.setting.SpecialKeySetting;
    import actionScripts.plugin.console.view.ConsoleModeEvent;
    import actionScripts.plugin.console.view.ConsoleView;
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.valueObjects.ConstantsCoreVO;
	
	/**
	 *  @private
	 *  Version string for this class.
	 */
	public class ConsolePlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		protected var consoleView:ConsoleView;
		protected var consoleCmd:Boolean;
		protected var consoleCtrl:Boolean;
		protected var mode:String = "";
		protected var consoleTextCache:Array;

        private var _consolePopsOver:Boolean;
		private var _consoleTriggerKey:String;

		public var consoleTriggerKeyPropertyName:String = "charCode";
		public var consoleTriggerKeyValue:int = 27; // Escape
		public var ctrl:Boolean = false;
		public var alt:Boolean = false;
		public var cmd:Boolean = false;

		public function get consolePopsOver():Boolean
		{
			return _consolePopsOver;
		}
		public function set consolePopsOver(v:Boolean):void
		{
			_consolePopsOver = v;
			if (consoleView) consoleView.consolePopOver = v;
		}
		
		public function get showDebugMessages():Boolean
		{
			return ConsoleOutputter.DEBUG;
		}
		public function set showDebugMessages(v:Boolean):void
		{
			ConsoleOutputter.DEBUG = v;
		} 
		
		override public function get name():String { return "Console"; }
		override public function get author():String { return "Erik Pettersson & Moonshine Project Team"; }
		override public function get description():String { return ResourceManager.getInstance().getString('resources','plugin.desc.console'); }
		
		override public function activate():void
        {
            consoleTextCache = [];

            consoleView = new ConsoleView();
			consoleView.addEventListener(FlexEvent.CREATION_COMPLETE, onConsoleViewCreationComplete);

            consoleView.consolePopOver = consolePopsOver;
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, consoleView));


            dispatcher.addEventListener(ConsoleOutputEvent.CONSOLE_OUTPUT, consoleOutputHandler);
			dispatcher.addEventListener(ConsoleOutputEvent.CONSOLE_PRINT, consolePrintHandler);
            dispatcher.addEventListener(ConsoleOutputEvent.CONSOLE_CLEAR, consoleClearHandler);
			dispatcher.addEventListener(ConsoleEvent.SHOW_CONSOLE, showConsoleHandler);

            dispatcher.addEventListener(ConsoleModeEvent.CHANGE, changeMode);

            var tempObj:Object = {};
            tempObj.callback = clearCommand;
            tempObj.commandDesc = "Clear all text from the console.";
            registerCommand("clear", tempObj);

            tempObj = {};
            tempObj.callback = helpCommand;
            tempObj.commandDesc = "List the available console commands.";
            registerCommand("help", tempObj);

            tempObj = {};
            tempObj.callback = exitCommand;
            tempObj.commandDesc = "Close Moonshine.  You will be prompted to save any unsaved files.";
            registerCommand("exit", tempObj);

            tempObj = {};
            tempObj.callback = aboutCommand;
            tempObj.commandDesc = "Display version and license information for Moonshine.";
            registerCommand("about", tempObj);

            // Get commands from view
            consoleView.commandLine.addEventListener(ConsoleCommandEvent.EVENT_COMMAND, execCommand);

            // just a demo output
            //About.onCreationCompletes();
            var timeoutValue:uint = setTimeout(function():void{
				aboutCommand(null);
				clearTimeout(timeoutValue);
        	}, 3000);
        }
		
		override public function deactivate():void
		{
			if (consoleView && consoleView.parent)
			{
				consoleView.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				consoleView.parent.removeChild(consoleView);
			}
			
			unregisterCommand("clear");
			unregisterCommand("hide");
			unregisterCommand("exit");
			unregisterCommand("help");
			
			dispatcher.removeEventListener(ConsoleOutputEvent.CONSOLE_OUTPUT, consoleOutputHandler);
			dispatcher.removeEventListener(ConsoleOutputEvent.CONSOLE_PRINT, consolePrintHandler);
            dispatcher.removeEventListener(ConsoleOutputEvent.CONSOLE_CLEAR, consoleClearHandler);
			dispatcher.removeEventListener(ConsoleEvent.SHOW_CONSOLE, showConsoleHandler);

			dispatcher.removeEventListener(ConsoleModeEvent.CHANGE, changeMode);
		}
		
		override public function get activated():Boolean
		{
			return (consoleView != null);
		}
		
		override public function resetSettings():void
		{
			consoleTriggerKey = null;
			consolePopsOver = false;
			showDebugMessages = true;
		}

		public function get consoleTriggerKey():String
		{
			return _consoleTriggerKey;
		}
		
		public function set consoleTriggerKey(value:String):void
		{
			_consoleTriggerKey = value;
			if (value)
			{
				var values:Array = value.split(":");
				consoleTriggerKeyPropertyName = values[0];
				alt  = (values[2]=="false"?false:true);
				ctrl = (values[3]=="false"?false:true);
				cmd  = (values[4]=="false"?false:true);
				consoleCmd = false;
				consoleCtrl = false;
				consoleTriggerKeyValue = parseInt(values[1]);
			}
		}
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new SpecialKeySetting(this, "consoleTriggerKey", "Console trigger key",consoleTriggerKey),
				new BooleanSetting(this, "consolePopsOver", "Console should glide over editor"),// This line is commented for now becuase it only hide console view for now 
				new BooleanSetting(this, "showDebugMessages", "Show Moonshine debug messages")
			]);
		}

		public function clearCommand(args:Array):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_CLEAR, null, true));
		}

		public function exitCommand(args:Array):void
		{
			dispatcher.dispatchEvent( new Event(MenuPlugin.MENU_QUIT_EVENT) );
		}

		public function helpCommand(args:Array):void
		{
			var cmds:Array = [];
			for (var cmd:String in console::commands)
			{
				var obj:Object = console::commands[cmd];
				cmds.push(cmd +" - " +obj.commandDesc);	
			}
			cmds = cmds.sort();
			
			var halp:String = "Available commands:\n";
			for each (cmd in cmds)
			{				
				halp += cmd + "\n";
			}
			
			halp = halp.substr(0, halp.length-1);
			//html(halp);
			print(halp);
		}
		
		public function aboutCommand(args:Array):void
		{
			var ntc:String = ConstantsCoreVO.MOONSHINE_IDE_LABEL +" "+ model.getVersionWithBuildNumber() +"\n";
			ntc += ConstantsCoreVO.MOONSHINE_IDE_COPYRIGHT_LABEL +"\n";
			ntc += "Source code is under Apache License, Version 2.0\n";
			ntc += "https://github.com/Moonshine-IDE/Moonshine-IDE\n";
			ntc += "Uses as3abc (LGPL), as3swf (MIT), fzip (ZLIB), asblocks (Apache License 2.0), NativeApplicationUpdater (LGPL)\n";
			
			if (ConstantsCoreVO.IS_AIR) ntc += "Running on Adobe AIR " + model.flexCore.runtimeVersion;
			notice(ntc);
		}

		protected function addKeyListener(event:Event=null):void
        {
            consoleView.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        }

		protected function handleKeyDown(event:KeyboardEvent):void
        {
            if(event.keyCode == 15 )
                consoleCmd = true;
            if(event.keyCode == 17)
                consoleCtrl = true;
            //cmd 17ctrl

            if (consoleTriggerKeyPropertyName=="charCode" && event[consoleTriggerKeyPropertyName] == consoleTriggerKeyValue)
            {
                // For combinatio key
                if(cmd && consoleCmd)//for command key
                {
                    toggleConsole(event);
                }
                else if(ctrl && consoleCtrl )// for Control Key
                {
                    toggleConsole(event);
                }
                else if(alt && event.altKey)
                {
                    toggleConsole(event);
                }
            }

        }

		protected function toggleConsole(event:KeyboardEvent):void
        {
            if (consoleView.stage.focus != consoleView.commandLine)
            {
                event.preventDefault();
                FeathersUIWrapper(consoleView.commandLine.parent).setFocus();
                consoleCmd = false;
                consoleCtrl = false;
            }
        }

		protected function changeMode(e:ConsoleModeEvent):void
        {
            mode = e.mode;
            consoleView.commandPrefix.text = " "+mode+">"
        }

		protected function execCommand(event:ConsoleCommandEvent):void
        {
            if (mode == "")
            {
                if (console::commands[event.command])
                {
                    var obj:Object = console::commands[event.command];
                    var func:Function = obj.callback;
                    func(event.args);
                    //console::commands[event.command](event.args);
                }
                else
                {
                    print("%s: command not found", event.command);
                }
            }
            else
            {
                // Command is an argument in a mode
                var args:Array = [event.command];
                args = args.concat(event.args);
                console::commands[mode](args);
            }
        }

		protected function consoleClearHandler(event:ConsoleOutputEvent):void
        {
            //consoleView.history.text = "";
			consoleView.historyTextEditor.clearText();
        }

		protected function consoleOutputHandler(event:ConsoleOutputEvent):void
        {
			consoleView.historyTextEditor.appendtext(event.text, event.messageType);
			/*if (!consoleView.history.textFlow)
			{
				this.consoleTextCache.push(event.text);
			}
			else
			{
                consoleView.history.appendtext(event.text);
				consoleView.historyTextEditor.appendtext(event.text);
			}*/
        }

		protected function consolePrintHandler(event:ConsoleOutputEvent):void
        {
            switch(event.messageType)
            {
                case ConsoleOutputEvent.TYPE_ERROR:
                    error(event.text);
                    break;
                case ConsoleOutputEvent.TYPE_SUCCESS:
                    success(event.text);
                    break;
                case ConsoleOutputEvent.TYPE_NOTE:
                    warning(event.text);
                    break;
				case ConsoleOutputEvent.TYPE_HTML:
					html(event.text);
					break;
                default:
                    print(event.text);
                    break;
            }
        }

		protected function onConsoleViewCreationComplete(event:FlexEvent):void
        {
            consoleView.removeEventListener(FlexEvent.CREATION_COMPLETE, onConsoleViewCreationComplete);

			for each (var text:String in consoleTextCache)
			{
				//consoleView.history.appendtext(text);
				consoleView.historyTextEditor.appendtext(text);
			}

			consoleTextCache = null;
            consoleView.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        }

		protected function showConsoleHandler(event:ConsoleEvent):void
		{
			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, consoleView));
		}
	}
}
