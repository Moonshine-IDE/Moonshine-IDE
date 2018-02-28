package awaybuilder.controller.events
{
	import flash.events.Event;
	
	public class MessageBoxEvent extends Event
	{
		public static const SHOW_MESSAGE_BOX:String = "showMessageBox";
		
		public function MessageBoxEvent(type:String, title:String, message:String,
			okLabel:String, okCallback:Function = null,
			cancelLabel:String = null, cancelCallback:Function = null)
		{
			super(type, false, false);
			this.title = title;
			this.message = message;
			this.okLabel = okLabel;
			this.okCallback = okCallback;
			this.cancelLabel = cancelLabel;
			this.cancelCallback = cancelCallback;
		}
		
		public var title:String;
		public var message:String;
		public var okLabel:String;
		public var cancelLabel:String;
		public var okCallback:Function;
		public var cancelCallback:Function;
		
		override public function clone():Event
		{
			return new MessageBoxEvent(this.type, this.title, this.message, this.okLabel, this.okCallback, this.cancelLabel, this.cancelCallback);
		}
	}
}