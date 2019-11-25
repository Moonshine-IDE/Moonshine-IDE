package actionScripts.events
{
	import flash.events.Event;
	import actionScripts.valueObjects.CodeAction;

	public class CodeActionsEvent extends Event
	{
		public static const EVENT_SHOW_CODE_ACTIONS:String = "newShowCodeActions";
		
		public var uri:String;
		public var codeActions:Vector.<CodeAction>;
		
		public function CodeActionsEvent(type:String, uri:String, codeActions:Vector.<CodeAction>)
		{
			super(type, false, false);
			this.uri = uri;
			this.codeActions = codeActions;
		}
	}
}
