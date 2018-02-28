package awaybuilder.controller.events
{
	import awaybuilder.model.vo.scene.AssetVO;
	
	import flash.events.Event;
	
	public class DocumentModelEvent extends Event
	{
		public static const DOCUMENT_NAME_CHANGED:String = "documentNameChanged";
		public static const DOCUMENT_EDITED:String = "documentEdited";
		public static const DOCUMENT_CREATED:String = "documentCreated";
		public static const OBJECTS_UPDATED:String = "objectsUpdated";
		
		public static const VALIDATE_OBJECT:String = "validateObject";
		
		public static const OBJECTS_COLLECTION_UPDATED:String = "objectsColelctionUpdated";
		public static const OBJECTS_FILLED:String = "objectsFilled";
		public static const CLIPBOARD_UPDATED:String = "clipboardUpdated";
		
		public function DocumentModelEvent(type:String, asset:AssetVO=null)
		{
			super(type, false, false);
			this.asset = asset;
		}
		
		public var asset:AssetVO;
		
		override public function clone():Event
		{
			return new DocumentModelEvent(this.type);
		}
	}
}