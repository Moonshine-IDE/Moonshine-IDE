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
package actionScripts.impls
{
    import actionScripts.interfaces.IVisualEditorBridge;
    import actionScripts.plugin.visualEditor.VisualEditorProjectPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugins.ui.editor.VisualEditorViewer;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.ui.IContentWindow;

    public class IVisualEditorProjectBridgeImpl extends ProjectBridgeImplBase implements IVisualEditorBridge
    {
        public function IVisualEditorProjectBridgeImpl()
        {
            super();
        }

        public function getVisualEditor(visualEditorProject:ProjectVO):BasicTextEditor
        {
            return new VisualEditorViewer(visualEditorProject);
        }

        public function renameDominoFormFileSave(visualEditor:IContentWindow,fileName:String):String
        {
            var formXmlString:String=null;
            var editor:VisualEditorViewer = visualEditor as VisualEditorViewer;
            if(editor){
                formXmlString =editor.renameDominoFormFileSave(fileName);
            }
            return formXmlString;
        }

        public function getCorePlugins():Array
        {
            return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
                VisualEditorProjectPlugin
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
            ];
        }

        public function get runtimeVersion():String
        {
            return "";
        }

        public function get version():String
        {
            return "";
        }
    }
}
