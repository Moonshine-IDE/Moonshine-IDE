////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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