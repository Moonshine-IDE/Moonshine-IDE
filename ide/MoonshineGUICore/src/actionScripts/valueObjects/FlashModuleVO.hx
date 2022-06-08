package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;

class FlashModuleVO {
	public var sourcePath:FileLocation;

	private var _isSelected:Bool;

	public var isSelected(get, set):Bool;

	private function get_isSelected():Bool {
		return _isSelected;
	}

	private function set_isSelected(value:Bool):Bool {
		_isSelected = value;
		return _isSelected;
	}

	public function new(path:FileLocation = null, selected:Bool = true) {
		this.sourcePath = path;
		this.isSelected = selected;
	}
}