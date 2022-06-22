package moonshine.utils.data;

import mx.collections.ArrayCollection;
import feathers.data.ArrayCollection;

class ArrayCollectionUtil {
	public static function toMXCollection<T>(input:feathers.data.ArrayCollection<T>):mx.collections.ArrayCollection {
		var mxc = new mx.collections.ArrayCollection();

		for (item in input) {
			mxc.addItem(item);
		}

		return mxc;
	}

	public static function fromMXCollection<T>(input:mx.collections.ArrayCollection):feathers.data.ArrayCollection<T> {
		var ac = new feathers.data.ArrayCollection<T>();

		var a:Array<Dynamic> = input.toArray();

		for (item in a) {
			ac.add(item);
		}

		return ac;
	}
}