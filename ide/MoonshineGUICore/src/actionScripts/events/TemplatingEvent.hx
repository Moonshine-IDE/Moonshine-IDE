package actionScripts.events;

import actionScripts.factory.FileLocation;
import openfl.events.Event;

class TemplatingEvent extends Event {
	public static final ADDED_NEW_TEMPLATE:String = "ADDED_NEW_TEMPLATE";
	public static final REMOVE_TEMPLATE:String = "REMOVE_TEMPLATE";
	public static final RENAME_TEMPLATE:String = "RENAME_TEMPLATE";

	public var label:String;
	public var newLabel:String;
	public var newFileTemplate:FileLocation;
	public var listener:String;
	public var isProject:Bool;

	public function new(type:String, isProject:Bool, label:String, listener:String = null, newLabel:String = null, newFileTemplate:FileLocation = null) {
		this.isProject = isProject;
		this.label = label;
		this.newLabel = newLabel;
		this.newFileTemplate = newFileTemplate;
		this.listener = listener;

		super(type, false, false);
	}

	public override function clone():Event {
		return new TemplatingEvent(type, isProject, label, listener, newLabel);
	}
}