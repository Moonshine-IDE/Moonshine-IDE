package actionScripts.events
{
	import flash.events.Event;
	import actionScripts.valueObjects.Command;

	public class CodeActionsEvent extends Event
	{
		public static const EVENT_SHOW_CODE_ACTIONS:String = "newShowCodeActions";
		
		public var codeActions:Vector.<Command>;
		
		public function CodeActionsEvent(type:String, codeActions:Vector.<Command>)
		{
			super(type, false, false);
			this.codeActions = codeActions;
		}
	}
}
