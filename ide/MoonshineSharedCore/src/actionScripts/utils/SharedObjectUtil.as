////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
    import flash.net.SharedObject;
    import actionScripts.interfaces.IFileBridge;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.locator.IDEModel;

    public class SharedObjectUtil
	{
		public static function saveProjectTreeItemForOpen(item:Object, propertyNameKey:String,
                                                          propertyNameKeyValue:String):void
		{
			var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
			if (!cookie.data.projectTree)
			{
				cookie.data.projectTree = [];
			}

			saveProjectItem(item, propertyNameKey, propertyNameKeyValue, "projectTree");
		}
		
		public static function removeProjectTreeItemFromOpenedItems(item:Object, propertyNameKey:String,
                                                                    propertyNameKeyValue:String):void
		{
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var projectTree:Array = cookie.data.projectTree;
            if (!projectTree) return;

			removeProjectItem(item, propertyNameKey, propertyNameKeyValue, "projectTree");
		}

		public static function saveLocationOfOpenedProjectFile(fileName:String, filePath:String):void
		{
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
			var activeProject:ProjectVO = IDEModel.getInstance().activeProject;
			if (!activeProject) return;
			
			var cookieName:String = "projectFiles" + activeProject.name;
            if (!cookie.data[cookieName])
            {
                cookie.data[cookieName] = [];
            }

            saveProjectItem({name: fileName, path: filePath}, "name", "path", cookieName);
		}

		public static function removeLocationOfClosingProjectFile(fileName:String, filePath:String):void
		{
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var activeProject:ProjectVO = IDEModel.getInstance().activeProject;
			if (!activeProject) return;

			removeProjectItem({name: fileName, path: filePath}, "name", "path", "projectFiles" + activeProject.name);
		}

		private static function saveProjectItem(item:Object, propertyNameKey:String,
                                                propertyNameKeyValue:String, cookieName:String):void
		{
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            if (item && item.hasOwnProperty(propertyNameKeyValue) && item.hasOwnProperty(propertyNameKey))
            {
                var hasItemForOpen:Boolean = cookie.data[cookieName].some(
                        function hasSomeItemForOpen(itemForOpen:Object, index:int, arr:Array):Boolean
                        {
                            return itemForOpen.hasOwnProperty(item[propertyNameKey]) && itemForOpen[item[propertyNameKey]] == item[propertyNameKeyValue];
                        });

                if (!hasItemForOpen)
                {
                    var itemForSave:Object = {};
                    itemForSave[item[propertyNameKey]] = item[propertyNameKeyValue];
                    cookie.data[cookieName].push(itemForSave);

                    cookie.flush();
                }
            }
		}

		private static function removeProjectItem(item:Object, propertyNameKey:String,
                                                  propertyNameKeyValue:String, cookieName:String):void
		{
			var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);

            if (item && item.hasOwnProperty(propertyNameKeyValue) && item.hasOwnProperty(propertyNameKey))
            {
				var data:Object = cookie.data;
                for (var i:int = 0; i < data[cookieName].length; i++)
                {
                    var itemForRemove:Object = data[cookieName][i];
                    if (itemForRemove.hasOwnProperty(item[propertyNameKey]) &&
                            itemForRemove[item[propertyNameKey]] == item[propertyNameKeyValue])
                    {
                        data[cookieName].removeAt(i);
                        cookie.flush();
                        break;
                    }
                }
            }
		}
	}
}