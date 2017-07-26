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
package actionScripts.plugin.visualEditor
{
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.templating.TemplatingHelper;
    import actionScripts.plugin.templating.event.TemplateEvent;
    import actionScripts.utils.FileCoreUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;

    public class VisualEditorProjectPlugin extends PluginBase
    {
        override public function get name():String 	{return "Visual Editor Project Plugin";}
        override public function get author():String {return "Moonshine Project Team";}
        override public function get description():String 	{return "Visual Editor project is aim to start create your application visually.";}

        public function VisualEditorProjectPlugin()
        {
            super();
        }

        override public function activate():void
        {
            dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, onVisualEditorCreateNewProject);
            dispatcher.addEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, onTemplatingRequestAdditionalData);

            super.activate();
        }

        override public function deactivate():void
        {
            dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, onVisualEditorCreateNewProject);
            dispatcher.removeEventListener(TemplateEvent.REQUEST_ADDITIONAL_DATA, onTemplatingRequestAdditionalData);

            super.deactivate();
        }

        private function onVisualEditorCreateNewProject(event:NewProjectEvent):void
        {
            if (!canCreateProject(event)) return;

            model.visualEditor.createProject(event);
        }

        private function onTemplatingRequestAdditionalData(event:TemplateEvent):void
        {
            /*if (TemplatingHelper.getExtension(event.template) == "as")
            {
                if (ConstantsCoreVO.IS_AIR && event.location)
                {
                    // Find project it belongs to
                    for each (var p:ProjectVO in model.projects)
                    {
                        if (p is AS3ProjectVO && p.projectFolder.containsFile(event.location))
                        {
                            // Populate templating data
                            event.templatingData = getTemplatingData(event.location, p as AS3ProjectVO);
                            return;
                        }
                    }
                }

                // If nothing is found - guess the data
                event.templatingData = {};
                event.templatingData['$projectName'] = "New";
                event.templatingData['$packageName'] = "";
                event.templatingData['$fileName'] = "New";
            }   */
        }

        private function getTemplatingData(file:FileLocation, project:AS3ProjectVO):Object
        {
           /* var toRet:Object = {};
            toRet['$projectName'] = project.name;

            // Figure out package name
            if (ConstantsCoreVO.IS_AIR)
            {
                for each (var dir:FileLocation in project.classpaths)
                {
                    if (FileCoreUtil.contains(dir, flashBuilderProjectFile))
                    {
                        // Convert path to package name in dot-style
                        var relativePath:String = dir.fileBridge.getRelativePath(flashBuilderProjectFile);
                        var packagePath:String = relativePath.substring(0, relativePath.indexOf(flashBuilderProjectFile.fileBridge.name));
                        if (packagePath.charAt(packagePath.length-1) == model.fileCore.separator)
                        {
                            packagePath = packagePath.substring(0, packagePath.length-1);
                        }
                        var packageName:String = packagePath.split(model.fileCore.separator).join(".");
                        toRet['$packageName'] = packageName;
                        break;
                    }
                }

                var name:String = flashBuilderProjectFile.fileBridge.name.split(".")[0];
                toRet['$fileName'] = name;
            }

            return toRet; */
            return null;
        }

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) > -1;
        }
    }
}
