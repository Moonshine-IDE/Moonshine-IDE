package moonshine.components.events;

import openfl.events.Event;

class FileTypesCalloutEvent extends Event
{	
	public static final SELECT_FILETYPE:String = "selectFileType";
	
	public function new(type:String, index:Int)
	{
		super(type);
		
		this.index = index;
	}
	
	public var index:Int = -1;
	
	override public function clone():Event {
		return new FileTypesCalloutEvent(this.type, this.index);
	}
}