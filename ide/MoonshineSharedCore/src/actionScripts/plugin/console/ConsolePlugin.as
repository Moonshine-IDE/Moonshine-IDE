////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.console
{
    import actionScripts.plugin.projectPanel.events.ProjectPanelPluginEvent;

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
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.BooleanSetting;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	/**
	 *  @private
	 *  Version string for this class.
	 */
	public class ConsolePlugin extends PluginBase implements IPlugin, ISettingsProvider
	{
		private var consoleView:ConsoleView;
		private var consoleCmd:Boolean;
		private var consoleCtrl:Boolean;
		private var mode:String = "";
		private var consoleTextCache:Array;

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
				cmds.push(cmd +" - <font color='#4C9BE0'> " +obj.commandDesc+"</font>");	
			}
			cmds = cmds.sort();
			
			var halp:String = "Available commands:\n";
			for each (cmd in cmds)
			{				
				halp += cmd + "\n";
			}
			
			halp = halp.substr(0, halp.length-1);
			outputMsg(halp);
		}
		
		public function aboutCommand(args:Array):void
		{
			var ntc:String = "Moonshine IDE "+ model.flexCore.version +"\n";
			ntc += "Source code is under Apache License, Version 2.0\n";
			ntc += "https://github.com/prominic/Moonshine-IDE\n";
			ntc += "Uses as3abc (LGPL), as3swf (MIT), fzip (ZLIB), asblocks (Apache License 2.0), NativeApplicationUpdater (LGPL)\n";
			
			if (ConstantsCoreVO.IS_AIR) ntc += "Running on Adobe AIR " + model.flexCore.runtimeVersion;
			notice(ntc);
		}

        private function addKeyListener(event:Event=null):void
        {
            consoleView.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        }

        private function handleKeyDown(event:KeyboardEvent):void
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

        private function toggleConsole(event:KeyboardEvent):void
        {
            if (consoleView.stage.focus != consoleView.commandLine)
            {
                event.preventDefault();
                consoleView.commandLine.setFocus();
                consoleCmd = false;
                consoleCtrl = false;
            }
        }


        private function changeMode(e:ConsoleModeEvent):void
        {
            mode = e.mode;
            consoleView.commandPrefix.text = " "+mode+">"
        }

        private function execCommand(event:ConsoleCommandEvent):void
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

        private function consoleClearHandler(event:ConsoleOutputEvent):void
        {
            consoleView.history.text = "";
        }

        private function consoleOutputHandler(event:ConsoleOutputEvent):void
        {
			if (!consoleView.history.textFlow)
			{
				this.consoleTextCache.push(event.text);
			}
			else
			{
                consoleView.history.appendtext(event.text);
			}
        }

        private function consolePrintHandler(event:ConsoleOutputEvent):void
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
                    notice(event.text);
                    break;
                default:
                    print(event.text);
                    break;
            }
        }

        private function onConsoleViewCreationComplete(event:FlexEvent):void
        {
            consoleView.removeEventListener(FlexEvent.CREATION_COMPLETE, onConsoleViewCreationComplete);

			for each (var text:String in consoleTextCache)
			{
				consoleView.history.appendtext(text);
			}

			consoleTextCache = null;
            consoleView.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        }
	}
}
