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

package moonshine.plugin.debugadapter.view;

import haxe.Json;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import openfl.events.Event;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeGridView;
import feathers.controls.TreeGridViewColumn;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.IHierarchicalCollection;
import feathers.data.TreeGridViewCellState;
import feathers.events.TreeGridViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.utils.DisplayObjectRecycler;
import moonshine.dsp.Scope;
import moonshine.dsp.StackFrame;
import moonshine.dsp.Thread;
import moonshine.dsp.Variable;
import moonshine.plugin.debugadapter.events.DebugAdapterViewThreadEvent;
import moonshine.plugin.debugadapter.events.DebugAdapterViewLoadVariablesEvent;
import moonshine.plugin.debugadapter.events.DebugAdapterViewStackFrameEvent;

@:styleContext
class DebugAdapterView extends LayoutGroup implements IViewWithTitle {
	public static final CHILD_VARIANT_PLAY_BUTTON = "debugAdapterView--playButton";
	public static final CHILD_VARIANT_PAUSE_BUTTON = "debugAdapterView--pauseButton";
	public static final CHILD_VARIANT_STEP_OVER_BUTTON = "debugAdapterView--stepOverButton";
	public static final CHILD_VARIANT_STEP_INTO_BUTTON = "debugAdapterView--stepIntoButton";
	public static final CHILD_VARIANT_STEP_OUT_BUTTON = "debugAdapterView--stepOutButton";
	public static final CHILD_VARIANT_STOP_BUTTON = "debugAdapterView--stopButton";

	public function new() {
		super();
		this.pausedThreads = new ArrayCollection();
		this.scopesAndVariables = new ArrayHierarchicalCollection();
		this.threadsAndStackFrames = new ArrayHierarchicalCollection();
	}

