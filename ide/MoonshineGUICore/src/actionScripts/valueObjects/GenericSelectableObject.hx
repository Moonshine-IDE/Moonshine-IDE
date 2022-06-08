package actionScripts.valueObjects;

class GenericSelectableObject {
	public var data:Dynamic;
	public var isSelected:Bool;

	public function new(isSelcted:Bool = false, data:Dynamic = null) {
		this.isSelected = isSelcted;
		this.data = data;
	}
}