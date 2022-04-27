/*
	Copyright 2022 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package actionScripts.events;

import actionScripts.interfaces.ICustomCommandRunProvider;
import actionScripts.plugin.build.vo.BuildActionVO;
import flash.events.Event;

class CustomCommandsEvent extends Event {
	public static final OPEN_CUSTOM_COMMANDS_ON_SDK:String = "openCustomCommandsInterfaceForSDKtype";
	public static final RUN_CUSTOM_COMMAND_ON_SDK:String = "runCustomCommandForSDKtype";

	public var commands:Array<String>;
	public var selectedCommand:BuildActionVO;
	public var executableNameToDisplay:String;
	public var origin:ICustomCommandRunProvider;

	public function new(type:String, executableNameToDisplay:String, commands:Array<String>, origin:ICustomCommandRunProvider,
			selectedCommand:BuildActionVO = null) {
		this.commands = commands;
		this.selectedCommand = selectedCommand;
		this.origin = origin;
		this.executableNameToDisplay = executableNameToDisplay;

		super(type, false, false);
	}
}