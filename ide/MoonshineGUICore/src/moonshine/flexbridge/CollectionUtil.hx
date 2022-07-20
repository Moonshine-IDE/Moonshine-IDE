package moonshine.flexbridge;

import feathers.data.ArrayCollection;
import mx.collections.ArrayCollection;
import mx.collections.ListCollectionView;

class CollectionUtil {
	/**
		Converts feathers.data.ArrayCollection to mx.collections.ArrayCollection.

		@param input ArrayCollection to convert
		@return The MX ArrayCollection
	**/
	public static function toMXArrayCollection<T>(input:feathers.data.ArrayCollection<T>):mx.collections.ArrayCollection {
		var result = new mx.collections.ArrayCollection();
		for (item in input)
			result.addItem(item);
		return result;
	}

	/**
		Converts feathers.data.ArrayCollection to mx.collections.XMLListCollection.

		@param input ArrayCollection to convert
		@return The XMLListCollection
	**/
	public static function toXMLListCollection<T>(input:feathers.data.ArrayCollection<T>):mx.collections.XMLListCollection {
		var result = new mx.collections.XMLListCollection();
		for (item in input)
			result.addItem(item);
		return result;
	}

	/**
		Converts mx.collections.ListCollectionView to feathers.data.ArrayCollection.

		@param input ListCollectionView to convert
		@return The FeathersUI Collection
	**/
	public static function fromMXCollection<T>(input:mx.collections.ListCollectionView):feathers.data.ArrayCollection<T> {
		var result = new feathers.data.ArrayCollection<T>();
		var a:Array<Dynamic> = input.toArray();
		for (item in a)
			result.add(item);
		return result;
	}
}
