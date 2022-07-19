package moonshine.utils.flexbridge;

import feathers.data.ArrayCollection;
import mx.collections.ArrayCollection;

class ArrayCollectionUtil {
	/**
		Converts feathers.data.ArrayCollection to mx.collections.ArrayCollection.

		@param input ArrayCollection to convert
		@return The MX collection
	**/
	public static function toMXCollection<T>(input:feathers.data.ArrayCollection<T>):mx.collections.ArrayCollection {
		var mxc = new mx.collections.ArrayCollection();
		for (item in input)
			mxc.addItem(item);
		return mxc;
	}

	/**
		Converts mx.collections.ArrayCollection to feathers.data.ArrayCollection.

		@param input ArrayCollection to convert
		@return The FeathersUI Collection
	**/
	public static function fromMXCollection<T>(input:mx.collections.ArrayCollection):feathers.data.ArrayCollection<T> {
		var ac = new feathers.data.ArrayCollection<T>();
		var a:Array<Dynamic> = input.toArray();
		for (item in a)
			ac.add(item);
		return ac;
	}
}