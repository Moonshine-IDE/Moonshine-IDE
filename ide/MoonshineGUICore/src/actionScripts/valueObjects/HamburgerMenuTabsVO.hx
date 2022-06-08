package actionScripts.valueObjects;

import openfl.display.DisplayObject;

class HamburgerMenuTabsVO {
	public var label:String;
	public var tabData:DisplayObject;
	public var visibleIndex:Int;

	public function new(label:String, tabData:DisplayObject, visibleIndex:Int = -1) {
		this.label = label;
		this.tabData = tabData;
		this.visibleIndex = visibleIndex;
	}
}