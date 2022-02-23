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
package actionScripts.plugins.vagrant
{
	import actionScripts.plugin.console.*;

	import flash.display.DisplayObject;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;

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
    import actionScripts.ui.menu.MenuPlugin;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.ui.FeathersUIWrapper;
	
	/**
	 *  @private
	 *  Version string for this class.
	 */
	public class VagrantConsolePlugin extends ConsolePlugin
	{
		public static const EVENT_PLUGIN_DEACTIVATED:String = "eventPluginDeactivated";

		override public function get name():String { return "Vagrant Console"; }
		override public function get author():String { return "Erik Pettersson & Moonshine Project Team"; }
		override public function get description():String { return ResourceManager.getInstance().getString('resources','plugin.desc.console'); }

		public function VagrantConsolePlugin()
		{
			activate();
		}
		
		override public function activate():void
        {
            consoleTextCache = [];

            consoleView = new ConsoleView();
			consoleView.showCommandLine = false;
			consoleView.label = "Vagrant";
			consoleView.displayContextMenuHelp = consoleView.displayContextMenuHide =
					consoleView.displayContextMenuExit = consoleView.displayContextMenuAbout = false;
			consoleView.consolePopOver = consolePopsOver;

			consoleView.addEventListener(FlexEvent.CREATION_COMPLETE, onConsoleViewCreationComplete);
			consoleView.addEventListener(Event.REMOVED_FROM_STAGE, onConsoleViewRemoved, false, 0, true);

			dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.ADD_VIEW_TO_PROJECT_PANEL, consoleView));
			dispatcher.addEventListener(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, consoleOutputHandler);

			var tempObj:Object = {};
			tempObj.callback = clearCommand;
			tempObj.commandDesc = "Clear all text from the console.";
			registerCommand("clear", tempObj);
			consoleView.commandLine.addEventListener(ConsoleCommandEvent.EVENT_COMMAND, execCommand);
        }
		
		override public function deactivate():void
		{
			if (consoleView && consoleView.parent)
			{
				consoleView.commandLine.removeEventListener(ConsoleCommandEvent.EVENT_COMMAND, execCommand);
				consoleView.removeEventListener(Event.REMOVED_FROM_STAGE, onConsoleViewRemoved);
				(consoleView.parent as IVisualElementContainer).removeElement(consoleView);
			}

			consoleView.removeEventListener(Event.REMOVED_FROM_STAGE, onConsoleViewRemoved);
			dispatcher.removeEventListener(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, consoleOutputHandler);
		}
		
		override public function get activated():Boolean
		{
			return (consoleView != null);
		}

		override public function clearCommand(args:Array):void
		{
			consoleClearHandler(null);
		}

		public function show():void
		{
			if (activated)
			{
				dispatcher.dispatchEvent(new ProjectPanelPluginEvent(ProjectPanelPluginEvent.SELECT_VIEW_IN_PROJECT_PANEL, consoleView));
			}
		}

		private function onConsoleViewRemoved(event:Event):void
		{
			deactivate();
			dispatcher.dispatchEvent(new Event(EVENT_PLUGIN_DEACTIVATED));
		}

        override protected function onConsoleViewCreationComplete(event:FlexEvent):void
        {
            consoleView.removeEventListener(FlexEvent.CREATION_COMPLETE, onConsoleViewCreationComplete);
			for each (var text:String in consoleTextCache)
			{
				consoleView.history.appendtext(text);
			}

			consoleTextCache = null;
        }
	}
}
