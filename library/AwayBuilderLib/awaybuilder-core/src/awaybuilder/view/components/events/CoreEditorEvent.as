package awaybuilder.view.components.events
{
	import flash.events.Event;

	public class CoreEditorEvent extends Event
	{
		
		public function CoreEditorEvent(type:String, data:Object )
		{
			super(type, false, false);
			this.data = data;
		}
		
		public var data:Object;
		
	}
}