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