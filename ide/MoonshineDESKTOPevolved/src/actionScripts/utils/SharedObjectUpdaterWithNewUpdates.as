////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.utils.describeType;
	
	import mx.collections.IList;
	import mx.utils.ObjectUtil;

	public class SharedObjectUpdaterWithNewUpdates
	{
		public static function isValidForNewUpdate(updateDate:Date):Boolean
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.SHARED_UPDATE_CHECKER);
			if (cookie.data.hasOwnProperty('objectsTested'))
			{
				var lastSavedOn:Date = new Date(Date.parse(cookie.data.objectsTested));
				if (ObjectUtil.dateCompare(updateDate, lastSavedOn) == 1)
				{
					return true;
				}
			}
			else if (!cookie.data.hasOwnProperty('objectsTested'))
			{
				return true;
			}
			
			return false;
		}
		
		public static function syncWithNewUpdates(sharedCollection:IList, updatedCollection:IList, primaryField:String):IList
		{
			var itemInUpdatedCollection:Object;
			var describedType:XML;
			var updatedItem:Object;
			var sharedItem:Object;
			
			// updating the existing items
			for each (sharedItem in sharedCollection)
			{
				itemInUpdatedCollection = null;
				for each (updatedItem in updatedCollection)
				{
					if (updatedItem[primaryField] == sharedItem[primaryField])
					{
						itemInUpdatedCollection = updatedItem;
						break;
					}
				}
				
				if (itemInUpdatedCollection)
				{
					if (!describedType) describedType = describeType(itemInUpdatedCollection);
					var localName:String;

					// do not update properties which 
					// has changed value in shared object
					// as that probably changed by user him/herself
					for each (var propertyTag:XML in describedType.accessor)
					{
						if (String(propertyTag.@access) != "readonly")
						{
							localName = String(propertyTag.@name);
							if (localName == "installPath")
							{
								if (!sharedItem[localName] || 
									((sharedItem[localName] is File) && 
									!(sharedItem[localName] as File).exists))
								{
									sharedItem[localName] = itemInUpdatedCollection[localName];
								}
							}
							else
							{
								sharedItem[localName] = itemInUpdatedCollection[localName];
							}
						}
					}
				}
			}
			
			// addition of any newer item
			var isFound:Boolean;
			for each (updatedItem in updatedCollection)
			{
				isFound = false;
				for each (sharedItem in sharedCollection)
				{
					if (updatedItem[primaryField] == sharedItem[primaryField])
					{
						isFound = true;
						break;
					}
				}
				
				if (!isFound)
				{
					sharedCollection.addItem(updatedItem);
				}
			}
			
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.SHARED_UPDATE_CHECKER);
			cookie.data["objectsTested"] = (new Date()).toUTCString();
			cookie.flush();
			
			return sharedCollection;
		}
	}
}