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
package actionScripts.ui.menu
{
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ProjectVO;

    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    public class MenuUtils
    {
        private static var resourceManager:IResourceManager = ResourceManager.getInstance();
        public static var menuItemsEnabledInVEProject:Array = [
            resourceManager.getString('resources', 'NEW'),
            resourceManager.getString('resources', 'OPEN'),
            resourceManager.getString('resources', 'SAVE'),
            resourceManager.getString('resources', 'SAVE_AS'),
            resourceManager.getString('resources', 'CLOSE'),
			resourceManager.getString('resources', 'CLOSE_ALL'),
            resourceManager.getString('resources', 'QUIT'),
            resourceManager.getString('resources', 'FIND'),
            resourceManager.getString('resources', 'FINDE_PREV'),
            resourceManager.getString('resources', 'PROJECT_VIEW'),
            resourceManager.getString('resources', 'FULLSCREEN'),
            resourceManager.getString('resources', 'HOME'),
            resourceManager.getString('resources', 'CHECKOUT'),
            resourceManager.getString('resources', 'ABOUT'),
            resourceManager.getString('resources', 'TOUR_DE_FLEX'),
            resourceManager.getString('resources', 'OPEN_IMPORT_PROJECT'),
            resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'),
			resourceManager.getString('resources', 'SEARCH_IN_PROJECTS'),
            resourceManager.getString('resources', 'USEFUL_LINKS'),
            resourceManager.getString('resources', 'REFRESH'),
            resourceManager.getString('resources', 'SETTINGS'),
            resourceManager.getString('resources', 'DELETE'),
            resourceManager.getString('resources', 'RENAME'),
            resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE'),
            resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE'),
            "Copy Path",
            "Show in Explorer",
            "Show in Finder"
        ];

        private static var menuItemsDisabledNoneVEProject:Array = [
            resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'),
            resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE'),
            resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE')
        ];

        public static function isMenuItemEnabledInVisualEditor(label:String, project:ProjectVO = null):Boolean
        {
            var currentProject:AS3ProjectVO = project as AS3ProjectVO;
            if (!currentProject)
            {
                var model:IDEModel = IDEModel.getInstance();
                currentProject = model.activeProject as AS3ProjectVO;
            }

            if (currentProject && currentProject.isVisualEditorProject)
            {
                if (currentProject.isPrimeFacesVisualEditorProject && label && label.indexOf(resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE')) > -1)
                {
                    return false;
                }
                else if (!currentProject.isPrimeFacesVisualEditorProject && label && label.indexOf(resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE')) > -1)
                {
                    return false;
                }

                return menuItemsEnabledInVEProject.indexOf(label) > -1;
            }

            return !isMenuItemDisabledNoneVisualEditorProject(label, project);
        }

        public static function isMenuItemDisabledNoneVisualEditorProject(label:String, project:ProjectVO = null):Boolean
        {
            var currentProject:AS3ProjectVO = project as AS3ProjectVO;
            if (!currentProject)
            {
                var model:IDEModel = IDEModel.getInstance();
                currentProject = model.activeProject as AS3ProjectVO;
            }

            if (label == "MXML File" && currentProject && currentProject.isActionScriptOnly)
            {
                return true;
            }

            if (!currentProject || !currentProject.isVisualEditorProject || currentProject.isActionScriptOnly)
            {
                return menuItemsDisabledNoneVEProject.indexOf(label) > -1;
            }

            return false;
        }
    }
}
