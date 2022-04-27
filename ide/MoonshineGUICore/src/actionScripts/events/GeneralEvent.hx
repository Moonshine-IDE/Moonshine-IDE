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

import openfl.events.Event;

class GeneralEvent extends Event {
	public static final DONE:String = "DONE";
	public static final DEVICE_UPDATED:String = "DEVICE_UPDATED";
	public static final RESET_ALL_SETTINGS:String = "RESET_ALL_SETTINGS";
	public static final SCROLL_TO_TOP:String = "SCROLL_TO_TOP";
	public static final EVENT_FILE_BROWSED:String = "eventFileBrowsed";

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, _bubble:Bool = false, _cancelable:Bool = true) {
		this.value = value;
		super(type, _bubble, _cancelable);
	}
}