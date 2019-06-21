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
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;
    import mx.utils.ObjectUtil;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectReferenceVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.RepositoryItemVO;
    import actionScripts.valueObjects.VersionControlTypes;

    public class SharedObjectUtil
	{
        public static function getMoonshineIDEProjectSO(name:String):SharedObject
        {
            var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var model:IDEModel = IDEModel.getInstance();
            if (name.indexOf("projectTree") > -1 && !model.openPreviouslyOpenedProjectBranches) return null;
            if (name.indexOf("projectFiles") > -1 && !model.openPreviouslyOpenedFiles) return null;
            if (name.indexOf("projects") > -1 && !model.openPreviouslyOpenedProjects) return null;
            
            for (var item:Object in cookie.data)
            {
                if (item.indexOf(name) > -1)
                {
                    return cookie;
                }
            }

            return null;
        }

        public static function resetMoonshineIdeProjectSO():void
        {
            var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            delete cookie.data["projectTree"];
            for (var item:Object in cookie.data)
            {
                delete cookie.data[item];
            }

            cookie.flush();
        }
		
		public static function getRepositoriesFromSO():ArrayCollection
		{
			var tmpCollection:ArrayCollection = new ArrayCollection();
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
			var tmpRepository:RepositoryItemVO;
			if (cookie.data.hasOwnProperty('savedRepositories'))
			{
				for each (var item:Object in cookie.data.savedRepositories)
				{
					tmpRepository = ObjectTranslator.objectToInstance(item, RepositoryItemVO) as RepositoryItemVO;
					if (tmpRepository.children) 
					{
						if (tmpRepository.type == VersionControlTypes.XML)
						{
							// only in the case of Git type
							// we shall parse children to parse saved
							// git-meta (#503)
							var children:Array = tmpRepository.children;
							var subRepository:RepositoryItemVO;
							tmpRepository.children = [];
							for each (var subItem:Object in children)
							{
								subRepository = ObjectTranslator.objectToInstance(subItem, RepositoryItemVO) as RepositoryItemVO;
								tmpRepository.children.push(subRepository);
							}
							
							// sort the items
							/*if (tmpRepository.children.length > 0)
							{
								tmpRepository.children.sortOn("url", Array.CASEINSENSITIVE);
							}*/
						}
						else
						{
							// in case of SVN we'll continue
							// to update children at runtime only
							tmpRepository.children = [];
						}
					}
					tmpCollection.addItem(tmpRepository);
				}
			}
			
			if (cookie.data.hasOwnProperty('defaultRepositoriesPopulated'))
			{
				ConstantsCoreVO.IS_DEFAULT_REPOSITORIES_POPULATED = true;
			}
			
			// add sorting by type
			tmpCollection.sort = new Sort([new SortField("type"), new SortField("url")]);
			tmpCollection.refresh();
			
			return tmpCollection;
		}
		
		public static function saveRepositoriesToSO(collection:ArrayCollection):void
		{
			var duplicate:ArrayCollection = ObjectUtil.copy(collection) as ArrayCollection;
			
			// we don't want to store children data
			// only in case of non-Git item type.
			// continue to save children to save any
			// already parsed git-meta (#503)
			for each (var repo:Object in duplicate)
			{
				if (repo.children && 
					repo.children.length > 0 && 
					repo.type == VersionControlTypes.SVN)
				{
					repo.children = [];
				}
				
				// also don't store any password if asked to
				// save for current session
				repo.userPassword = null;
			}
			
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
			cookie.data['savedRepositories'] = duplicate;
			cookie.data['defaultRepositoriesPopulated'] = true;
			cookie.flush();
		}
		
		public static function resetRepositoriesSO():void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.REPOSITORY_HISTORY);
			cookie.clear();
			cookie.flush();
		}

		public static function saveProjectTreeItemForOpen(item:Object, propertyNameKey:String,
                                                          propertyNameKeyValue:String):void
		{
            if (!IDEModel.getInstance().openPreviouslyOpenedProjectBranches) return;

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
            if (!IDEModel.getInstance().openPreviouslyOpenedProjectBranches) return;
            
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var projectTree:Array = cookie.data.projectTree;
            if (!projectTree) return;
            var cookieName:String = "projectTree";
			var isItemRemoved:Boolean = removeProjectItem(item, propertyNameKey, propertyNameKeyValue, cookieName);
            if (isItemRemoved && propertyNameKeyValue == "path")
            {
                removeProjectLefovers(item, propertyNameKeyValue);
            }
		}

		public static function saveLocationOfOpenedProjectFile(fileName:String, filePath:String, projectPath:String):void
		{
            var model:IDEModel = IDEModel.getInstance();
            if (!model.openPreviouslyOpenedFiles) return;

            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var projectLocation:FileLocation = new FileLocation(projectPath);
            var projectReferenceVO: ProjectReferenceVO = new ProjectReferenceVO();
            projectReferenceVO.path = projectPath;
            var fileProjectWrapper:FileWrapper = new FileWrapper(projectLocation, false, projectReferenceVO, false);

			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fileProjectWrapper);
			if (!project) return;
			
			var cookieName:String = "projectFiles" + project.name;
            if (!cookie.data[cookieName])
            {
                cookie.data[cookieName] = [];
            }

            saveProjectItem({name: fileName, path: filePath}, "name", "path", cookieName);
		}

		public static function removeLocationOfClosingProjectFile(fileName:String, filePath:String, projectPath:String):void
		{
            var model:IDEModel = IDEModel.getInstance();
            if (!model.openPreviouslyOpenedFiles) return;

            var projectLocation:FileLocation = new FileLocation(projectPath);
            var projectReferenceVO: ProjectReferenceVO = new ProjectReferenceVO();
            projectReferenceVO.path = projectPath;
            var fileProjectWrapper:FileWrapper = new FileWrapper(projectLocation, false, projectReferenceVO, false);

            var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fileProjectWrapper);
            if (!project) return;

			removeProjectItem({name: fileName, path: filePath}, "name", "path", "projectFiles" + project.name);
		}

        public static function saveProjectForOpen(projectFolderPath:String, projectName:String):void
        {
            var model:IDEModel = IDEModel.getInstance();
            if (!model.openPreviouslyOpenedProjects) return;

            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            if (!cookie.data["projects"])
            {
                cookie.data["projects"] = [];
            }

            saveProjectItem({name: projectFolderPath, path: projectName}, "name", "path", "projects");
        }

        public static function removeProjectFromOpen(projectFolderPath:String, projectName:String):void
        {
            var model:IDEModel = IDEModel.getInstance();
            if (!model.openPreviouslyOpenedProjects) return;

            removeProjectItem({name: projectFolderPath, path: projectName}, "name", "path", "projects");
        }

        public static function removeCookieByName(cookieName:String):void
        {
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            if (cookie.data.hasOwnProperty(cookieName))
            {
                delete cookie.data[cookieName];
                cookie.flush();
            }
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
                                                  propertyNameKeyValue:String, cookieName:String):Boolean
		{
			var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);

            if (item && item.hasOwnProperty(propertyNameKeyValue) && item.hasOwnProperty(propertyNameKey))
            {
				var data:Object = cookie.data;
                if (!data.hasOwnProperty(cookieName)) return false;

                for (var i:int = 0; i < data[cookieName].length; i++)
                {
                    var itemForRemove:Object = data[cookieName][i];
                    var itemForRemoveProperty:String = itemForRemove[item[propertyNameKey]];
                    var itemValue:String = item[propertyNameKeyValue];
                    if (itemForRemove.hasOwnProperty(item[propertyNameKey]) &&
                        itemForRemoveProperty == itemValue)
                    {
                        data[cookieName].removeAt(i);
                        cookie.flush();
                        return true;
                    }
                }
            }

            return false;
		}

        private static function removeProjectLefovers(item:Object, propertyNameKeyValue:String):void
        {
            var cookie:Object = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
            var cookieName:String = "projectTree";

            var data:Object = cookie.data;
            for (var i:int = 0; i < data[cookieName].length; i++)
            {
                var itemForRemove:Object = data[cookieName][i];
                var itemValue:String = item[propertyNameKeyValue];

                for (var itemRemove:Object in itemForRemove)
                {
                    var itemProperty:String = itemForRemove[itemRemove];
                    if (itemProperty.indexOf(itemValue) > -1)
                    {
                        data[cookieName].removeAt(i);
                        cookie.flush();
                    }
                }
            }
        }
    }
}