/*
	Copyright 2021 Prominic.NET, Inc.

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

package moonshine.plugin.debugadapter.events;

import openfl.events.Event;

class DebugAdapterViewThreadEvent extends Event {
	public static final DEBUG_RESUME = "debugResume";
	public static final DEBUG_PAUSE = "debugPause";
	public static final DEBUG_STEP_OVER = "debugStepOver";
	public static final DEBUG_STEP_INTO = "debugStepInto";
	public static final DEBUG_STEP_OUT = "debugStepOut";
	public static final DEBUG_STOP = "debugStop";

	public function new(type:String, threadId:Int = -1) {
		super(type, false, false);
		this.threadId = threadId;
	}

	public var threadId:Int;

	override public function clone():Event {
		return new DebugAdapterViewThreadEvent(this.type, this.threadId);
	}
}
