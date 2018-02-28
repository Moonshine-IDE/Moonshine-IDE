package awaybuilder.utils
{
	import awaybuilder.utils.interfaces.IMergeable;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;

	public final class DataMerger
	{
		// TODO: make comparePropertyName not required, so items themselves will be compared
		/**
		 * Syncs given arrays.
		 * Rules:
		 * if item from new array is exist in originalList, then all properties of the item is copied to the old item.
		 * if item from new array does'nt exist in originalList - it is added to the end of the originalList array
		 * if item from originalList array doesn't exist in new array, then item is being removed from originalList array (if allowRemove parameter is true).
		 * @param originalList can be Array, Vector or IList
		 * @param newList can be Array, Vector or IList
		 * @param comparePropertyName property name to compare items. It must exist on each item. Property contents will be converted to string before comparing.
		 * @param mergeFunction Function that will be invoked each time when equal items will be found.
		 * @param allowRemove If true, then all items that are not exist in new array will be removed in originalList one.
		 * it must accept 2 arguments: function(originalItem:*, newItem:*)
		 * 
		 */
		public static function syncArrays(originalList:*, newList:*, comparePropertyName:String, mergeFunction:Function = null, allowRemove:Boolean = true):*
		{
			
			if(allowRemove)
				removeNonExistingItems(originalList, newList, comparePropertyName);
			var item:*;
			var oldItem:*;
			var itemsMap:Dictionary = new Dictionary();
			for each(item in originalList)
			{
				itemsMap[ item[comparePropertyName] ] = item;
			}
			for each(item in newList)
			{
				oldItem = itemsMap[ item[comparePropertyName] ];
				
				if(oldItem)
				{
					if(oldItem != item)
					{
						if(mergeFunction is Function)
							mergeFunction(oldItem, item);
						else if(oldItem is IMergeable)
							IMergeable(oldItem).merge(item);
					}
				}
				else
				{
					switch(true)
					{
						case originalList is IList:
							originalList.addItem(item);
							break;
						
						default:
							originalList.push(item);
					}
				}
			}
			return originalList;
		}
		public static function syncArrayCollections(originalList:ArrayCollection, newList:ArrayCollection, comparePropertyName:String, mergeFunction:Function = null, allowRemove:Boolean = true):ArrayCollection
		{
			if( originalList.length == 0 )
			{
				originalList = new ArrayCollection( newList.source );
				return originalList;
			}
			return syncArrays( originalList, newList, comparePropertyName, mergeFunction, allowRemove );
		}
		/**
		 * Will remove all items from originalList which are not exist in referenceList.
		 * Comparing will be performed by comparePropertyName
		 * @param originalList can be Array, Vector or IList
		 * @param referenceList can be Array, Vector or IList
		 * @param comparePropertyName
		 * @return
		 */
		private static function removeNonExistingItems(originalList:*, referenceList:*, comparePropertyName:String):void
		{
			var item:*;
			var itemsMap:Dictionary = new Dictionary();
			
			var itemsToRemove:Array = [];
			
			for each(item in referenceList)
			{
				itemsMap[ item[comparePropertyName] ] = item;
			}
			
			for each(item in originalList)
			{
				if(!itemsMap[item[comparePropertyName]])
				{
					itemsToRemove.push(item);
				}
			}
			
			var i:int;
			switch(true)
			{
				case originalList is IList:
					for each(item in itemsToRemove)
				{
					i = originalList.getItemIndex(item);
					if(i > -1)
						originalList.removeItemAt(i);
				}
					break;
				
				default:
					for each(item in itemsToRemove)
				{
					i = originalList.indexOf(item);
					if(i > -1)
						originalList.splice(i, 1);
				}
			}
		}
	}
}