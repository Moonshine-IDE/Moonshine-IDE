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
package actionScripts.plugin.dominoInterface
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
	public class DominoObjectsConsolePlugin extends ConsolePlugin
	{
		public static const EVENT_PLUGIN_DEACTIVATED:String = "eventPluginDeactivated";

		override public function get name():String { return "Vagrant Console"; }
		override public function get author():String { return "Erik Pettersson & Moonshine Project Team"; }
		override public function get description():String { return ResourceManager.getInstance().getString('resources','plugin.desc.console'); }

		public function DominoObjectsConsolePlugin()
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