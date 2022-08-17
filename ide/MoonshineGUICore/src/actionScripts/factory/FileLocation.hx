package actionScripts.factory;

import actionScripts.controllers.DataAgent;
import actionScripts.interfaces.IFileBridge;
import actionScripts.locator.IDEModel;
import actionScripts.valueObjects.URLDescriptorVO;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class FileLocation extends EventDispatcher {
	public var fileBridge:IFileBridge;
	public var name(get, never):String;

	public function new(path:String = null, isURL:Bool = false) {
		// ** IMPORTANT **
		fileBridge = BridgeFactory.getFileInstanceObject();
		if (path == null) {
			path = IDEModel.getInstance().fileCore.nativePath;
			return;
		}

		if (isURL) {
			fileBridge.url = path;
		} else {
			fileBridge.nativePath = path;
		}

		super();
	}

	public function resolvePath(path:String):FileLocation {
		return fileBridge.resolvePath(path);
	}

	private function get_name():String {
		return fileBridge.name;
	}

	//--------------------------------------------------------------------------
	//
	//  WEB METHODS
	//
	//--------------------------------------------------------------------------

	public function deleteFileOrDirectory():Void {
		var tmpLoader:DataAgent = new DataAgent(URLDescriptorVO.FILE_REMOVE, onSuccessDelete, onFault, {path: fileBridge.nativePath}, DataAgent.POSTEVENT, 0,
			true);
	}

	private function onSuccessDelete(value:Dynamic, message:String = null):Void {
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function onFault(message:String = null):Void {
		dispatchEvent(new Event(Event.CLOSE));
	}
}