package classes.events
{
    import org.apache.royale.events.Event;

	public class DeleteItemEvent extends Event 
	{
		public static const DELETE_TABLE_ITEM:String = "deleteTableItem";
		
		public function DeleteItemEvent(type:String, item:Object)
		{
			super(type, false, false);
			
			this.item = item;
		}
		
		private var _item:Object;

		public function get item():Object
		{
			return _item;
		}

		public function set item(value:Object):void
		{
			_item = value;
		}
	}
}