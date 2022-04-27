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
package actionScripts.plugin.console;

import flash.events.Event;

class ConsoleOutputEvent extends Event {
	public static final CONSOLE_OUTPUT:String = "consoleOutput";
	public static final CONSOLE_CLEAR:String = "consoleClear";
	public static final CONSOLE_PRINT:String = "consolePrint"; // this uses regular commands to print message to console other than how things works by CONSOLE_OUTPUT

	public static final CONSOLE_OUTPUT_VAGRANT:String = "consoleOutputVagrant";

	public static final TYPE_ERROR:String = "typeError";
	public static final TYPE_INFO:String = "typeInfo";
	public static final TYPE_SUCCESS:String = "typeSuccess";
	public static final TYPE_NOTE:String = "typeNotice";

	public var text:Any;
	public var hideOtherOutput:Bool;
	public var messageType:String;

	public function new(type:String, text:Any, hideOtherOutput:Bool = false, cancelable:Bool = false, messageType:String = "typeInfo") {
		this.text = text;
		this.hideOtherOutput = hideOtherOutput;
		this.messageType = messageType;
		super(type, false, cancelable);
	}
}