	private var playButton:Button;
	private var pauseButton:Button;
	private var stepOverButton:Button;
	private var stepIntoButton:Button;
	private var stepOutButton:Button;
	private var stopButton:Button;
	private var variablesTree:TreeGridView;
	private var threadsTree:TreeGridView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Debug";
	}

	private var _active:Bool = false;

	@:flash.property
	public var active(get, set):Bool;

	private function get_active():Bool {
		return this._active;
	}

	private function set_active(value:Bool):Bool {
		if (this._active == value) {
			return this._active;
		}
		this._active = value;
		this.setInvalid(InvalidationFlag.STATE);
		return this._active;
	}

	private var _pausedThreads:ArrayCollection<Float>;

	@:flash.property
	public var pausedThreads(get, set):ArrayCollection<Float>;

	private function get_pausedThreads():ArrayCollection<Float> {
		return this._pausedThreads;
	}

	private function set_pausedThreads(value:ArrayCollection<Float>):ArrayCollection<Float> {
		if (this._pausedThreads == value) {
			return this._pausedThreads;
		}
		if (this._pausedThreads != null) {
			this._pausedThreads.removeEventListener(Event.CHANGE, pausedThreads_changeHandler);
		}
		this._pausedThreads = value;
		if (this._pausedThreads != null) {
			this._pausedThreads.addEventListener(Event.CHANGE, pausedThreads_changeHandler);
		}
		this.setInvalid(InvalidationFlag.STATE);
		return this._pausedThreads;
	}

	private var _scopesAndVariables:IHierarchicalCollection<Any>;

	@:flash.property
	public var scopesAndVariables(get, set):IHierarchicalCollection<Any>;

	private function get_scopesAndVariables():IHierarchicalCollection<Any> {
		return this._scopesAndVariables;
	}

	private function set_scopesAndVariables(value:IHierarchicalCollection<Any>):IHierarchicalCollection<Any> {
		if (this._scopesAndVariables == value) {
			return this._scopesAndVariables;
		}
		this._scopesAndVariables = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._scopesAndVariables;
	}

	private var _threadsAndStackFrames:IHierarchicalCollection<Any>;

	@:flash.property
	public var threadsAndStackFrames(get, set):IHierarchicalCollection<Any>;

	private function get_threadsAndStackFrames():IHierarchicalCollection<Any> {
		return this._threadsAndStackFrames;
	}

	private function set_threadsAndStackFrames(value:IHierarchicalCollection<Any>):IHierarchicalCollection<Any> {
		if (this._threadsAndStackFrames == value) {
			return this._threadsAndStackFrames;
		}
		this._threadsAndStackFrames = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._threadsAndStackFrames;
	}

	override private function initialize():Void {
		this.layout = new HorizontalLayout();

		var buttonsLayout = new VerticalLayout();
		buttonsLayout.gap = 4.0;
		buttonsLayout.setPadding(4.0);
		var buttonsContainer = new LayoutGroup();
		buttonsContainer.layout = buttonsLayout;
		this.addChild(buttonsContainer);

		this.playButton = new Button();
		this.playButton.variant = CHILD_VARIANT_PLAY_BUTTON;
		this.playButton.addEventListener(TriggerEvent.TRIGGER, playButton_triggerHandler);
		buttonsContainer.addChild(this.playButton);

		this.pauseButton = new Button();
		this.pauseButton.variant = CHILD_VARIANT_PAUSE_BUTTON;
		this.pauseButton.addEventListener(TriggerEvent.TRIGGER, pauseButton_triggerHandler);
		buttonsContainer.addChild(this.pauseButton);

		this.stepOverButton = new Button();
		this.stepOverButton.variant = CHILD_VARIANT_STEP_OVER_BUTTON;
		this.stepOverButton.addEventListener(TriggerEvent.TRIGGER, stepOverButton_triggerHandler);
		buttonsContainer.addChild(this.stepOverButton);

		this.stepIntoButton = new Button();
		this.stepIntoButton.variant = CHILD_VARIANT_STEP_INTO_BUTTON;
		this.stepIntoButton.addEventListener(TriggerEvent.TRIGGER, stepIntoButton_triggerHandler);
		buttonsContainer.addChild(this.stepIntoButton);

		this.stepOutButton = new Button();
		this.stepOutButton.variant = CHILD_VARIANT_STEP_OUT_BUTTON;
		this.stepOutButton.addEventListener(TriggerEvent.TRIGGER, stepOutButton_triggerHandler);
		buttonsContainer.addChild(this.stepOutButton);

		this.stopButton = new Button();
		this.stopButton.variant = CHILD_VARIANT_STOP_BUTTON;
		this.stopButton.addEventListener(TriggerEvent.TRIGGER, stopButton_triggerHandler);
		buttonsContainer.addChild(this.stopButton);

		var dividedBox = new HDividedBox();
		dividedBox.layoutData = HorizontalLayoutData.fill();
		this.addChild(dividedBox);

		this.variablesTree = new TreeGridView();
		this.variablesTree.variant = TreeGridView.VARIANT_BORDERLESS;
		var variablesColumn = new TreeGridViewColumn("Variables", getScopeOrVariableNameText);
		variablesColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer, (target, state:TreeGridViewCellState) -> {
			target.text = state.text;
			if (Reflect.hasField(state.data, "value")) {
				var variable = (state.data : Variable);
				target.toolTip = variable.type;
			} else {
				target.toolTip = null;
			}
		});
		var valuesColumn = new TreeGridViewColumn("Values", getScopeOrVariableValueText);
		valuesColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer, (target, state:TreeGridViewCellState) -> {
			target.text = state.text;
			target.toolTip = state.text;
		});
		this.variablesTree.columns = new ArrayCollection([variablesColumn, valuesColumn]);
		this.variablesTree.selectable = false;
		this.variablesTree.extendedScrollBarY = true;
		this.variablesTree.resizableColumns = true;
		this.variablesTree.addEventListener(TreeGridViewEvent.BRANCH_OPEN, variablesTree_branchOpenHandler);
		dividedBox.addChild(this.variablesTree);

		this.threadsTree = new TreeGridView();
		this.threadsTree.variant = TreeGridView.VARIANT_BORDERLESS;
		var stackColumn = new TreeGridViewColumn("Stack", getThreadOrStackFrameNameText);
		stackColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer, (target, state:TreeGridViewCellState) -> {
			target.text = state.text;
			if (Reflect.hasField(state.data, "line")) {
				var stackFrame = (state.data : StackFrame);
				var toolTip:String = stackFrame.name;
				if (stackFrame.source != null) {
					toolTip += " (" + stackFrame.line + "," + stackFrame.column + ")";
					toolTip += "\n" + stackFrame.source.path;
				}
				target.toolTip = toolTip;
			} else {
				target.toolTip = null;
			}
		});
		var lineColumn = new TreeGridViewColumn("Line", getThreadOrStackFramePositionText);
		lineColumn.cellRendererRecycler = DisplayObjectRecycler.withClass(HierarchicalItemRenderer);
		this.threadsTree.columns = new ArrayCollection([stackColumn, lineColumn]);
		this.threadsTree.extendedScrollBarY = true;
		this.threadsTree.resizableColumns = true;
		this.threadsTree.addEventListener(TreeGridViewEvent.CELL_TRIGGER, threadsTree_cellTriggerHandler);
		dividedBox.addChild(this.threadsTree);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);

		if (dataInvalid) {
			this.variablesTree.dataProvider = this._scopesAndVariables;
			this.threadsTree.dataProvider = this._threadsAndStackFrames;
		}

		if (stateInvalid) {
			this.playButton.enabled = active && _pausedThreads.length > 0;
			this.pauseButton.enabled = active && _pausedThreads.length == 0;
			this.stepOverButton.enabled = active && _pausedThreads.length > 0;
			this.stepIntoButton.enabled = active && _pausedThreads.length > 0;
			this.stepOutButton.enabled = active && _pausedThreads.length > 0;
			this.stopButton.enabled = active;
		}

		super.update();
	}

	private function getScopeOrVariableNameText(item:Any):String {
		if (Reflect.hasField(item, "value")) {
			var variable = (item : Variable);
			return variable.name;
		}
		var scope = (item : Scope);
		return scope.name;
	}

	private function getScopeOrVariableValueText(item:Any):String {
		if (Reflect.hasField(item, "value")) {
			var variable = (item : Variable);
			return variable.value;
		}
		return null;
	}

	private function getThreadOrStackFrameNameText(item:Any):String {
		if (Reflect.hasField(item, "line")) {
			var stackFrame = (item : StackFrame);
			return stackFrame.name;
		}
		var thread = (item : Thread);
		return thread.name;
	}

	private function getThreadOrStackFramePositionText(item:Any):String {
		if (Reflect.hasField(item, "line")) {
			var stackFrame = (item : StackFrame);
			return '${stackFrame.line}, ${stackFrame.column}';
		}
		return null;
	}

	private function playButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_RESUME));
	}

	private function pauseButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_PAUSE));
	}

	private function stepOverButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_OVER));
	}

	private function stepIntoButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_INTO));
	}

	private function stepOutButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STEP_OUT));
	}

	private function stopButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new DebugAdapterViewThreadEvent(DebugAdapterViewThreadEvent.DEBUG_STOP));
	}

	private function variablesTree_branchOpenHandler(event:TreeGridViewEvent<TreeGridViewCellState>):Void {
		var item:Any = event.state.data;
		if (!this._scopesAndVariables.isBranch(item)) {
			return;
		}
		this.dispatchEvent(new DebugAdapterViewLoadVariablesEvent(DebugAdapterViewLoadVariablesEvent.LOAD_VARIABLES, item));
	}

	private function threadsTree_cellTriggerHandler(event:TreeGridViewEvent<TreeGridViewCellState>):Void {
		var item:Any = event.state.data;
		if (item == null || !Reflect.hasField(item, "line")) {
			return;
		}
		var stackFrame = (item : StackFrame);
		this.dispatchEvent(new DebugAdapterViewStackFrameEvent(DebugAdapterViewStackFrameEvent.GOTO_STACK_FRAME, stackFrame));
	}

	private function pausedThreads_changeHandler(event:Event):Void {
		this.setInvalid(InvalidationFlag.STATE);
	}
}
