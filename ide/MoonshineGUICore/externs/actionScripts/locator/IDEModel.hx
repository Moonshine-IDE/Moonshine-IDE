package actionScripts.locator;

import mx.collections.ArrayCollection;
import actionScripts.interfaces.IFileBridge;
import actionScripts.factory.FileLocation;

extern class IDEModel {
	public static function getInstance():IDEModel;

	public var antHomePath:FileLocation;
	public var defaultSDK:FileLocation;
	public var editors:ArrayCollection;
	public var fileCore:IFileBridge;
	public var gitPath:String;
	public var gradlePath:String;
	public var grailsPath:String;
	public var haxePath:String;
	public var java8Path:FileLocation;
	public var javaPathForTypeAhead:FileLocation;
	public var macportsPath:String;
	public var mavenPath:String;
	public var nekoPath:String;
	public var nodePath:String;
	public var notesPath:String;
	public var svnPath:String;
	public var vagrantPath:String;
    public var virtualBoxPath:String;

	public function getVersionWithBuildNumber():String;
}