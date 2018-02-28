package awaybuilder.desktop.view.mediators
{
	import flash.events.Event;
	
	import awaybuilder.desktop.utils.ModalityManager;
	import awaybuilder.desktop.view.components.MessageBox;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class MessageBoxMediator extends Mediator
	{
		[Inject]
		public var window:MessageBox;
		
		override public function onRegister():void
		{
			ModalityManager.modalityManager.addModalNature(this.window);
			this.eventMap.mapListener(this.window.content, Event.COMPLETE, content_completeHandler);
			this.eventMap.mapListener(this.window.content, Event.CANCEL, content_cancelHandler);
			this.eventMap.mapListener(this.window, Event.CLOSING, window_closingHandler);
		}
		
		private function content_completeHandler(event:Event):void
		{
			this.window.close();
		}
		
		private function content_cancelHandler(event:Event):void
		{
			this.window.close();
		}
		
		private function window_closingHandler(event:Event):void
		{
			this.mediatorMap.removeMediator(this);
		}
	}
}