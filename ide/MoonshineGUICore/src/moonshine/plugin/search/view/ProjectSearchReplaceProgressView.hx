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

package moonshine.plugin.search.view;

import feathers.controls.HProgressBar;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;

class ProjectSearchReplaceProgressView extends ResizableTitleWindow {
	public function new() {
		super();
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 120.0;
		this.closeEnabled = true;
		this.resizeEnabled = false;
	}

	private var progressLabel:Label;
	private var progressBar:HProgressBar;
	private var finishButton:Button;

	private var _matchCountProcessed:Int = 0;

	@:flash.property
	public var matchCountProcessed(get, set):Int;

	private function get_matchCountProcessed():Int {
		return this._matchCountProcessed;
	}

	private function set_matchCountProcessed(value:Int):Int {
		if (this._matchCountProcessed == value) {
			return this._matchCountProcessed;
		}
		this._matchCountProcessed = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._matchCountProcessed;
	}

	private var _filesCount:Int = 0;

	@:flash.property
	public var filesCount(get, set):Int;

	private function get_filesCount():Int {
		return this._filesCount;
	}

	private function set_filesCount(value:Int):Int {
		if (this._filesCount == value) {
			return this._filesCount;
		}
		this._filesCount = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._filesCount;
	}

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.progressLabel = new Label();
		this.addChild(this.progressLabel);

		this.progressBar = new HProgressBar();
		this.addChild(this.progressBar);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.finishButton = new Button();
		this.finishButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.finishButton.text = "Finish";
		this.finishButton.enabled = false;
		this.finishButton.addEventListener(TriggerEvent.TRIGGER, finishButton_triggerHandler);
		footer.addChild(this.finishButton);

		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.progressLabel.text = 'Replaced: ${this._matchCountProcessed}';
			if (this._filesCount > 0) {
				this.progressBar.value = this._matchCountProcessed / this._filesCount;
			} else {
				this.progressBar.value = 0.0;
			}
			this.finishButton.enabled = this._matchCountProcessed >= this._filesCount;
		}

		super.update();
	}

	private function finishButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
