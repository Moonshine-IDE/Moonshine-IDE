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

package moonshine.plugin.debugadapter.view;

import moonshine.theme.MoonshineTheme;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import moonshine.dsp.StackFrame;
import moonshine.dsp.Thread;
import moonshine.plugin.debugadapter.events.DebugAdapterViewThreadEvent;

class ThreadOrStackFrameItemRenderer extends LayoutGroupItemRenderer {
	public static final CHILD_VARIANT_PLAY_BUTTON = "threadOrStackFrameItemRenderer--playButton";
	public static final CHILD_VARIANT_PAUSE_BUTTON = "threadOrStackFrameItemRenderer--pauseButton";
	public static final CHILD_VARIANT_STEP_OVER_BUTTON = "threadOrStackFrameItemRenderer--stepOverButton";
	public static final CHILD_VARIANT_STEP_INTO_BUTTON = "threadOrStackFrameItemRenderer--stepIntoButton";
	public static final CHILD_VARIANT_STEP_OUT_BUTTON = "threadOrStackFrameItemRenderer--stepOutButton";

	public function new() {
		super();
	}

	private var _paused:Bool = false;

	public var paused(get, set):Bool;

	private function get_paused():Bool {
		return _paused;
	}

	private function set_paused(value:Bool):Bool {
		if (_paused == value) {
			return _paused;
		}
		_paused = value;
		setInvalid(DATA);
		return _paused;
	}

	private var label:Label;
	private var playButton:Button;
	private var pauseButton:Button;
	private var stepOverButton:Button;
	private var stepIntoButton:Button;
	private var stepOutButton:Button;

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new HorizontalLayout();
		viewLayout.gap = 6.0;
		viewLayout.paddingTop = 4.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 4.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 4.0;
		viewLayout.horizontalAlign = LEFT;
		viewLayout.verticalAlign = MIDDLE;
		layout = viewLayout;

		label = new Label();
		label.variant = MoonshineTheme.THEME_VARIANT_LIGHT_LABEL;
		addChild(label);

		playButton = new Button();
		playButton.variant = CHILD_VARIANT_PLAY_BUTTON;
		playButton.toolTip = "Resume";
		playButton.addEventListener(TriggerEvent.TRIGGER, playButton_triggerHandler);
		addChild(playButton);

		pauseButton = new Button();
		pauseButton.variant = CHILD_VARIANT_PAUSE_BUTTON;
		pauseButton.toolTip = "Pause";
		pauseButton.addEventListener(TriggerEvent.TRIGGER, pauseButton_triggerHandler);
		addChild(pauseButton);

		stepOverButton = new Button();
		stepOverButton.variant = CHILD_VARIANT_STEP_OVER_BUTTON;
		stepOverButton.toolTip = "Step Over";
		stepOverButton.addEventListener(TriggerEvent.TRIGGER, stepOverButton_triggerHandler);
		addChild(stepOverButton);

		stepIntoButton = new Button();
		stepIntoButton.variant = CHILD_VARIANT_STEP_INTO_BUTTON;
		stepIntoButton.toolTip = "Step Into";
		stepIntoButton.addEventListener(TriggerEvent.TRIGGER, stepIntoButton_triggerHandler);
		addChild(stepIntoButton);

		stepOutButton = new Button();
		stepOutButton.variant = CHILD_VARIANT_STEP_OUT_BUTTON;
		stepOutButton.toolTip = "Step Out";
		stepOutButton.addEventListener(TriggerEvent.TRIGGER, stepOutButton_triggerHandler);
		addChild(stepOutButton);
	}

	override private function update():Void {
		super.update();

		if (data != null && Reflect.hasField(data, "line")) {
			var stackFrame = (data : StackFrame);
			label.visible = true;
			label.includeInLayout = true;
			label.text = '${stackFrame.line}, ${stackFrame.column}';
			playButton.visible = false;
			playButton.includeInLayout = false;
			pauseButton.visible = false;
			pauseButton.includeInLayout = false;
			stepOverButton.visible = false;
			stepOverButton.includeInLayout = false;
			stepIntoButton.visible = false;
			stepIntoButton.includeInLayout = false;
			stepOutButton.visible = false;
			stepOutButton.includeInLayout = false;
		} else {
			var thread = (data : Thread);
			label.visible = false;
			label.includeInLayout = false;
			label.text = null;
			playButton.visible = true;
			playButton.includeInLayout = true;
			pauseButton.visible = true;
			pauseButton.includeInLayout = true;
			stepOverButton.visible = true;
			stepOverButton.includeInLayout = true;
			stepIntoButton.visible = true;
			stepIntoButton.includeInLayout = true;
			stepOutButton.visible = true;
			stepOutButton.includeInLayout = true;
			playButton.enabled = thread != null && _paused;
			pauseButton.enabled = thread != null && !_paused;
			stepOverButton.enabled = thread != null && _paused;
			stepIntoButton.enabled = thread != null && _paused;
			stepOutButton.enabled = thread != null && _paused;
		}
	}

	private function playButton_triggerHandler(event:TriggerEvent):Void {
		var thread = (data : Thread);
		dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_RESUME, thread.id));
	}

	private function pauseButton_triggerHandler(event:TriggerEvent):Void {
		var thread = (data : Thread);
		dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_PAUSE, thread.id));
	}

	private function stepOverButton_triggerHandler(event:TriggerEvent):Void {
		var thread = (data : Thread);
		dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_OVER, thread.id));
	}

	private function stepIntoButton_triggerHandler(event:TriggerEvent):Void {
		var thread = (data : Thread);
		dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_INTO, thread.id));
	}

	private function stepOutButton_triggerHandler(event:TriggerEvent):Void {
		var thread = (data : Thread);
		dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_OUT, thread.id));
	}
}
