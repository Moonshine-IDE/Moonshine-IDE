/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

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
