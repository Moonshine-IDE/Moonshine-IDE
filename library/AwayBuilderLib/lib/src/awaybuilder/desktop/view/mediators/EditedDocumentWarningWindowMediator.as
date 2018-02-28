package awaybuilder.desktop.view.mediators
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import awaybuilder.desktop.utils.ModalityManager;
	import awaybuilder.desktop.view.components.EditedDocumentWarningWindow;
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.ApplicationModel;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditedDocumentWarningWindowMediator extends Mediator
	{	
		private static const ACTION_SAVE:String = "actionSave";
		private static const ACTION_NO_SAVE:String = "actionNoSave";
		
		[Inject]
		public var window:EditedDocumentWarningWindow;
		
		[Inject]
		public var documentModel:DocumentModel;
		
		[Inject]
		public var windowModel:ApplicationModel;
		
		private var _actionChosen:String = null;
		
		override public function onRegister():void
		{
			this.window.documentName = this.documentModel.name;
			this.window.validateNow();
			this.window.height = this.window.measuredHeight;
			ModalityManager.modalityManager.addModalNature(this.window);
			
			this.eventMap.mapListener(this.window, EditedDocumentWarningWindow.SAVE_DOCUMENT, window_saveDocumentHandler);
			this.eventMap.mapListener(this.window, EditedDocumentWarningWindow.NO_SAVE_DOCUMENT, window_noSaveDocumentHandler);
			this.eventMap.mapListener(this.window, Event.CANCEL, window_cancelHandler);
			this.eventMap.mapListener(this.window, Event.CLOSING, window_closingHandler);
		}
		
		private function window_saveDocumentHandler(event:Event):void
		{
			this._actionChosen = ACTION_SAVE;
			this.window.close();
		}
			
		private function window_noSaveDocumentHandler(event:Event):void
		{
			this._actionChosen = ACTION_NO_SAVE;
			this.window.close();
		}
		
		private var _timer:Timer = new Timer(250);
		
		private function window_closingHandler(event:Event):void
		{
			//AIR sucks. We have to do this to ensure that the main window will
			//close and not detect this.window as an open window.
			this._timer = new Timer(250, 1);
			this._timer.addEventListener(TimerEvent.TIMER_COMPLETE, closeTimer_timerCompleteHandler);
			this._timer.start();
		}
		
		private function closeTimer_timerCompleteHandler(event:TimerEvent):void
		{
			this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE, closeTimer_timerCompleteHandler);
			this._timer = null;
			this.delayedAction();
		}
		
		private function delayedAction():void
		{
			//because awaybuilderDesktopMediator requires all windows be closed,
			//we cannot dispatch this saved event until this window has closed
			//completely.
			if(this._actionChosen == null)
			{
				this.windowModel.isWaitingForClose = false;
			}
			else if(this._actionChosen == ACTION_SAVE)
			{
				this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT));
			}
			else if(this._actionChosen == ACTION_NO_SAVE && this.windowModel.savedNextEvent)
			{
				var nextEvent:Event = this.windowModel.savedNextEvent;
				this.windowModel.savedNextEvent = null;
				this.dispatch(nextEvent);
			}
			this.mediatorMap.removeMediator(this);
		}
		
		private function window_cancelHandler(event:Event):void
		{
			this.window.close();
		}
	}
}