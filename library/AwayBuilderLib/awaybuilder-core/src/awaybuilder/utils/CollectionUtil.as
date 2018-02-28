package awaybuilder.utils
{
	import awaybuilder.model.vo.scene.AssetVO;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	public class CollectionUtil
	{
		private static var collections:Dictionary = new Dictionary();
		
		public static function sync( collection:ArrayCollection, source:ArrayCollection, addItemFunction:Function ):void
		{
			collections[source] = {collection:collection, addItemFunction:addItemFunction};
			source.addEventListener(CollectionEvent.COLLECTION_CHANGE, source_collectionChangeHandler );
		}
		
		private static function source_collectionChangeHandler( event:CollectionEvent ):void
		{
			var collection:ArrayCollection = collections[event.target].collection as ArrayCollection;
			var addItemFunction:Function = collections[event.target].addItemFunction as Function;
			var position:int = event.location;
			var item:Object;
			switch( event.kind )
			{
				case CollectionEventKind.ADD:
					for each( item in event.items )
					{
						collection.addItemAt( addItemFunction( item ), position++ );
					}
					break;
				case CollectionEventKind.MOVE:
					collection.addItemAt(collection.removeItemAt(event.oldLocation), event.location );
					break;
				case CollectionEventKind.REFRESH:
					collection.refresh();
					break;
				case CollectionEventKind.REMOVE:
					for each( item in event.items )
					{
						collection.removeItemAt( position );
					}
					break;
				case CollectionEventKind.REPLACE:
					collection.setItemAt( item, event.location );
					break;
				case CollectionEventKind.RESET:
					break;
				case CollectionEventKind.UPDATE:
					break;
			}
			trace( event.kind + " " + event.items , "collection = " + collection );
		}
	}
}