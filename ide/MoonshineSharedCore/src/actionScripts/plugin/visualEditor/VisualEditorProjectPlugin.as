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
    import actionScripts.events.ProjectEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ProjectVO;

    import flash.events.Event;

    public class VisualEditorProjectPlugin extends PluginBase
    {
        override public function get name():String 	{return "Visual Editor Project";}
        override public function get author():String {return "Moonshine Project Team";}
        override public function get description():String 	{return "Visual Editor project is aim to start create your application visually.";}

        public function VisualEditorProjectPlugin()
        {
            super();
        }

        override public function activate():void
        {
            dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, visualEditorCreateNewProjectHandler);
            dispatcher.addEventListener(ProjectEvent.INIT_EXPORT_VISUALEDITOR_PROJECT, visualEditorExportVisualEditorProjectHandler);

            super.activate();
        }

        override public function deactivate():void
        {
            dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, visualEditorCreateNewProjectHandler);
            dispatcher.removeEventListener(ProjectEvent.INIT_EXPORT_VISUALEDITOR_PROJECT, visualEditorExportVisualEditorProjectHandler);

            super.deactivate();
        }

        private function visualEditorCreateNewProjectHandler(event:NewProjectEvent):void
        {
            if (!canCreateProject(event)) return;

            model.visualEditorCore.createProject(event);
        }

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) > -1;
        }

        private function visualEditorExportVisualEditorProjectHandler(event:Event):void
        {
            var currentActiveProject:ProjectVO = model.activeProject;
            UtilsCore.closeAllRelativeEditors(model.activeProject, false,
                    function():void
                    {
                        dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.EXPORT_VISUALEDITOR_PROJECT, currentActiveProject));
                    }, false);
        }
    }
}
