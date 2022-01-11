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

package moonshine.plugin.help.view;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;

@:styleContext
class TourDeFlexHierarchicalItemRenderer extends HierarchicalItemRenderer {
	public function new() {
		super();
	}

	private var _currentActiveFileIndicator:DisplayObject;

	@:style
	public var activeFileIndicator:DisplayObject = null;

	private var _showActiveFileIndicator:Bool;

	@:flash.property
	public var showActiveFileIndicator(get, set):Bool;

	private function get_showActiveFileIndicator():Bool {
		return this._showActiveFileIndicator;
	}

	private function set_showActiveFileIndicator(value:Bool):Bool {
		if (this._showActiveFileIndicator == value) {
			return this._showActiveFileIndicator;
		}
		this._showActiveFileIndicator = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._showActiveFileIndicator;
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (stylesInvalid) {
			this.refreshActiveFileIndicator();
		}

		if (dataInvalid) {
			if (this._currentActiveFileIndicator != null) {
				this._currentActiveFileIndicator.visible = this._showActiveFileIndicator;
			}
		}

		super.update();
	}

	private function refreshActiveFileIndicator():Void {
		if (this.activeFileIndicator == this._currentActiveFileIndicator) {
			return;
		}
		if (this._currentActiveFileIndicator != null) {
			this.removeChild(this._currentActiveFileIndicator);
		}
		this._currentActiveFileIndicator = this.activeFileIndicator;
		if (this._currentActiveFileIndicator != null) {
			this.addChild(this._currentActiveFileIndicator);
		}
	}

	override private function layoutContent():Void {
		super.layoutContent();

		if (this._currentActiveFileIndicator != null) {
			if (Std.isOfType(this._currentActiveFileIndicator, IValidating)) {
				cast(this._currentActiveFileIndicator, IValidating).validateNow();
			}
			this._currentActiveFileIndicator.x = this.textField.x - this._currentActiveFileIndicator.width - 4.0;
			this._currentActiveFileIndicator.y = this.textField.y + (this.textField.height - this._currentActiveFileIndicator.height) / 2.0;
		}
	}
}
