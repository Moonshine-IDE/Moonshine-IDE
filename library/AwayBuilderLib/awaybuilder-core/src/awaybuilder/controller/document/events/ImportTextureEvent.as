package awaybuilder.controller.document.events
{
	import flash.events.Event;

	public class ImportTextureEvent extends Event
	{
		public static const IMPORT_AND_BITMAP_REPLACE:String = "importBitmapAndRplace";
		
		public static const IMPORT_AND_ADD:String = "importTextureForMaterial";
		
		public function ImportTextureEvent( type:String, items:Array, options:Object=null )
		{
			super( type );
			this.items = items;
			this.options = options;
		}
		
		public var items:Array;
		public var options:Object;
		
		override public function clone():Event
		{
			return new ImportTextureEvent(this.type, this.items, this.options );
		}
	}
}