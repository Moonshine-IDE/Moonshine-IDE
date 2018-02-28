package awaybuilder.desktop.controller.events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class OpenFromInvokeEvent extends Event
	{
		public static const OPEN_FROM_INVOKE:String = "openFromInvoke";
		
		public function OpenFromInvokeEvent(type:String, file:File)
		{
			super(type, false, false);
			this.file = file;
		}
		
		public var file:File;
		
		override public function clone():Event
		{
			return new OpenFromInvokeEvent(this.type, this.file);
		}
	}
}