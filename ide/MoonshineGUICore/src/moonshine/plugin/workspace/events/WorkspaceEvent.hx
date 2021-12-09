package moonshine.plugin.workspace.events;

import openfl.events.Event;

class WorkspaceEvent extends Event {
	public static final NEW_WORKSPACE_WITH_LABEL:String = "newWorkspaceWithLabel";
	
	public function new(type:String, workspaceLabel:String) {
		super(type);
		
		this.workspaceLabel = workspaceLabel;
	}
	
	public var workspaceLabel:String;
	
	override public function clone():Event {
		return new WorkspaceEvent(this.type, this.workspaceLabel);
	}
}