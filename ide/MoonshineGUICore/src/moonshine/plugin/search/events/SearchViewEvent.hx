package moonshine.plugin.search.events;

import actionScripts.valueObjects.ProjectVO;
import openfl.events.Event;

class SearchViewEvent extends Event 
{
	public static final SEARCH_PHRASE:String = "searchPhrase";
	public static final REPLACE_PHRASE:String = "replacePhrase";
	
	public function new(type:String, searchText:String)
	{
		super(type);
		
		this.searchText = searchText;
	}
	
	public var searchText:String = "";
	public var patternsText:String = "*";
	public var selectedSearchScopeIndex:Int;
	public var selectedProject:ProjectVO = null;
	public var matchCaseEnabled:Bool = false;
	public var regExpEnabled:Bool = false;
	public var escapeCharsEnabled:Bool = false;
	public var includeExternalSourcePath:Bool = false;
	
	override public function clone():Event {
		return new SearchViewEvent(this.type, this.searchText);
	}
}