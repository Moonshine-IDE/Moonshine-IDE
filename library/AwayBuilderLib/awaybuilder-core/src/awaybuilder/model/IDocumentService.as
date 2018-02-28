package awaybuilder.model
{
	import awaybuilder.controller.history.HistoryEvent;
	
	import flash.events.Event;
	
	public interface IDocumentService
	{
		function save(data:DocumentModel, path:String):void;
		function saveAs(data:DocumentModel, defaultName:String):void;
		
		function open( type:String, createNew:Boolean, event:Event ):void
		
		function openBitmap( items:Array, property:String ):void;
		
		function load( url:String, name:String, event:Event):void;
	}
}