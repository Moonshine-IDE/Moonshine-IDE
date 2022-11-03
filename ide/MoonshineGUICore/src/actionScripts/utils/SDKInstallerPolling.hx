package actionScripts.utils;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.StartupHelperEvent;
import actionScripts.valueObjects.HelperConstants;
import flash.filesystem.File;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class SDKInstallerPolling extends EventDispatcher {
	private static var instance:SDKInstallerPolling;

	public static function getInstance():SDKInstallerPolling {
		if (instance == null)
			instance = new SDKInstallerPolling();
		return instance;
	}

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
	private var pollingTimer:Timer;

	public var notifierFileLocation(get, never):File;

	private function get_notifierFileLocation():File {
		return File.applicationStorageDirectory.resolvePath(HelperConstants.MOONSHINE_NOTIFIER_FILE_NAME);
	}

	public function new() {
		super();
	}

	public function startPolling():Void {
		stopPolling();

		pollingTimer = new Timer(10000);
		pollingTimer.addEventListener(TimerEvent.TIMER, onPollTimerTick);
		pollingTimer.start();
		onPollTimerTick(null);
	}

	public function stopPolling():Void {
		if (pollingTimer != null && pollingTimer.running) {
			pollingTimer.stop();
			pollingTimer.removeEventListener(TimerEvent.TIMER, onPollTimerTick);
			pollingTimer = null;
		}
	}

	private function onPollTimerTick(event:TimerEvent):Void {
		if (notifierFileLocation.exists) {
			dispatcher.dispatchEvent(new StartupHelperEvent(StartupHelperEvent.EVENT_SDK_INSTALLER_NOTIFIER_NOTIFICATION));
		}
	}
}