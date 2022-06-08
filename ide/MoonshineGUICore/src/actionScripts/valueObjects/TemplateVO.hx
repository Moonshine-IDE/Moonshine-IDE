package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;

class TemplateVO {
	public var title:String;
	public var homeTitle:String;
	public var description:String;
	public var logoImagePath:String;
	public var file:FileLocation;
	public var displayHome:Bool;

	public function new() {}
}