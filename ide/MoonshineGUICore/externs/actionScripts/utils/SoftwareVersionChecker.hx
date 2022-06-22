package actionScripts.utils;

import mx.collections.ArrayCollection;
import openfl.events.Event;

extern class SoftwareVersionChecker {
	public static inline final VERSION_CHECK_TYPE_SDK:String = "versionCheckTypeSDKs";
	public static inline final VERSION_CHECK_TYPE_EDITOR:String = "versionCheckTypeEditors";

	public var versionCheckType:String;

	public function new();
	public function addEventListener(evetType:String, callback:(Event) -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	public function removeEventListener(evetType:String, callback:(Event) -> Void):Void;
	public function retrieveSDKsInformation(items:ArrayCollection):Void;
	public function retrieveEditorsInformation(items:ArrayCollection):Void;
	public function dispose():Void;
}