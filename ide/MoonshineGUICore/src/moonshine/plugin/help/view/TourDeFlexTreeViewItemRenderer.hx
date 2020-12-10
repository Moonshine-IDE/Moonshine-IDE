package moonshine.plugin.help.view;

import feathers.core.IValidating;
import openfl.display.DisplayObject;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.TreeViewItemRenderer;

@:styleContext
class TourDeFlexTreeViewItemRenderer extends TreeViewItemRenderer {
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
			if (Std.is(this._currentActiveFileIndicator, IValidating)) {
				cast(this._currentActiveFileIndicator, IValidating).validateNow();
			}
			this._currentActiveFileIndicator.x = this.textField.x - this._currentActiveFileIndicator.width - 4.0;
			this._currentActiveFileIndicator.y = this.textField.y + (this.textField.height - this._currentActiveFileIndicator.height) / 2.0;
		}
	}
}
