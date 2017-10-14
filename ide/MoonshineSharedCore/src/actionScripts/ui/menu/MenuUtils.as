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
        private static var menuItemsDisabledInVEProject:Array = [
            resourceManager.getString('resources', 'NEW'),
            resourceManager.getString('resources', 'OPEN'),
            resourceManager.getString('resources', 'SAVE'),
            resourceManager.getString('resources', 'SAVE_AS'),
            resourceManager.getString('resources', 'CLOSE'),
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
            resourceManager.getString('resources', 'USEFUL_LINKS'),
            resourceManager.getString('resources', 'VE_PROJECT'),
            resourceManager.getString('resources', 'ACTION_SCRIPT_PROJECT'),
            resourceManager.getString('resources', 'FLEX_MOBILE_PROJECT'),
            resourceManager.getString('resources', 'FLEX_DESKTOP_PROJECT'),
            resourceManager.getString('resources', 'FLEX_BROWSER_PROJECT'),
            resourceManager.getString('resources', 'FLEXJS_BROWSER_PROJECT'),
            resourceManager.getString('resources', 'FEATHERS_DESKTOP_PROJECT'),
            resourceManager.getString('resources', 'FEATHERS_MOBILE_PROJECT'),
            resourceManager.getString('resources', 'AWAY3D_PROJECT'),
            resourceManager.getString('resources', 'REFRESH'),
            resourceManager.getString('resources', 'SETTINGS'),
            resourceManager.getString('resources', 'DELETE'),
            resourceManager.getString('resources', 'RENAME'),
            "Visual Editor Flex File"
        ];

        private static var menuItemsDisabledNoneVEProject:Array = [
            resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'),
            "Visual Editor Flex File"
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
                return menuItemsDisabledInVEProject.indexOf(label) > -1;
            }

            return true;
        }

        public static function isMenuItemDisabledNoneVisualEditorProject(label:String, project:ProjectVO = null):Boolean
        {
            var currentProject:AS3ProjectVO = project as AS3ProjectVO;
            if (!currentProject)
            {
                var model:IDEModel = IDEModel.getInstance();
                currentProject = model.activeProject as AS3ProjectVO;
            }

            if (currentProject && !currentProject.isVisualEditorProject)
            {
                return menuItemsDisabledNoneVEProject.indexOf(label) > -1;
            }

            return false;
        }
    }
}
