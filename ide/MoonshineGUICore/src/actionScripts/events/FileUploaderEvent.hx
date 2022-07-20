package actionScripts.events;

import openfl.events.Event;

class FileUploaderEvent extends Event {
	public static final EVENT_UPLOAD_LOADED:String = "eventUploadLoaded";
	public static final EVENT_UPLOAD_COMPLETE_DATA:String = "eventUploadCompleteData";
	public static final EVENT_UPLOAD_CANCELED:String = "eventUploadCanceled";
	public static final EVENT_UPLOAD_PROGRESS:String = "eventUploadProgress";
	public static final EVENT_UPLOAD_ERROR:String = "eventUploadError";
	public static final EVENT_UPLOAD_COMPLETE:String = "eventUploadComplete";

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, _bubble:Bool = false, _cancelable:Bool = true) {
		this.value = value;
		super(type, _bubble, _cancelable);
	}
}