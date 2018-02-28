package awaybuilder.desktop.utils
{
	import flash.events.Event;
	
	import mx.events.AIREvent;
	
	import spark.components.Window;

	public class ModalityManager
	{
		public static const modalityManager:ModalityManager = new ModalityManager();
		
		public function ModalityManager()
		{
		}
		
		private var _modalWindows:Vector.<Window> = new <Window>[];
		
		public function get modalWindowCount():int
		{
			return this._modalWindows.length;
		}
		
		public function addModalNature(window:Window):void
		{
			var index:int = this._modalWindows.indexOf(window);
			if(index >= 0)
			{
				throw new ArgumentError("Window is already modal!");
			}
			
			window.addEventListener(AIREvent.APPLICATION_ACTIVATE, window_applicationActivateHandler);
			window.addEventListener(AIREvent.WINDOW_DEACTIVATE, window_windowDeactivateHandler);
			window.addEventListener(Event.CLOSE, window_closeHandler);
			this._modalWindows.push(window);
		}
		
		public function removeModalNature(window:Window):void
		{
			var index:int = this._modalWindows.indexOf(window);
			if(index < 0)
			{
				throw new ArgumentError("Window is not modal. Cannot remove modal nature.");
			}
			this._modalWindows.splice(index, 1);
			window.removeEventListener(AIREvent.APPLICATION_ACTIVATE, window_applicationActivateHandler);
			window.removeEventListener(AIREvent.WINDOW_DEACTIVATE, window_windowDeactivateHandler);
			window.removeEventListener(Event.CLOSE, window_closeHandler);
		}
		
		private function window_closeHandler(event:Event):void
		{
			var window:Window = Window(event.currentTarget);
			this.removeModalNature(window);
		}
		
		private function bringToFront(window:Window):void
		{
			//we need to check for the stage because the window may have closed
			//but not necessarily detectable otherwise
			if(window.stage && window.visible)
			{
				window.activate();
			}
		}
		
		private function window_applicationActivateHandler(event:AIREvent):void
		{
			var window:Window = Window(event.currentTarget);
			window.orderToFront();
			window.callLater(bringToFront, [window]);
		}
		
		private function window_windowDeactivateHandler(event:AIREvent):void
		{
			var window:Window = Window(event.currentTarget);
			window.orderToFront();
			window.callLater(bringToFront, [window]);
		}
	}
}