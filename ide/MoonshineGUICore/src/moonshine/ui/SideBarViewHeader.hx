/*
	Copyright 2020 Prominic.NET, Inc.

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

package moonshine.ui;

import openfl.events.Event;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayoutData;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.layout.HorizontalLayout;
import feathers.core.InvalidationFlag;
import feathers.controls.LayoutGroup;

@:styleContext
class SideBarViewHeader extends LayoutGroup {
	public static final CHILD_VARIANT_TITLE = "sideBarViewHeader--title";
	public static final CHILD_VARIANT_CLOSE_BUTTON = "sideBarViewHeader--closeButton";

	public function new() {
		super();
	}

	@:flash.property
	public var title(default, set):String;

	private function set_title(value:String):String {
		if (this.title == value) {
			return this.title;
		}
		this.title = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.title;
	}

	@:flash.property
	public var closeEnabled(default, set):Bool;

	private function set_closeEnabled(value:Bool):Bool {
		if (this.closeEnabled == value) {
			return this.closeEnabled;
		}
		this.closeEnabled = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this.closeEnabled;
	}

	private var titleLabel:Label;
	private var closeButton:Button;

	override private function initialize():Void {
		if (this.titleLabel == null) {
			this.titleLabel = new Label();
			this.titleLabel.variant = CHILD_VARIANT_TITLE;
			this.addChild(this.titleLabel);
		}
		if (this.closeButton == null) {
			this.closeButton = new Button();
			this.closeButton.variant = CHILD_VARIANT_CLOSE_BUTTON;
			this.closeButton.focusEnabled = false;
			this.closeButton.addEventListener(TriggerEvent.TRIGGER, closeButton_triggerHandler);
			this.addChild(this.closeButton);
		}
		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.updateTitle();
			this.updateCloseButton();
		}

		super.update();
	}

	private function updateTitle():Void {
		this.titleLabel.text = this.title;
	}

	private function updateCloseButton():Void {
		this.closeButton.enabled = this.enabled && this.closeEnabled;
		this.closeButton.visible = this.closeEnabled;
		this.closeButton.includeInLayout = this.closeEnabled;
	}

	private function closeButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
