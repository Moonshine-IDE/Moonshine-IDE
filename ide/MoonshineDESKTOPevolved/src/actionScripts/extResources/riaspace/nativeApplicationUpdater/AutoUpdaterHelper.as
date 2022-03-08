package actionScripts.extResources.riaspace.nativeApplicationUpdater
{
	import actionScripts.events.GlobalEventDispatcher;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	
	import actionScripts.events.GeneralEvent;
	
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;

	import mx.events.CloseEvent;

	[Event(name="DONE", type="actionScripts.events.GeneralEvent")]
	public class AutoUpdaterHelper extends EventDispatcher
	{
		public static const EVENT_UPDATE_CHECK_COMPLETES:String = "eventUpdateCheckCompletes";

		[Bindable] public var downlaoding:Boolean = false;
		[Bindable] public var isUpdater:int = -1;
		
		private var _updater:NativeApplicationUpdater;
		public function get updater():NativeApplicationUpdater
		{
			return _updater;
		}
		public function set updater(value:NativeApplicationUpdater):void
		{
			_updater = value;
		}
		
		public function AutoUpdaterHelper()
		{
		}
		
		public function isNewerFunction(currentVersion:String, updateVersion:String):Boolean
		{
			// Example of custom isNewerFunction function, it can be omitted if one doesn't want
			// to implement it's own version comparison logic. Be default it does simple string
			// comparison.
			return true;
		}
		
		public function updater_errorHandler(event:ErrorEvent):void
		{
			dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
		}
		
		public function updater_initializedHandler(event:UpdateEvent):void
		{
			// When NativeApplicationUpdater is initialized you can call checkNow function
			updater.checkNow();
		}

		public function updater_updateStatusHandler(event:StatusUpdateEvent):void
		{
			if (event.available)
			{
				// In case update is available prevent default behavior of checkNow() function 
				// and switch to the view that gives the user ability to decide if he wants to
				// install new version of the application.
				event.preventDefault();
				//currentState = "Update";
				isUpdater = 1;
			}
			else
			{
				isUpdater = 0;
				//Alert.show("Your application is up to date!");
			}
		}
		
		public function btnNo_clickHandler(event:Event):void
		{
			isUpdater = 0;
		}

		public function btnCheck_CancelHandler(event:Event):void
		{
			updater.cancelUpdateCheck();
			isUpdater = 0;
		}
		
		public function btnCancel_clickHandler(event:Event):void
		{
			updater.cancelUpdate();
			isUpdater = 0;
			dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
		}
		
		public function btnYes_clickHandler(event:Event):void
		{
			// In case user wants to download and install update display download progress bar
			// and invoke downloadUpdate() function.
			downlaoding = true;
			updater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, updater_downloadCompleteHandler);
			updater.downloadUpdate();
		}
		
		private function updater_downloadCompleteHandler(event:UpdateEvent):void
		{
			// When update is downloaded install it.
			updater.installUpdate();
		}
	}
}