package actionScripts.utils;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.ProjectEvent;
import actionScripts.events.SettingsEvent;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.help.HelpPlugin;
import mx.controls.Alert;
import mx.events.CloseEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class NoSDKNotifier extends EventDispatcher {
	public static final SDK_SAVED:String = "SDK_SAVED";
	public static final SDK_SAVE_CANCELLED:String = "SDK_SAVE_CANCELLED";

	private static var instance:NoSDKNotifier;
	private static var isShowing:Bool;

	public static function getInstance():NoSDKNotifier {
		if (instance == null)
			instance = new NoSDKNotifier();
		return instance;
	}

	private var isJavaCheckingRequires:Bool;

	public function new() {
		super();
	}

	public function notifyNoFlexSDK(isJavaCheckingRequires:Bool = true):Void {
		if (isShowing)
			return;

		var model:IDEModel = IDEModel.getInstance();
		var item:Dynamic = model.userSavedSDKs.getItemAt(0);
		if ((model.userSavedSDKs.length != 0) && (item != null) && (item.status == SDKUtils.BUNDLED)) {
			SDKUtils.setDefaultSDKByBundledSDK();
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.FLEX_SDK_UDPATED_OUTSIDE, item));
			return;
		}

		Alert.noLabel = "Do it later";
		Alert.yesLabel = "Fix this now";
		Alert.buttonWidth = 110;

		Alert.show("Moonshine detected no default SDK set!", "No SDK Found", Alert.YES | Alert.NO, null, alertClosed);
		this.isJavaCheckingRequires = isJavaCheckingRequires;
	}

	private function alertClosed(event:CloseEvent):Void {
		Alert.buttonWidth = 65;
		Alert.noLabel = "No";
		Alert.yesLabel = "Yes";

		if (event.detail == Alert.YES) {
			GlobalEventDispatcher.getInstance()
				.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin"));
		}

		if (isJavaCheckingRequires)
			GlobalEventDispatcher.getInstance().dispatchEvent(new Event(HelpPlugin.EVENT_ENSURE_JAVA_PATH));
		isShowing = false;
	}
}